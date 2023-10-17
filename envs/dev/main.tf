terraform {
  required_version = "~> 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.75.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5.1"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

data "azurerm_subscription" "primary" {}

resource "random_integer" "num" {
  min = 1000
  max = 9999
}

module "resource_group" {
  source = "../../modules/resource_group"

  common = var.common
}

module "network" {
  source = "../../modules/network"

  common              = var.common
  resource_group_name = module.resource_group.resource_group_name
  network             = var.network
  subnet              = var.subnet
}

module "network_security_group" {
  source = "../../modules/network_security_group"

  common                 = var.common
  resource_group_name    = module.resource_group.resource_group_name
  network_security_group = var.network_security_group
  subnet                 = module.network.subnet
  allowed_cidr           = var.allowed_cidr
}

module "storage" {
  source = "../../modules/storage"

  common              = var.common
  resource_group_name = module.resource_group.resource_group_name
  random              = local.common.random
  storage             = var.storage
  blob_container      = var.blob_container
  allowed_cidr        = var.allowed_cidr
}

module "app_service_plan" {
  source = "../../modules/app_service_plan"

  common              = var.common
  resource_group_name = module.resource_group.resource_group_name
  app_service_plan    = var.app_service_plan
}

module "function" {
  source = "../../modules/function"

  common              = var.common
  resource_group_name = module.resource_group.resource_group_name
  function            = var.function
  allowed_cidr        = var.allowed_cidr
  app_service_plan    = module.app_service_plan.app_service_plan
  subnet              = module.network.subnet
  storage_account     = module.storage.storage_account
}

module "log_analytics" {
  source = "../../modules/log_analytics"

  common              = var.common
  resource_group_name = module.resource_group.resource_group_name
  log_analytics       = var.log_analytics
}
