locals {

  # 特定の Azure リソースを作成する/しない
  aisearch_enabled = false

  common = {
    subscription_id   = data.azurerm_subscription.primary.subscription_id
    tenant_id         = data.azurerm_subscription.primary.tenant_id
    random            = random_integer.num.result
    allowed_cidr      = split(",", var.allowed_cidr)
    client_ip_address = chomp(data.http.ipify.response_body)
  }

  key_vault_secret = {
    target_key_vault = "app"
    secrets = {
      DOCKER_REGISTRY_SERVER_PASSWORD            = module.container_registry.container_registry["app"].admin_password
      DOCKER_REGISTRY_SERVER_USERNAME            = module.container_registry.container_registry["app"].admin_username
      FUNCTION_STORAGE_ACCOUNT_CONNECTION_STRING = module.storage.storage_account["function"].primary_connection_string
    }
  }

  functions = {
    app_settings = {
      FUNCTIONS_WORKER_RUNTIME            = "python"
      WEBSITES_ENABLE_APP_SERVICE_STORAGE = false
      WEBSITE_PULL_IMAGE_OVER_VNET        = true
      WEBSITE_HTTPLOGGING_RETENTION_DAYS  = var.function["function"].app_service_logs.retention_period_days
      DOCKER_REGISTRY_SERVER_URL          = "https://${module.container_registry.container_registry["app"].login_server}"
      DOCKER_REGISTRY_SERVER_USERNAME     = "@Microsoft.KeyVault(VaultName=${module.key_vault.key_vault["app"].name};SecretName=DOCKER-REGISTRY-SERVER-USERNAME)"
      DOCKER_REGISTRY_SERVER_PASSWORD     = "@Microsoft.KeyVault(VaultName=${module.key_vault.key_vault["app"].name};SecretName=DOCKER-REGISTRY-SERVER-PASSWORD)"
    }
  }
}
