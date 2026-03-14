#!/usr/bin/env bash

set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TF_DIR="${TF_DIR:-$ROOT_DIR/terraform}"
BUILD_DIR="${BUILD_DIR:-$ROOT_DIR/build}"
METADATA_FILE="${METADATA_FILE:-$BUILD_DIR/image-metadata.env}"

APP_NAME="${APP_NAME:-test-app}"
AWS_REGION="${AWS_REGION:-ap-south-1}"

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

load_metadata_if_present() {
  if [[ -f "$METADATA_FILE" ]]; then
    # shellcheck disable=SC1090
    source "$METADATA_FILE"
  fi
}

main() {
  export TF_IN_AUTOMATION=1

  require_command terraform

  load_metadata_if_present

  log INFO "Destroying Terraform resources for app=${APP_NAME} region=${AWS_REGION}."
  terraform -chdir="$TF_DIR" init -input=false
  terraform -chdir="$TF_DIR" destroy \
    -input=false \
    -auto-approve \
    -var="app_name=$APP_NAME" \
    -var="region=$AWS_REGION"

  log INFO "All Terraform-managed resources have been destroyed."
}

main "$@"
