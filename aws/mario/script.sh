#!/bin/bash

# Install Terraform
sudo yum update -y
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
sudo yum -y install terraform
# Verify the installation
terraform version

# Set variables
echo 'project_name = "mario"' > ../backend/terraform.tfvars
echo 'aws_region   = "us-east-1"' >> ../backend/terraform.tfvars

echo "Creating a S3 backend with Terraform"
cd ../backend
echo "$PWD"
terraform init
terraform apply -auto-approve

echo "Creating EKS with Terraform"
cd ../mario
echo "$PWD"
terraform init
terraform apply -auto-approve

# Install kubectl
# Add Kubernetes repository
sudo yum-config-manager --add-repo https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
# Install kubectl with the specified version
sudo yum install -y kubectl
# Verify the installation
kubectl version --client

# Update the configuration to communicate with a particular cluster
aws eks update-kubeconfig --name ${EKS_CLUSTER_NAME} --region ${AWS_REGION}

kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
kubectl get all
kubectl describe service mario-service
kubectl describe service mario-service | grep "LoadBalancer Ingress"

# terraform destroy --auto-approve