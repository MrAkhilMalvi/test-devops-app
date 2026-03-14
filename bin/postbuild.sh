#!/usr/bin/env bash

set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TF_DIR="${TF_DIR:-$ROOT_DIR/terraform}"
BUILD_DIR="${BUILD_DIR:-$ROOT_DIR/build}"
METADATA_FILE="${METADATA_FILE:-$BUILD_DIR/image-metadata.env}"

log() {
  printf '\n[%s] %s\n' "$1" "$2"
}

fail() {
  printf '\n[ERROR] %s\n' "$1" >&2
  exit 1
}

require_command() {
  command -v "$1" >/dev/null 2>&1 || fail "Missing required command: $1"
}

main() {
  export TF_IN_AUTOMATION=1

  require_command terraform

  if [[ ! -f "$METADATA_FILE" ]]; then
    fail "Build metadata file not found at $METADATA_FILE. Run bin/build.sh first."
  fi

  # shellcheck disable=SC1090
  source "$METADATA_FILE"

  : "${APP_NAME:?APP_NAME missing from build metadata}"
  : "${AWS_REGION:?AWS_REGION missing from build metadata}"
  : "${IMAGE_TAG:?IMAGE_TAG missing from build metadata}"
  : "${IMAGE_URI:?IMAGE_URI missing from build metadata}"

  log INFO "Running Terraform deployment for ${IMAGE_URI}."

  terraform -chdir="$TF_DIR" init -input=false
  terraform -chdir="$TF_DIR" apply \
    -input=false \
    -auto-approve \
    -var="app_name=$APP_NAME" \
    -var="region=$AWS_REGION" \
    -var="image_tag=$IMAGE_TAG"

  log INFO "Deployment completed. Terraform outputs:"
  terraform -chdir="$TF_DIR" output
}

main "$@"
