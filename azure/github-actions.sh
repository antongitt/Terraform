# bash script to prepare a user-assigned managed identity for Login with OIDC

# Define variables
PROJECT_NAME="mario"
LOCATION="eastus2"
SUBSCRIPTION="Visual Studio Professional Subscription"
GITHUB_REPO="antongitt/Terraform"

az account set --subscription "$SUBSCRIPTION"
az group create --name "$PROJECT_NAME-rg" --location $LOCATION
az identity create --resource-group "$PROJECT_NAME-rg" --name GitHub-mi
az role assignment create --assignee-object-id $(az identity show --resource-group "$PROJECT_NAME-rg" --name GitHub-mi --query principalId --output tsv) --assignee-principal-type ServicePrincipal --role contributor --scope "/subscriptions/$(az account show --query id --output tsv)/resourceGroups/$PROJECT_NAME-rg"
az identity federated-credential create --name "GitHubFederatedCredential" --identity-name "GitHub-mi" --resource-group "$PROJECT_NAME-rg" --issuer "https://token.actions.githubusercontent.com" --subject "repo:${GITHUB_REPO}:environment:azure" --audiences "api://AzureADTokenExchange"