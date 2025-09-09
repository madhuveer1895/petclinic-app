# ----------------------
# Stage 1: Build JAR
# ----------------------
FROM maven:3.8.7-openjdk-17-slim AS build

WORKDIR /app

# Copy Maven wrapper and pom.xml first (to leverage caching)
COPY mvnw .
COPY .mvn/ .mvn/
COPY pom.xml .

# Pre-download dependencies (cache layer)
RUN ./mvnw dependency:go-offline -B

# Copy full source and build
COPY src ./src
RUN ./mvnw clean package -DskipTests


# ----------------------
# Stage 2: Runtime image
# ----------------------
FROM openjdk:17-jdk-slim

# App directory
WORKDIR /opt/app

# Copy the JAR from build stage
COPY --from=build /app/target/*.jar spring-petclinic-pro.jar

# Expose app port
EXPOSE 8080

# Run with MongoDB connection string
CMD ["java", "-Dspring.data.mongodb.uri=mongodb://mongo:27017/spring-mongo", \
     "-Djava.security.egd=file:/dev/./urandom", \
     "-jar", "spring-petclinic-pro.jar"]

