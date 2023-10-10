locals {
  common = {
    subscription_id = data.azurerm_subscription.primary.subscription_id
    tenant_id       = data.azurerm_subscription.primary.tenant_id
    random          = random_integer.num.result
  }
}
