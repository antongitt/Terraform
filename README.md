Terraform is a cloud-agnostic infrastructure provisioning tool. You can use Terraform's collection of providers to provision and compose resources from multiple cloud providers using the same infrastructure-as-code workflow. This allows you to create multi-cloud architectures without needing to manage cloud-specific implementations and tools.

In this fun project/example, you will provision Kubernetes clusters in Azure and AWS environments using their respective providers and managed Kubernetes services, deploy an image running a Super Mario game across the clusters, all using the same Terraform workflow.

# aws/mario
![mario](https://github.com/antongitt/Terraform/assets/91033128/d59dcc9c-1f2d-45fe-9d18-574e5818cd23)

In this fun project/example, you will deploy an EKS cluster running a [dockerized Super Mario game](https://github.com/kaminskypavel/supermario-docker) using Terraform and a couple of ```kubectl``` commands.

> [!WARNING]
> AWS EKS clusters cost $0.10 per hour, so you may incur charges by running this tutorial. The cost should be a few dollars at most, but be sure to delete your infrastructure promptly to avoid additional charges.

You can create a runner VM and attach IAM role to it, or you can simply use AWS CloudShell:
- Log in to the [AWS Management Console](https://console.aws.amazon.com/)
- In the top-right corner, click on [CloudShell](https://console.aws.amazon.com/cloudshell/)
- Clone this repository containing the example configuration:
```bash
git clone https://github.com/antongitt/Terraform.git
```
- Set your variables in ```Terraform/aws/mario/terraform.tfvars``` file:
```bash
nano Terraform/aws/mario/terraform.tfvars
```
- Run the script:
```bash
cd Terraform/aws/mario
chmod +x script.sh
./script.sh
```

That's it! Cluster creation could take up to 10 minutes.

Open URL from script output.

> [!TIP]
> In case of any issues, please check the cluster events. These events are retained for 1 hour by default:
> ```bash
> kubectl get events --sort-by=.metadata.creationTimestamp
> ```

When you are done playing, you could easily destroy the created infrastructure. Let's remove the service and deployment first:
```bash
kubectl delete service mario-service
kubectl delete deployment mario-deployment
```
Then destroy cluster and all its resources:
```bash
terraform destroy --auto-approve
```

## aws/backend
This Terraform helper configuration for other projects sets up the S3 bucket, DynamoDB table, and required IAM roles and policies for a Terraform backend on AWS. Additionally, it creates the backend file in a required format https://developer.hashicorp.com/terraform/language/settings/backends/s3

This configuration uses provisioned throughput for DynamoDB with low values that fall within the AWS Free Tier limits. The AWS Free Tier provides 25 read capacity units and 25 write capacity units per month for DynamoDB. Ensure that you review the AWS Free Tier limits to stay within the free tier usage.

Before applying this configuration, make sure that you have the AWS CLI configured with the necessary credentials.

To stage the configuration, run the following commands:
```bash
git clone https://github.com/antongitt/Terraform.git
cd Terraform/aws/backend/
```

The configuration requires the ```terraform.tfvars``` file with ```project``` and ```region``` variables, which can be set via CLI:
```bash
echo 'project = "mario"' > terraform.tfvars
echo 'region = "us-east-1"' >> terraform.tfvars
```

To apply the configuration, run the following commands:
```bash
terraform init
terraform apply -auto-approve
```
When you apply this Terraform configuration, it will create or modify the ```../${var.project}/backend.tf``` file. The file will contain the generated Terraform backend configuration based on the values of the specified resources and variables.


# azure/mario
In this fun project/example, you will deploy an AKS cluster running a [dockerized Super Mario game](https://github.com/kaminskypavel/supermario-docker) using Terraform and a couple of ```kubectl``` commands.

> [!NOTE]
> This project uses AKS Free tier which makes it easy to get started with a managed Kubernetes container orchestrator service in the most efficient and cost-effective way.

You can create a runner VM and attach IAM role to it, or you can simply use Azure Cloud Shell:
- Log in to the [Azure Portal](https://portal.azure.com/)
- In the top-right corner, click on "Cloud Shell"
- Make sure `Bash` is selected as the terminal shell
- Clone this repository containing the example configuration:
```bash
git clone https://github.com/antongitt/Terraform.git
```
- Set your variables in ```Terraform/azure/mario/terraform.tfvars``` file:
```bash
nano Terraform/azure/mario/terraform.tfvars
```
- Run the script:
```bash
cd Terraform/azure/mario
chmod +x script.sh
./script.sh
```

That's it! Cluster creation could take up to 10 minutes.

Open URL from the script output.

> [!TIP]
> In case of any issues, please check the cluster events. These events are retained for 1 hour by default:
> ```bash
> kubectl get events --sort-by=.metadata.creationTimestamp
> ```

When you are done playing, you could easily destroy the created infrastructure. Let's remove the service and deployment first:
```bash
kubectl delete service mario-service
kubectl delete deployment mario-deployment
```
Then destroy cluster and all its resources:
```bash
terraform destroy --auto-approve
```

## azure/backend
This Terraform helper configuration for other projects sets up the storage account and blob container for a remote Terraform backend on Azure. Additionally, it creates the backend file in a required format https://developer.hashicorp.com/terraform/language/settings/backends/azurerm

Before applying this configuration, make sure that you have the CLI configured with the necessary credentials.

To stage the configuration, run the following commands:
```bash
git clone https://github.com/antongitt/Terraform.git
cd Terraform/azure/backend/
```

The configuration requires the ```terraform.tfvars``` file with ```project```, ```region``` and ```subid``` variables, which can be set via CLI:
```bash
echo 'project = "mario"' > terraform.tfvars
echo 'region  = "eastus2"' >> terraform.tfvars
echo 'subid   = "00000000-0000-0000-0000-000000000000"' >> terraform.tfvars
```
> [!TIP]
> You can also list your subscriptions and view their IDs programmatically by using ```az account list --query '[].{SubscriptionName:name, SubscriptionId:id}' --output table``` command.

To apply the configuration, run the following commands:
```bash
terraform init
terraform apply -auto-approve
```
When you apply this Terraform configuration, it will create or modify the ```../${var.project}/backend.tf``` file. The file will contain the generated Terraform backend configuration based on the values of the specified resources and variables.


# GitHub Actions

GitHub Actions is an ideal platform for automating cloud deployments and infrastructure management tasks, such as provisioning and tearing down environments. By integrating workflows like you find in ```.github/workflows``` folder into your GitHub Actions, you can streamline your CI/CD process, ensuring that your infrastructure is consistently deployed and destroyed as needed.
Additionally, integrating cache management workflow ```caches-delete.yml``` helps keep your environments clean and efficient.

The ```github-actions.sh``` scripts set up the necessary cloud resources to allow GitHub Actions workflows to interact with cloud services.

## aws/github-actions.sh
- Log in to the [AWS Management Console](https://console.aws.amazon.com/)
- In the top-right corner, click on [CloudShell](https://console.aws.amazon.com/cloudshell/)
- Clone this repository containing the example configuration:
```bash
git clone https://github.com/antongitt/Terraform.git
```
- Set your variables in ```Terraform/aws/github-actions.sh``` file:
```bash
nano Terraform/aws/github-actions.sh
```
Define your GitHub repository that will use the IAM role: ```GITHUB_REPO="<your_org>/Terraform"```
- Run the script:
```bash
cd Terraform/aws/
chmod +x github-actions.sh
./github-actions.sh
```

The ```aws/github-actions.sh``` script will set up AWS resources for GitHub Actions workflows to securely interact with AWS based on the permissions granted:
- Creates an OIDC provider in AWS IAM for GitHub Actions to authenticate.
- Retrieves the ARN of the newly created OIDC provider.
- Creates an IAM role with a trust policy allowing GitHub Actions to assume it. 
- Creates a custom IAM policy for full access to Amazon EKS.
- Attaches managed and custom policies to the IAM role to grant necessary permissions for interacting with AWS services like DynamoDB, S3, IAM, EC2, and EKS.

## azure/github-actions.sh
- Log in to the [Azure Portal](https://portal.azure.com/)
- In the top-right corner, click on "Cloud Shell"
- Make sure `Bash` is selected as the terminal shell
- Clone this repository containing the example configuration:
```bash
git clone https://github.com/antongitt/Terraform.git
```
- Set your variables in ```Terraform/azure/github-actions.sh``` file:
```bash
nano Terraform/azure/github-actions.sh
```
Define the name for the resource group, Azure region where resources will be created, subscription to use and GitHub repository that will be allowed to use the managed identity:
```bash
PROJECT_NAME="mario"
LOCATION="<your_Azure_region>"
SUBSCRIPTION="<your_Azure_subscription>"
GITHUB_REPO="<your_account>/Terraform"
```
- Run the script:
```bash
cd Terraform/azure/
chmod +x github-actions.sh
./github-actions.sh
```

The ```azure/github-actions.sh``` will set up a user-assigned managed identity in Azure for GitHub Actions to authenticate and access Azure resources using OpenID Connect (OIDC):
- Sets the Azure subscription to use.
- Creates a resource group in the specified location.
- Creates a managed identity in the resource group.
- Assigns the Contributor role to the managed identity for managing Azure resources.
- Creates a federated credential to allow GitHub Actions to authenticate with Azure using OIDC.

## Set up GitHub environment and variables

To start using the workflows, fork this repository into your own GitHub account.

1. Create GitHub environments: ```aws``` and ```azure```.
   
2. Set up secrets and variables for workflows
   - For Azure, add 3 secrets to ```azure``` environment:
     - AZURE_CLIENT_ID
     - AZURE_SECRET
     - AZURE_TENANT_ID
   - For AWS, add 2 secrets to ```aws``` environment:
     - AWS_ACCESS_KEY_ID
     - AWS_SECRET_ACCESS_KEY
   - Additionally, add variables to ```aws``` environment:
     - AWS_REGION: The AWS region where your resources will be deployed (e.g., us-east-1).
     - AWS_GITHUB_ACTIONS_ROLE: Specifies an IAM role that you want to assume during the execution of a GitHub Actions workflow. IAM roles are used to grant permissions to entities (like users or services) without needing to share long-term access keys.
     - PROJECT_NAME: Name of the project (```mario```).

