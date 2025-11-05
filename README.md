# Maven Sync

Tool to sync Maven packages between different repositories (Maven Central, GitHub Packages, Azure Artifacts).

## Prerequisites

- Maven
- yq (YAML processor): `brew install yq` on macOS
- Environment variables for authentication (see below)

## Local Usage

```bash
# Set environment variables
export GITHUB_USERNAME=myuser
export GITHUB_TOKEN=ghp_xxx
export AZURE_USERNAME=azureuser
export AZURE_TOKEN=azd_xxx

# Sync from Maven Central → Azure Artifacts
./sync.sh central azure

# Sync from GitHub → Azure
./sync.sh github azure

# Sync from Central → GitHub
./sync.sh central github
```

## Docker Usage

### Using Docker directly

```bash
# Build the image
docker build -t maven-sync:latest .

# Run with environment variables and mounted config files
docker run --rm \
  --env-file .env \
  -v "$(pwd)/config.yaml:/app/config.yaml:ro" \
  -v "$(pwd)/packages.list:/app/packages.list:ro" \
  -v maven-repo:/root/.m2/repository \
  maven-sync:latest central github

# Or pass environment variables directly
docker run --rm \
  -e GITHUB_USERNAME=myuser \
  -e GITHUB_TOKEN=ghp_xxx \
  -v "$(pwd)/config.yaml:/app/config.yaml:ro" \
  -v "$(pwd)/packages.list:/app/packages.list:ro" \
  -v maven-repo:/root/.m2/repository \
  maven-sync:latest central github
```

### Using Docker Compose

```bash
# 1. Create .env file with your credentials
cp .env.example .env
# Edit .env with your actual credentials

# 2. Build and run
docker-compose run --rm maven-sync central github

# Or build first, then run
docker-compose build
docker-compose run --rm maven-sync central azure
```

The Docker Compose setup automatically:
- Reads environment variables from `.env` file
- Mounts `config.yaml` and `packages.list` as volumes (read-only)
- Persists Maven local repository in a named volume
- Cleans up after execution (`--rm` flag)

**Note:** You can modify `config.yaml` and `packages.list` on your host without rebuilding the Docker image.