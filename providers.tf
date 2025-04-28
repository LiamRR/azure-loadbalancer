# We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.1.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
  # Can be found here ~ az account list | grep tenantId
  tenant_id = "e0db078b-c381-439d-825c-5c949b0a0911"
  # Can be found here ~ https://portal.azure.com/#view/Microsoft_Azure_Billing/SubscriptionsBladeV2
  subscription_id = "e37e02ad-a7fc-481d-b432-1931018a80b2"
}
