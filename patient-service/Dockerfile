## docker build -t patient-service:latest .

##
#docker run -d --name patient-service --network internal \
#  -p 4000:4000 \
#  -e SPRING_DATASOURCE_URL=jdbc:postgresql://patient-service-db:5432/db \
#  -e SPRING_DATASOURCE_USERNAME=admin_user \
#  -e SPRING_DATASOURCE_PASSWORD=password \
#  -e SPRING_JPA_HIBERNATE_DDL_AUTO=update \
#  -e SPRING_SQL_INIT_MODE=always \
#  -e BILLING_SERVICE_ADDRESS=billing-service
#  -e BILLING_SERVICE_GRPC_PORT=9001
#  -e SPRING_KAFKA_BOOTSTRAP_SERVERS=kafka:9092
#  patient-service:latest
##

FROM maven:3.9.9-eclipse-temurin-21 AS builder
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline -B

COPY src ./src
RUN mvn clean package -DskipTests

FROM eclipse-temurin:21-jre
WORKDIR /app

COPY --from=builder /app/target/patient-service-0.0.1-SNAPSHOT.jar app.jar
EXPOSE 4000
ENTRYPOINT ["java", "-jar", "app.jar"]