#!/bin/bash

# Install Terraform
sudo yum update -y
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
sudo yum -y install terraform
# Verify the installation
terraform version

echo "Copying the variables file..."
cp -fr terraform.tfvars ../backend/terraform.tfvars

echo "Creating a remote backend with Terraform..."
cd ../backend
echo "$PWD"
terraform init
terraform apply -auto-approve

# Check if the bucket created
if [[ $(terraform output -raw bucket) == "" ]]; then
    echo "Remote backend was not created! Exiting script..."
    exit 1
fi

echo "Creating Kubernetes cluster with Terraform..."
cd ../mario
echo "$PWD"
terraform init
terraform apply -auto-approve

echo "Installing kubectl..."
sudo yum-config-manager --add-repo https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
sudo yum install -y kubectl
# Verify the installation
kubectl version --client

echo "Updating configuration to communicate with the cluster..."
aws eks --region $(terraform output -raw region) update-kubeconfig --name $(terraform output -raw cluster_name)

# You can now use kubectl to manage your cluster and deploy Kubernetes configurations to it.
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
kubectl get all
kubectl describe service mario-service

echo "Waiting for the external IP of the LoadBalancer to become available..."
kubectl wait --for=jsonpath='{.status.loadBalancer.ingress}' service/mario-service
echo "Open this URL in your favorite browser: http://$(kubectl get service mario-service -o=jsonpath='{.status.loadBalancer.ingress[0].ip}')"