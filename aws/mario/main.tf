terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Filter out local zones, which are not currently supported with managed node groups
data "aws_availability_zones" "available" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}


# Creating the Amazon EKS cluster role https://docs.aws.amazon.com/eks/latest/userguide/service_IAM_role.html#create-service-role
resource "aws_iam_role" "cluster" {
  name               = "eksClusterRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "cluster" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster.name
}

data "aws_vpc" "default" {
  default = true
}

# Only use subnets from available zones
data "aws_subnet_ids" "available" {
  vpc_id = data.aws_vpc.default.id
  count  = length(data.aws_availability_zones.available.names)
  filter {
    name   = "availabilityZone"
    values = [data.aws_availability_zones.available.names[count.index]]
  }
}

# Create a cluster using only available subnets
resource "aws_eks_cluster" "cluster" {
  name     = "mario-cluster"
  role_arn = aws_iam_role.cluster.arn

  vpc_config {
    subnet_ids = data.aws_subnet_ids.available[*].id
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [aws_iam_role_policy_attachment.cluster]
}

# Create the node IAM role https://docs.aws.amazon.com/eks/latest/userguide/create-node-role.html
resource "aws_iam_role" "node" {
  name               = "eksNodeRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# Attach two required IAM managed policies to the IAM role
resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node.name
}

# Attach one of the following IAM policies to the IAM role depending on which IP family you created your cluster with. 
resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node.name
}


# create node group
resource "aws_eks_node_group" "group" {
  cluster_name    = aws_eks_cluster.cluster.name
  node_group_name = "mario-group"
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = data.aws_subnets.public.ids

  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }

  instance_types = ["t2.micro"]

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
  ]
}

# Output as environment variables
output "eks_cluster_env_variables" {
  value = {
    EKS_CLUSTER_NAME         = aws_eks_cluster.cluster.name
    EKS_CLUSTER_KUBE_VERSION = aws_eks_cluster.cluster.version
    AWS_REGION               = var.aws_region
  }
}