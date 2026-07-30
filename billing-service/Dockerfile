## docker build -t billing-service:latest .

## docker run -d  --name billing-service --network internal -p 4001:4001 -p 9001:9001 billing-service:latest


## docker run -d --name patient-service-db --network internal -p 5000:5432 -e POSTGRES_DB=db -e POSTGRES_USER=admin_user -e POSTGRES_PASSWORD=password -v /Users/zeeshanhaider/docker-volumes/patient-service:/var/lib/postgresql/data postgres:16

FROM maven:3.9.9-eclipse-temurin-21 AS builder
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline -B

COPY src ./src
RUN mvn clean package -DskipTests

FROM eclipse-temurin:21-jre
WORKDIR /app

COPY --from=builder /app/target/billing-service-0.0.1-SNAPSHOT.jar app.jar
EXPOSE 4001
EXPOSE 9001
ENTRYPOINT ["java", "-jar", "app.jar"]