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

provider "http" {}

data "http" "ipify" {
  url = "http://api.ipify.org"
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

  common               = var.common
  resource_group_name  = module.resource_group.resource_group_name
  function             = var.function
  app_settings         = local.functions.app_settings
  app_service_plan     = module.app_service_plan.app_service_plan
  allowed_cidr         = var.allowed_cidr
  subnet               = module.network.subnet
  application_insights = module.application_insights.application_insights
  container_registry   = module.container_registry.container_registry
  identity             = module.user_assigned_identity.user_assigned_identity
  key_vault_secret     = module.key_vault_secret.key_vault_secret
}

module "container_registry" {
  source = "../../modules/container_registry"

  common              = var.common
  resource_group_name = module.resource_group.resource_group_name
  container_registry  = var.container_registry
}

module "user_assigned_identity" {
  source = "../../modules/user_assigned_identity"

  common                 = var.common
  resource_group_name    = module.resource_group.resource_group_name
  subscription_id        = local.common.subscription_id
  user_assigned_identity = var.user_assigned_identity
  role_assignment        = var.role_assignment
}

module "log_analytics" {
  source = "../../modules/log_analytics"

  common              = var.common
  resource_group_name = module.resource_group.resource_group_name
  log_analytics       = var.log_analytics
}

module "application_insights" {
  source = "../../modules/application_insights"

  common               = var.common
  resource_group_name  = module.resource_group.resource_group_name
  application_insights = var.application_insights
  log_analytics        = module.log_analytics.log_analytics
}

module "key_vault" {
  source = "../../modules/key_vault"

  common              = var.common
  resource_group_name = module.resource_group.resource_group_name
  key_vault           = var.key_vault
  allowed_cidr        = var.allowed_cidr
  client_ip_address   = local.common.client_ip_address
  tenant_id           = local.common.tenant_id
}

module "key_vault_secret" {
  source = "../../modules/key_vault_secret"

  key_vault        = module.key_vault.key_vault
  key_vault_secret = local.key_vault_secret
}
