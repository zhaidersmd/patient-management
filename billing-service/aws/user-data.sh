#!/bin/bash

set -e
REGION="ap-south-1"
ECR_REPO="774118824657.dkr.ecr.ap-south-1.amazonaws.com/billing-service"
IMAGE_TAG="__IMAGE_TAG__"

dnf install -y docker
systemctl enable --now docker

aws ecr get-login-password \
    --region "$REGION" | \
docker login \
    --username AWS \
    --password-stdin "$ECR_REPO"


docker pull "$ECR_REPO:$IMAGE_TAG"

docker rm -f billing-service 2>/dev/null || true


docker run -d \
    --name billing-service \
    --restart unless-stopped \
    -p 9001:9001 \
    "$ECR_REPO:$IMAGE_TAG"