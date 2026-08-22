#!/bin/bash

set -e

REGION="ap-south-1"
ECR_REPO="774118824657.dkr.ecr.ap-south-1.amazonaws.com/patient-service"
IMAGE_TAG="__IMAGE_TAG__"

SECRET_ARN="arn:aws:secretsmanager:ap-south-1:774118824657:secret:patient-service/rds-agbOdR"

RDS_HOST="patientdb2.cxeseem0ax4c.ap-south-1.rds.amazonaws.com"
RDS_PORT="5432"
RDS_DB="postgres"


# ============================================================
# 1. Install Docker
# ============================================================

dnf install -y docker

systemctl enable --now docker


# ============================================================
# 2. Install CloudWatch Agent
# ============================================================

dnf install -y amazon-cloudwatch-agent


# ============================================================
# 3. Configure CloudWatch Agent
# ============================================================

cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json <<'EOF'
{
  "agent": {
    "metrics_collection_interval": 60,
    "run_as_user": "root"
  },
  "metrics": {
    "namespace": "PatientService/EC2",
    "metrics_collected": {
      "mem": {
        "measurement": [
          "mem_used_percent"
        ],
        "metrics_collection_interval": 60
      },
      "disk": {
        "measurement": [
          "used_percent"
        ],
        "resources": [
          "/"
        ],
        "metrics_collection_interval": 60
      }
    }
  },
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/lib/docker/containers/*/*-json.log",
            "log_group_name": "/aws/ec2/patient-service",
            "log_stream_name": "{instance_id}/docker",
            "timezone": "UTC"
          }
        ]
      }
    }
  }
}
EOF


# ============================================================
# 4. Start CloudWatch Agent
# ============================================================

/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config \
  -m ec2 \
  -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json \
  -s


# ============================================================
# 5. Authenticate to ECR
# ============================================================

aws ecr get-login-password --region "$REGION" | \
docker login --username AWS --password-stdin "$ECR_REPO"


# ============================================================
# 6. Pull application image
# ============================================================

docker pull "$ECR_REPO:$IMAGE_TAG"


# ============================================================
# 7. Get database credentials from Secrets Manager
# ============================================================

SECRET=$(aws secretsmanager get-secret-value \
    --secret-id "$SECRET_ARN" \
    --region "$REGION" \
    --query SecretString \
    --output text)

DB_USERNAME=$(echo "$SECRET" | python3 -c \
'import sys,json; print(json.load(sys.stdin)["username"])')

DB_PASSWORD=$(echo "$SECRET" | python3 -c \
'import sys,json; print(json.load(sys.stdin)["password"])')


# ============================================================
# 8. Remove existing container if present
# ============================================================

docker rm -f patient-service 2>/dev/null || true


# ============================================================
# 9. Start Spring Boot application
# ============================================================

docker run -d \
    --name patient-service \
    --restart unless-stopped \
    -p 4000:4000 \
    -e SPRING_DATASOURCE_URL="jdbc:postgresql://$RDS_HOST:$RDS_PORT/$RDS_DB" \
    -e SPRING_DATASOURCE_USERNAME="$DB_USERNAME" \
    -e SPRING_DATASOURCE_PASSWORD="$DB_PASSWORD" \
    -e SPRING_SQL_INIT_MODE="always" \
    "$ECR_REPO:$IMAGE_TAG"