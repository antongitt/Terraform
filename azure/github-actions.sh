# bash script to prepare a user-assigned managed identity for Login with OIDC

# Define variables
PROJECT_NAME="mario"
LOCATION="eastus2"
SUBSCRIPTION="Visual Studio Professional Subscription"
GITHUB_REPO="antongitt/Terraform"

az account set --subscription "$SUBSCRIPTION"
az group create --name "$PROJECT_NAME-mi-rg" --location $LOCATION
az identity create --resource-group "$PROJECT_NAME-mi-rg" --name GitHub-mi
az role assignment create --assignee-object-id $(az identity show --resource-group "$PROJECT_NAME-mi-rg" --name GitHub-mi --query principalId --output tsv) --assignee-principal-type ServicePrincipal --role contributor --scope "/subscriptions/$(az account show --query id --output tsv)"
az identity federated-credential create --name "GitHubFederatedCredential" --identity-name "GitHub-mi" --resource-group "$PROJECT_NAME-mi-rg" --issuer "https://token.actions.githubusercontent.com" --subject "repo:${GITHUB_REPO}:environment:azure" --audiences "api://AzureADTokenExchange"