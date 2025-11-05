#!/bin/bash
set -euo pipefail

CONFIG_FILE="config.yaml"
PACKAGE_FILE="packages.list"
SETTINGS_FILE="settings.xml"

# -------------------------------
# Check input arguments
# -------------------------------
if [[ $# -ne 2 ]]; then
  echo "Usage: $0 <source> <target>"
  echo "Example: $0 central azure"
  exit 1
fi

SRC_NAME=$1
TGT_NAME=$2

if ! command -v yq >/dev/null 2>&1; then
  echo "❌ 'yq' command not found. Please install it: brew install yq"
  exit 1
fi

# -------------------------------
# Load config for source and target
# -------------------------------
SRC_URL=$(yq -r ".sources[\"$SRC_NAME\"].url" "$CONFIG_FILE")
SRC_ID=$(yq -r ".sources[\"$SRC_NAME\"].id" "$CONFIG_FILE")
TGT_URL=$(yq -r ".targets[\"$TGT_NAME\"].url" "$CONFIG_FILE")
TGT_ID=$(yq -r ".targets[\"$TGT_NAME\"].id" "$CONFIG_FILE")

if [[ "$SRC_URL" == "null" || "$TGT_URL" == "null" ]]; then
  echo "❌ Invalid source or target. Check config.yaml."
  exit 1
fi

echo "🔗 Source: $SRC_NAME ($SRC_URL)"
echo "🎯 Target: $TGT_NAME ($TGT_URL)"
echo

# -------------------------------
# Process each package
# -------------------------------
while IFS= read -r line; do
  [[ -z "$line" || "$line" =~ ^# ]] && continue

  IFS=':' read -r GROUP_ID ARTIFACT_ID VERSION <<< "$line"
  if [[ -z "$GROUP_ID" || -z "$ARTIFACT_ID" || -z "$VERSION" ]]; then
    echo "⚠️ Skipping invalid line: $line"
    continue
  fi

  echo "📦 Syncing ${GROUP_ID}:${ARTIFACT_ID}:${VERSION}"

  # Step 1: Download from source
  mvn dependency:get \
    -s "$SETTINGS_FILE" \
    -DrepoUrl="$SRC_URL" \
    -Dartifact="${GROUP_ID}:${ARTIFACT_ID}:${VERSION}" \
    -Dtransitive=false -q || { echo "❌ Failed to get $ARTIFACT_ID"; continue; }

  LOCAL_REPO="$HOME/.m2/repository/${GROUP_ID//.//}/${ARTIFACT_ID}/${VERSION}"
  JAR_FILE="${LOCAL_REPO}/${ARTIFACT_ID}-${VERSION}.jar"
  POM_FILE="${LOCAL_REPO}/${ARTIFACT_ID}-${VERSION}.pom"

  if [[ ! -f "$JAR_FILE" || ! -f "$POM_FILE" ]]; then
    echo "❌ Missing JAR or POM for $ARTIFACT_ID"
    continue
  fi

  # Step 2: Deploy to target
  mvn deploy:deploy-file \
    -s "$SETTINGS_FILE" \
    -Dfile="$JAR_FILE" \
    -DpomFile="$POM_FILE" \
    -DrepositoryId="$TGT_ID" \
    -Durl="$TGT_URL" \
    -q || { echo "❌ Failed to deploy $ARTIFACT_ID"; continue; }

  echo "✅ Synced ${ARTIFACT_ID}:${VERSION} from $SRC_NAME → $TGT_NAME"
  echo "-------------------------------------------"

done < "$PACKAGE_FILE"

echo "🎉 All packages processed successfully!"
