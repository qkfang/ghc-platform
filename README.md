# Azure Web App - Hello World

This repository deploys a Hello World Node.js application to Azure Web App using Terraform and GitHub Actions.

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      GitHub Actions                          │
│  ┌─────────────────┐         ┌─────────────────────────┐    │
│  │ Terraform Job   │────────▶│ Deploy Application Job  │    │
│  └─────────────────┘         └─────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                         Azure                                │
│  ┌─────────────────────────────────────────────────────┐    │
│  │              Resource Group                          │    │
│  │  ┌─────────────────┐    ┌─────────────────────┐     │    │
│  │  │ App Service     │    │  Linux Web App      │     │    │
│  │  │ Plan (B1)       │───▶│  (Node.js 18)       │     │    │
│  │  └─────────────────┘    └─────────────────────┘     │    │
│  └─────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
```

## Prerequisites

1. **Azure Subscription** with the following resources pre-created:
   - Storage Account for Terraform state
   - Container in the storage account for state files

2. **Azure AD App Registration** with:
   - Federated credentials configured for GitHub Actions (OIDC)
   - Contributor role on the subscription or resource group

3. **GitHub Repository** with the following secrets configured:
   - `AZURE_CLIENT_ID` - Azure AD App (Service Principal) Client ID
   - `AZURE_TENANT_ID` - Azure AD Tenant ID
   - `AZURE_SUBSCRIPTION_ID` - Azure Subscription ID
   - `TFSTATE_RESOURCE_GROUP` - Resource group containing the state storage account
   - `TFSTATE_STORAGE_ACCOUNT` - Storage account name for Terraform state
   - `TFSTATE_CONTAINER` - Container name for Terraform state

## Project Structure

```
.
├── .github/
│   └── workflows/
│       └── deploy.yml          # GitHub Actions workflow
├── app/
│   ├── package.json            # Node.js dependencies
│   └── server.js               # Hello World Express app
├── main.tf                     # Main Terraform resources
├── variables.tf                # Variable definitions
├── outputs.tf                  # Output definitions
├── providers.tf                # Provider configuration
├── terraform.tfvars.example    # Example variable values
├── .gitignore
└── README.md
```

## Quick Start

### 1. Set up Azure Prerequisites

```bash
# Login to Azure
az login

# Create resource group for Terraform state
az group create --name tfstate-rg --location eastus

# Create storage account (name must be globally unique)
az storage account create \
  --name tfstateYOURUNIQUENAME \
  --resource-group tfstate-rg \
  --sku Standard_LRS \
  --encryption-services blob

# Create container for state files
az storage container create \
  --name tfstate \
  --account-name tfstateYOURUNIQUENAME
```

### 2. Create Azure AD App Registration for GitHub Actions

```bash
# Create the app registration
az ad app create --display-name "GitHub Actions - Web App Deploy"

# Note the appId from the output, then create a service principal
az ad sp create --id <APP_ID>

# Assign Contributor role
az role assignment create \
  --assignee <APP_ID> \
  --role Contributor \
  --scope /subscriptions/<SUBSCRIPTION_ID>

# Add federated credential for GitHub Actions
az ad app federated-credential create \
  --id <APP_ID> \
  --parameters '{
    "name": "github-actions",
    "issuer": "https://token.actions.githubusercontent.com",
    "subject": "repo:<GITHUB_ORG>/<REPO_NAME>:environment:production",
    "audiences": ["api://AzureADTokenExchange"]
  }'
```

### 3. Configure GitHub Secrets

Add the following secrets to your GitHub repository (Settings → Secrets and variables → Actions):

| Secret Name | Description |
|-------------|-------------|
| `AZURE_CLIENT_ID` | App Registration Client ID |
| `AZURE_TENANT_ID` | Azure AD Tenant ID |
| `AZURE_SUBSCRIPTION_ID` | Azure Subscription ID |
| `TFSTATE_RESOURCE_GROUP` | Resource group with state storage (e.g., `tfstate-rg`) |
| `TFSTATE_STORAGE_ACCOUNT` | Storage account name |
| `TFSTATE_CONTAINER` | Container name (e.g., `tfstate`) |

### 4. Create GitHub Environment

1. Go to Settings → Environments → New environment
2. Create an environment named `production`
3. Optionally configure protection rules

### 5. Customize Variables

Copy `terraform.tfvars.example` to `terraform.tfvars` and update values:

```bash
cp terraform.tfvars.example terraform.tfvars
```

**Important:** Change `app_service_name` to a globally unique name.

### 6. Deploy

Push to the `main` branch to trigger deployment:

```bash
git add .
git commit -m "Initial deployment"
git push origin main
```

## Local Development

### Run the app locally

```bash
cd app
npm install
npm start
```

Open http://localhost:3000 in your browser.

### Test Terraform locally

```bash
# Initialize Terraform
terraform init

# Format check
terraform fmt -check

# Validate configuration
terraform validate

# Plan changes
terraform plan

# Apply changes
terraform apply
```

## Workflow Details

The GitHub Actions workflow:

1. **On Pull Request**: Runs `terraform plan` to show proposed changes
2. **On Push to main**: 
   - Runs `terraform apply` to create/update infrastructure
   - Deploys the Node.js application to the Web App

## Customization

### Change App Service SKU

Edit `terraform.tfvars`:

```hcl
app_service_sku = "P1v2"  # Options: F1, B1, B2, B3, S1, S2, S3, P1v2, P2v2, P3v2
```

### Change Region

Edit `terraform.tfvars`:

```hcl
location = "westus2"
```

### Modify the Application

Edit files in the `app/` directory. The application is a simple Express.js server.

## Cleanup

To destroy all resources:

```bash
terraform destroy
```

Or run the destroy workflow (if configured).

## License

MIT
