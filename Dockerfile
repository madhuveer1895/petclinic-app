# Stage 1: Build JAR
FROM maven:3.9.9-eclipse-temurin-17 AS builder

WORKDIR /app

COPY mvnw .
COPY .mvn/ .mvn/
COPY pom.xml .

# Download dependencies (cache layer)
RUN ./mvnw dependency:go-offline -B

COPY src ./src

RUN ./mvnw clean package -DskipTests

# Stage 2: Runtime
FROM openjdk:17-jdk-slim

WORKDIR /opt/app

COPY --from=builder /app/target/*.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-Dspring.data.mongodb.uri=mongodb://mongo:27017/spring-mongo", \
            "-Djava.security.egd=file:/dev/./urandom", \
            "-jar", "app.jar"]
[I
