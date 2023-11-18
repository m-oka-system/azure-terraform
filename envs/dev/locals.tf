locals {
  common = {
    subscription_id   = data.azurerm_subscription.primary.subscription_id
    tenant_id         = data.azurerm_subscription.primary.tenant_id
    random            = random_integer.num.result
    client_ip_address = chomp(data.http.ipify.response_body)
  }
}
