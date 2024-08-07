# Define variables
GITHUB_REPO="antongitt/Terraform"

# Create OIDC provider
aws iam create-open-id-connect-provider --url "https://token.actions.githubusercontent.com" --client-id-list "sts.amazonaws.com"

# Retrieve OIDC provider ARN
OIDC_PROVIDER_ARN=$(aws iam list-open-id-connect-providers | jq -r '.OpenIDConnectProviderList[] | select(.Arn | contains("token.actions.githubusercontent.com")) | .Arn')

# Create IAM role with scoped trust policy
aws iam create-role --role-name GitHubActionsRole --assume-role-policy-document '{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "'"${OIDC_PROVIDER_ARN}"'"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com",
          "token.actions.githubusercontent.com:sub": "repo:'"${GITHUB_REPO}"':environment:aws"
        }
      }
    }
  ]
}'

# Create a custom IAM policy specifically for actions to manage the lifecycle of Amazon EKS clusters, node groups, and associated resources since AWS does not offer a managed policy for these actions
aws iam create-policy --policy-name EKSFullAccessPolicy --policy-document '{"Version":"2012-10-17","Statement":[{"Effect":"Allow","Action":["eks:*"],"Resource":"*"}]}'

# Attach policies to the role
aws iam attach-role-policy --role-name GitHubActionsRole --policy-arn arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess
aws iam attach-role-policy --role-name GitHubActionsRole --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess
aws iam attach-role-policy --role-name GitHubActionsRole --policy-arn arn:aws:iam::aws:policy/IAMFullAccess
aws iam attach-role-policy --role-name GitHubActionsRole --policy-arn arn:aws:iam::aws:policy/AmazonEC2FullAccess
aws iam attach-role-policy --role-name GitHubActionsRole --policy-arn arn:aws:iam::aws:policy/AmazonEKSClusterPolicy
aws iam attach-role-policy --role-name GitHubActionsRole --policy-arn arn:aws:iam::aws:policy/AmazonEKSServicePolicy
aws iam attach-role-policy --role-name GitHubActionsRole --policy-arn $(aws iam list-policies --query "Policies[?PolicyName=='EKSFullAccessPolicy'].Arn" --output text)

