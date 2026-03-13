#!/bin/bash

TAG="${BUILD_NUMBER}_prod"

REPO=123456789.dkr.ecr.ap-south-1.amazonaws.com/test-app

IMAGE="$REPO:$TAG"

echo "=============================="
echo "Building Docker Image"
echo "Tag = $TAG"
echo "ECR Image = $IMAGE"
echo "=============================="

docker build -t test-app .

aws ecr get-login-password --region ap-south-1 \
| docker login \
--username AWS \
--password-stdin 123456789.dkr.ecr.ap-south-1.amazonaws.com

docker tag test-app:latest $IMAGE

docker push $IMAGE

echo "=============================="
echo "PUSH SUCCESS"
echo "Use this in Terraform UI:"
echo "image_tag = $TAG"
echo "Full image = $IMAGE"
echo "=============================="