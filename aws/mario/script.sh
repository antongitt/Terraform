#!/bin/bash

# Install Terraform
sudo yum update -y
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
sudo yum -y install terraform
# Verify the installation
terraform version

echo
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

echo
echo "Creating Kubernetes cluster with Terraform..."
cd ../mario
echo "$PWD"
terraform init
terraform apply -auto-approve

echo "Installing the latest stable version of kubectl..."
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
kubectl version --client

echo
echo "Updating configuration to communicate with the cluster..."
aws eks --region $(terraform output -raw region) update-kubeconfig --name $(terraform output -raw cluster_name)

# If you are trying to access the EKS cluster as a non-creator (e.g., cluster was created with GitHub Actions), you might face access issues. To resolve this, run the commands below::
#aws eks update-cluster-config --name mario-cluster --access-config authenticationMode=API_AND_CONFIG_MAP
#aws eks create-access-entry --cluster-name mario-cluster --principal-arn $(aws sts get-caller-identity --query 'Arn' --output text) --type STANDARD
#aws eks associate-access-policy --cluster-name mario-cluster --principal-arn $(aws sts get-caller-identity --query 'Arn' --output text) --access-scope type=cluster --policy-arn arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy

# You can now use kubectl to manage your cluster and deploy Kubernetes configurations to it.
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
kubectl get all
kubectl describe service mario-service
echo
echo "Waiting for the external hostname of the LoadBalancer to become available..."
kubectl wait --for=jsonpath='{.status.loadBalancer.ingress[0].hostname}' service/mario-service --timeout=300s
echo
echo "Open this URL in your favorite browser: http://$(kubectl get service mario-service -o=jsonpath='{.status.loadBalancer.ingress[0].hostname}')"