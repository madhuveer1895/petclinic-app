# =========================
# Stage 1: Build with Maven
# =========================
FROM maven:3.9.9-eclipse-temurin-17 AS builder

WORKDIR /app

# Copy pom.xml and download dependencies first (cache layer)
COPY pom.xml .
COPY .mvn/ .mvn
COPY mvnw .
RUN ./mvnw dependency:go-offline -B

# Copy the rest of the project
COPY src src

# Build the JAR (skip tests to save time here)
RUN ./mvnw clean package -DskipTests

# =========================
# Stage 2: Run with JDK
# =========================
FROM openjdk:17-jdk-slim

WORKDIR /opt/app

# Copy only the built JAR from builder stage
COPY --from=builder /app/target/*.jar app.jar

# Expose app port
EXPOSE 8080

# Run the app with MongoDB URI
ENTRYPOINT ["java", "-Dspring.data.mongodb.uri=mongodb://mongo:27017/spring-mongo", "-jar", "app.jar"]

