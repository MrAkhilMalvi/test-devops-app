#!/usr/bin/env bash

set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="${BUILD_DIR:-$ROOT_DIR/build}"
METADATA_FILE="${METADATA_FILE:-$BUILD_DIR/image-metadata.env}"

APP_NAME="${APP_NAME:-test-app}"
AWS_REGION="${AWS_REGION:-ap-south-1}"
ENV_SUFFIX="${ENV_SUFFIX:-prod}"


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

next_tag_from_ecr() {
  local existing_tags max_value tag tag_number

  existing_tags="$(aws ecr list-images \
    --repository-name "$APP_NAME" \
    --region "$AWS_REGION" \
    --filter tagStatus=TAGGED \
    --query 'imageIds[*].imageTag' \
    --output text 2>/dev/null || true)"

  max_value=0
  for tag in $existing_tags; do
    if [[ "$tag" =~ ^([0-9]+)_${ENV_SUFFIX}$ ]]; then
      tag_number="${BASH_REMATCH[1]}"
      if (( tag_number > max_value )); then
        max_value=$tag_number
      fi
    fi
  done

  printf '%s_%s' "$((max_value + 1))" "$ENV_SUFFIX"
}

resolve_image_tag() {
  if [[ -n "${BUILD_NUMBER:-}" && "${BUILD_NUMBER}" =~ ^[0-9]+$ ]]; then
    printf '%s_%s' "$BUILD_NUMBER" "$ENV_SUFFIX"
    return
  fi

  next_tag_from_ecr
}

ensure_ecr_exists() {
  if aws ecr describe-repositories \
    --repository-names "$APP_NAME" \
    --region "$AWS_REGION" >/dev/null 2>&1; then
    log INFO "ECR repository already exists."
    return
  fi

  log INFO "ECR repository does not exist yet. Creating it with AWS CLI."
  aws ecr create-repository \
    --repository-name "$APP_NAME" \
    --region "$AWS_REGION" >/dev/null
}

write_metadata() {
  local account_id="$1"
  local repository_url="$2"
  local image_tag="$3"
  local image_uri="$4"

  mkdir -p "$BUILD_DIR"

  {
    printf 'APP_NAME=%q\n' "$APP_NAME"
    printf 'AWS_ACCOUNT_ID=%q\n' "$account_id"
    printf 'AWS_REGION=%q\n' "$AWS_REGION"
    printf 'ECR_REPOSITORY_URL=%q\n' "$repository_url"
    printf 'IMAGE_TAG=%q\n' "$image_tag"
    printf 'IMAGE_URI=%q\n' "$image_uri"
  } >"$METADATA_FILE"
}

main() {
  local account_id repository_url image_tag image_uri registry_url

  export TF_IN_AUTOMATION=1

  require_command aws
  require_command docker
  log INFO "Checking AWS CLI access and Docker availability."
  account_id="$(aws sts get-caller-identity --query 'Account' --output text)"
  docker info >/dev/null

  log INFO "Ensuring ECR exists."
  ensure_ecr_exists

  repository_url="$(aws ecr describe-repositories \
    --repository-names "$APP_NAME" \
    --region "$AWS_REGION" \
    --query 'repositories[0].repositoryUri' \
    --output text)"

  image_tag="$(resolve_image_tag)"
  image_uri="${repository_url}:${image_tag}"
  registry_url="${repository_url%%/*}"

  log INFO "Build details:"
  printf '  app_name     : %s\n' "$APP_NAME"
  printf '  aws_account  : %s\n' "$account_id"
  printf '  region       : %s\n' "$AWS_REGION"
  printf '  image_tag    : %s\n' "$image_tag"
  printf '  image_uri    : %s\n' "$image_uri"

  log INFO "Logging in to Amazon ECR."
  aws ecr get-login-password --region "$AWS_REGION" | docker login \
    --username AWS \
    --password-stdin "$registry_url"

  log INFO "Building Docker image."
  docker build --tag "${APP_NAME}:${image_tag}" "$ROOT_DIR"
  docker tag "${APP_NAME}:${image_tag}" "$image_uri"

  log INFO "Pushing Docker image to ECR."
  docker push "$image_uri"

  write_metadata "$account_id" "$repository_url" "$image_tag" "$image_uri"

  log INFO "Build phase completed successfully."
  printf '  metadata_file: %s\n' "$METADATA_FILE"
}

main "$@"
