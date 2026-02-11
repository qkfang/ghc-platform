terraform {
  required_version = ">= 1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

  # backend "azurerm" {
  #   # Configure these values in your GitHub Actions secrets or backend config file
  #   # resource_group_name  = "tfstate-rg"
  #   # storage_account_name = "tfstateXXXXX"
  #   # container_name       = "tfstate"
  #   # key                  = "webapp.tfstate"
  # }
}

provider "azurerm" {
  features {}
  skip_provider_registration = true
  # use_msi = true  # Enable for managed identity in Azure environments
}
