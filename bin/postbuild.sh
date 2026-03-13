#!/bin/bash

TAG="${BUILD_NUMBER}_prod"

echo "Using tag $TAG"

cd terraform

terraform init

terraform apply \
  -var="image_tag=$TAG" \
  -auto-approve