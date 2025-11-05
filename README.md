```
export GITHUB_USERNAME=myuser
export GITHUB_TOKEN=ghp_xxx
export AZURE_USERNAME=azureuser
export AZURE_TOKEN=azd_xxx

# Sync from Maven Central → Azure Artifacts
./sync-maven.sh central azure

# Sync from GitHub → Azure
./sync-maven.sh github azure

# Sync from Central → GitHub
./sync-maven.sh central github
```