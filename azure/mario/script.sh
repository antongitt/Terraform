#!/bin/bash

# Cloud Shell automatically updates to the latest version of Terraform. However, the updates come within a couple of weeks of release.
terraform version

echo
echo "Copying the variables file..."
cp -fr terraform.tfvars ../backend/terraform.tfvars

echo "Creating a remote backend with Terraform..."
cd ../backend
echo "$PWD"
terraform init
terraform apply -auto-approve

# Check if the container created
if [[ $(terraform output -raw container) == "" ]]; then
    echo "Remote backend was not created! Exiting script..."
    exit 1
fi

echo
echo "Creating Kubernetes cluster with Terraform..."
cd ../mario
echo "$PWD"
terraform init
terraform apply -auto-approve

echo "Getting access credentials for a managed Kubernetes cluster..."
az aks get-credentials --resource-group $(terraform output -raw rg_name) --name $(terraform output -raw cluster_name) --overwrite-existing

# You can now use kubectl to manage your cluster and deploy Kubernetes configurations to it.
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
kubectl get all
kubectl describe service mario-service

echo "Waiting for the external IP of the LoadBalancer to become available..."
kubectl wait --for=jsonpath='{.status.loadBalancer.ingress}' service/mario-service --timeout=300s
echo "Open this URL in your favorite browser: http://$(kubectl describe service mario-service | grep 'LoadBalancer Ingress' | awk '{print $3}')"