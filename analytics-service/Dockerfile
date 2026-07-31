## docker build -t analytics-service:latest .
## docker run -d --name analytics-service --network internal -p 4002:4002 -e SPRING_KAFKA_BOOTSTRAP_SERVERS=kafka:9092 analytics-service:latest

FROM maven:3.9.9-eclipse-temurin-21 AS builder
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline -B

COPY src ./src
RUN mvn clean package -DskipTests

FROM eclipse-temurin:21-jre
WORKDIR /app

COPY --from=builder ./app/target/analytics-service-0.0.1-SNAPSHOT.jar ./app.jar
EXPOSE 4002
ENTRYPOINT ["java", "-jar", "app.jar"]