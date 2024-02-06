#!/bin/bash

# Install Terraform
sudo yum update -y
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
sudo yum -y install terraform
# Verify the installation
terraform version

# Copy the variables file
cp -fr terraform.tfvars ../backend/terraform.tfvars

echo "Creating a remote backend with Terraform"
cd ../backend
echo "$PWD"
terraform init
terraform apply -auto-approve

echo "Creating Kubernetes Cluster with Terraform"
cd ../mario
echo "$PWD"
terraform init
terraform apply -auto-approve

# Install kubectl
sudo yum-config-manager --add-repo https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
sudo yum install -y kubectl
# Verify the installation
kubectl version --client

# Update the configuration to communicate with a particular cluster
az aks get-credentials --resource-group $(terraform output -raw rg_name) --name $(terraform output -raw cluster_name)

# You can now use kubectl to manage your cluster and deploy Kubernetes configurations to it.
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
kubectl get all
kubectl describe service mario-service
echo "Open this URL in your favorite browser: http://$(kubectl describe service mario-service | grep 'LoadBalancer Ingress' | awk '{print $3}')"