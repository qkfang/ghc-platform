variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "hello-world-webapp-rg"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "eastus"
}

variable "app_service_plan_name" {
  description = "Name of the App Service Plan"
  type        = string
  default     = "hello-world-asp"
}

variable "app_service_name" {
  description = "Name of the Web App (must be globally unique)"
  type        = string
  default     = "hello-world-webapp"
}

variable "app_service_sku" {
  description = "SKU for the App Service Plan"
  type        = string
  default     = "B1"
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}
