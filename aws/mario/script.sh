# Set variables
echo 'project_name = "mario"' > ../backend/terraform.tfvars
echo 'aws_region   = "us-east-1"' >> ../backend/terraform.tfvars

echo "Creating a S3 backend with Terraform"
cd ../backend
echo "$PWD"
terraform init
terraform plan
terraform apply 

echo "Creating EKS with Terraform"
cd ../mario
echo "$PWD"
terraform init
terraform plan
#terraform apply