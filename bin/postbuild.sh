#!/bin/bash

TAG="${BUILD_NUMBER}_prod"

cd terraform

terraform init

terraform apply \
-var="image_tag=$TAG" \
-auto-approve