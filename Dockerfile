FROM maven:3.9-eclipse-temurin-17 AS builder

# Install yq (YAML processor)
RUN apt-get update && apt-get install -y \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Install yq
RUN wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 \
    && chmod +x /usr/local/bin/yq

# Set working directory
WORKDIR /app

# Copy scripts and default settings.xml
# Note: config.yaml and packages.list will be mounted as volumes
COPY settings.xml sync.sh docker-entrypoint.sh ./

# Make scripts executable
RUN chmod +x sync.sh docker-entrypoint.sh

# Set Maven local repository location
ENV MAVEN_OPTS="-Dmaven.repo.local=/root/.m2/repository"

# Use entrypoint script that generates settings.xml from env vars
ENTRYPOINT ["./docker-entrypoint.sh"]

