locals {
  common = {
    subscription_id   = data.azurerm_subscription.primary.subscription_id
    tenant_id         = data.azurerm_subscription.primary.tenant_id
    random            = random_integer.num.result
    client_ip_address = chomp(data.http.ipify.response_body)
  }

  key_vault_secret = {
    target_key_vault = "app"
    secrets = {
      DOCKER_REGISTRY_SERVER_URL                 = "https://${module.container_registry.container_registry["app"].login_server}"
      DOCKER_REGISTRY_SERVER_PASSWORD            = module.container_registry.container_registry["app"].admin_password
      DOCKER_REGISTRY_SERVER_USERNAME            = module.container_registry.container_registry["app"].admin_username
      FUNCTION_STORAGE_ACCOUNT_CONNECTION_STRING = module.storage.storage_account["function"].primary_connection_string
    }
  }
}
