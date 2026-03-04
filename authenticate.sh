#!/bin/bash
set -e

if ! command -v gcloud &> /dev/null; then
  echo "Error: gcloud is not installed. Please install the Google Cloud SDK: https://cloud.google.com/sdk/docs/install"
  exit 1
fi

if [ -f .env ]; then
  set -a
  source .env
  set +a
fi

if [ -n "$GOOGLE_CLOUD_API_KEY" ]; then
  echo "Getting access token..."
  echo "$GOOGLE_CLOUD_API_KEY" | gcloud auth activate-service-account --key-file=-
fi

TOKEN=$(gcloud auth print-access-token)

NPMRC="$HOME/.npmrc"
REGISTRY_BASE="europe-west2-npm.pkg.dev/kps-unified-commerce/kps-connect-npm"
REGISTRY_URL="https://${REGISTRY_BASE}/"
AUTH_LINE="//${REGISTRY_BASE}/:_authToken=${TOKEN}"
SCOPED_REGISTRY_LINE="@kps:registry=${REGISTRY_URL}"

if [ -f "$NPMRC" ] && grep -q "$REGISTRY_BASE" "$NPMRC"; then
  sed -i.bak "s|//${REGISTRY_BASE}/:_authToken=.*|${AUTH_LINE}|" "$NPMRC"
  rm -f "$NPMRC.bak"
  echo "Updated existing token in $NPMRC"
else
  printf "\n%s\n" "$AUTH_LINE" >> "$NPMRC"
  echo "Added token to $NPMRC"
fi

if ! grep -q "^@kps:registry=" "$NPMRC"; then
  printf "\n%s\n" "$SCOPED_REGISTRY_LINE" >> "$NPMRC"
  echo "Added @kps scoped registry to $NPMRC"
fi

# Remove any global registry override that would break public packages
sed -i.bak "/^registry=https:\/\/${REGISTRY_BASE//\//\\/}/d" "$NPMRC"
rm -f "$NPMRC.bak"