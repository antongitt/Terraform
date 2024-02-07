# aws/mario
![mario](https://github.com/antongitt/Terraform/assets/91033128/d59dcc9c-1f2d-45fe-9d18-574e5818cd23)

In this fun project/example, you will deploy an EKS cluster running a [dockerized Super Mario game](https://github.com/kaminskypavel/supermario-docker) using Terraform and a couple of ```kubectl``` commands.

> [!WARNING]
> AWS EKS clusters cost $0.10 per hour, so you may incur charges by running this tutorial. The cost should be a few dollars at most, but be sure to delete your infrastructure promptly to avoid additional charges.

You can create a runner VM and attach IAM role to it, or you can simply use AWS CloudShell:
- Open the AWS Management Console.
- In the top-right corner, click on "CloudShell"
- Clone the repo:
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

Check the cluster events:
```bash
kubectl get events --sort-by=.metadata.creationTimestamp
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

# aws/backend
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
- Open the [Azure Portal](https://portal.azure.com/)
- In the top-right corner, click on "Cloud Shell"
- Make sure Bash is selected as the terminal shell
- Clone the repo:
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

# azure/backend
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