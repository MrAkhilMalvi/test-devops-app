#!/bin/bash

TAG="${BUILD_NUMBER}_prod"

REPO=692366125125.dkr.ecr.ap-south-1.amazonaws.com/test-app

echo "Tag = $TAG"

docker build -t test-app .

aws ecr get-login-password --region ap-south-1 \
| docker login \
--username AWS \
--password-stdin 692366125125.dkr.ecr.ap-south-1.amazonaws.com

docker tag test-app:latest $REPO:$TAG

docker push $REPO:$TAG