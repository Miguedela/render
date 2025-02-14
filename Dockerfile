# Etapa 1: Build (Compilación)
FROM eclipse-temurin:23-jdk AS builder

WORKDIR /app

# Instalar Maven manualmente
RUN apt-get update && apt-get install -y curl tar \
    && curl -fsSL https://downloads.apache.org/maven/maven-3/3.9.6/binaries/apache-maven-3.9.6-bin.tar.gz \
    | tar xz -C /opt \
    && ln -s /opt/apache-maven-3.9.6/bin/mvn /usr/bin/mvn

# Copiar código fuente y dependencias
COPY pom.xml .
RUN mvn dependency:go-offline
COPY . .

# Construir la aplicación sin ejecutar pruebas
RUN mvn clean package -DskipTests

# Etapa 2: Runtime (Ejecución)
FROM eclipse-temurin:23-jre

WORKDIR /app

# Copiar solo el JAR desde la etapa de compilación
COPY --from=builder /app/target/*.jar app.jar

# Exponer el puerto de la aplicación
EXPOSE 8080

# Ejecutar la aplicación
ENTRYPOINT ["java", "-jar", "app.jar"]
