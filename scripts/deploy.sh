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

# Install Helm if not already installed
echo "Installing Helm..."
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Add Prometheus and Grafana Helm repositories
echo "Adding Helm repositories..."
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

# Install Prometheus
echo "Installing Prometheus..."
helm install prometheus prometheus-community/prometheus \
  --namespace monitoring \
  --create-namespace

# Install Grafana
echo "Installing Grafana..."
helm install grafana grafana/grafana \
  --namespace monitoring \
  --set persistence.enabled=false

# Deploy app to kubernetes
echo "Deploying app to kubernetes..."
kubectl apply -f kubernetes/deployment.yaml
kubectl apply -f kubernetes/service.yaml

# Wait for deployment
echo "Waiting for deployment to be ready..."
kubectl wait --for=condition=available --timeout=120s deployment/lambda-app

# Expose Grafana via port-forward (in background)
echo "Exposing Grafana on port 3000..."
kubectl port-forward -n monitoring service/grafana 3000:80 &

# Wait for Grafana to be ready
echo "Waiting for Grafana to be ready..."
until curl -s http://localhost:3000/api/health; do
  echo "Grafana is not ready yet. Retrying in 5 seconds..."
  sleep 5
done

# Get Grafana admin password
GRAFANA_ADMIN_PASSWORD=$(kubectl get secret --namespace monitoring grafana -o jsonpath="{.data.admin-password}" | base64 --decode)

# Configure Grafana automatically
echo "Configuring Grafana..."

# Add Prometheus as a data source
curl -X POST -H "Content-Type: application/json" \
  -d '{
        "name": "Prometheus",
        "type": "prometheus",
        "url": "http://prometheus-server.monitoring.svc.cluster.local:80",
        "access": "proxy",
        "basicAuth": false
      }' \
  http://admin:${GRAFANA_ADMIN_PASSWORD}@localhost:3000/api/datasources

# Import Kubernetes dashboard
curl -X POST -H "Content-Type: application/json" \
  -d '{
        "dashboard": {
          "id": null,
          "uid": null,
          "title": "Kubernetes Cluster Monitoring",
          "timezone": "browser",
          "schemaVersion": 16,
          "version": 0,
          "refresh": "25s"
        },
        "folderId": 0,
        "overwrite": false,
        "inputs": [
          {
            "name": "DS_PROMETHEUS",
            "type": "datasource",
            "pluginId": "prometheus",
            "value": "Prometheus"
          }
        ]
      }' \
  http://admin:${GRAFANA_ADMIN_PASSWORD}@localhost:3000/api/dashboards/import

# Display Grafana access information
echo "Grafana is now available at http://localhost:3000"
echo "Username: admin"
echo "Password: ${GRAFANA_ADMIN_PASSWORD}"

echo "Finished!"