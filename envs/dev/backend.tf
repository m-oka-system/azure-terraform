terraform {
  backend "azurerm" {
    resource_group_name  = "terraform-state-rg"
    storage_account_name = "azurermtfstate"
    container_name       = "terraform-state"
    key                  = "dev.terraform.tfstate"
  }
}
