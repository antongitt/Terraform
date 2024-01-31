# Set variables
aws_region="us-east-1"
s3_key="projects/mario/.tfstate"

# Create a S3 backend with Terraform
cd ../backend
terraform init
terraform plan -var="aws_region=$aws_region" -var="aws_region=$s3_key"
terraform apply -var="aws_region=$aws_region" -var="aws_region=$s3_key"
terraform output -json > output.json

# Create a new file named backend.tf
cd ../mario
echo 'terraform {' > backend.tf
echo '  backend "s3" {' >> backend.tf

# Read values from json file and append to backend.tf
jq -r '. | to_entries[] | "    \(.key) = \"\(.value)\""' output.json >> backend.tf

# Close the backend.tf file
echo '  }' >> backend.tf
echo '}' >> backend.tf

# Create EKS with Terraform
terraform init
terraform plan -var="aws_region=$aws_region"