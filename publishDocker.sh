#!/bin/bash
set -e

EXTENSION=
BUILD_ONLY=false
for arg in "$@"; do
  case "$arg" in
    --extension=*) EXTENSION="${arg#--extension=}" ;;
    --build-only) BUILD_ONLY=true ;;
  esac
done

if [ -z "$EXTENSION" ]; then
  echo "Error: --extension=<name> is required"
  exit 1
fi

EXTENSION_NAME="uc-$EXTENSION"

if command -v docker &> /dev/null; then
  RUNTIME="docker buildx"
elif command -v podman &> /dev/null; then
  RUNTIME=podman
else
  echo "Error: neither docker nor podman found"
  exit 1
fi

SCRIPT_DIR=$(dirname "$0")
VERSION=$(node -p "require('./package.json').version")
IMAGE_BASE="europe-west2-docker.pkg.dev/kps-unified-commerce/kps-connect/$EXTENSION_NAME"

$RUNTIME build --platform linux/amd64 -f "$SCRIPT_DIR/Dockerfile" \
  -t "$IMAGE_BASE:latest" \
  -t "$IMAGE_BASE:$VERSION" \
  --build-arg NPM_TOKEN=$(gcloud auth print-access-token) .
if [ "$BUILD_ONLY" = false ]; then
  $RUNTIME push "$IMAGE_BASE:latest"
  $RUNTIME push "$IMAGE_BASE:$VERSION"
fi
