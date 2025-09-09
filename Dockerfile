# Stage 1: Build JAR
FROM maven:3.9.9-eclipse-temurin-17 AS builder

WORKDIR /app

COPY pom.xml .
COPY .mvn/ .mvn/
COPY mvnw .

# Download dependencies
RUN mvn dependency:go-offline -B -Dmaven.repo.local=/root/.m2/repository

# Copy source
COPY src ./src

# Build the JAR
RUN mvn clean package -DskipTests -Dmaven.repo.local=/root/.m2/repository

# Stage 2: Runtime
FROM openjdk:17-jdk-slim

WORKDIR /opt/app
COPY --from=builder /app/target/*.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java","-Dspring.data.mongodb.uri=mongodb://mongo:27017/spring-mongo","-Djava.security.egd=file:/dev/./urandom","-jar","app.jar"]

