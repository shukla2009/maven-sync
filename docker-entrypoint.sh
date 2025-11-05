#!/bin/bash
set -euo pipefail

# Generate settings.xml from environment variables if provided
# This allows Docker to use env vars instead of hardcoded credentials
if [[ -n "${GITHUB_USERNAME:-}" || -n "${GITHUB_TOKEN:-}" || -n "${AZURE_USERNAME:-}" || -n "${AZURE_TOKEN:-}" ]]; then
  echo "🔧 Generating settings.xml from environment variables"
  cat > settings.xml <<EOF
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0">
  <servers>
    <server>
      <id>github</id>
      <username>${GITHUB_USERNAME:-}</username>
      <password>${GITHUB_TOKEN:-}</password>
    </server>
    <server>
      <id>azure</id>
      <username>${AZURE_USERNAME:-}</username>
      <password>${AZURE_TOKEN:-}</password>
    </server>
    <server>
      <id>central</id>
      <username></username>
      <password></password>
    </server>
  </servers>
</settings>
EOF
else
  echo "ℹ️  Using existing settings.xml (no environment variables provided)"
fi

# Execute the sync script with provided arguments
exec ./sync.sh "$@"

