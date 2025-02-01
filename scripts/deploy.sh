#!/bin/bash

# Variables
CLUSTER_NAME="lambda-cluster"
DOCKER_IMAGE="lambda-app"
DOCKER_USERNAME="gipeio"
LAMBDA_PORT="5432"

# Create k3d cluster with integrated docker registry
echo "Creating k3d cluster..."
k3d cluster create ${CLUSTER_NAME} \
    --registry-create ${CLUSTER_NAME}:5000 \
    -p "${LAMBDA_PORT}:${LAMBDA_PORT}@loadbalancer"

# Deploy app to kubernetes
echo "Deploying app to kubernetes..."
kubectl apply -f kubernetes/deployment.yaml
kubectl apply -f kubernetes/service.yaml

# Wait for deployment
echo "Waiting..."
kubectl wait --for=condition=available --timeout=120s deployment/lambda-app

echo "Finished!"