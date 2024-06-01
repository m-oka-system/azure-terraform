################################
# Azure OpenAI Service
################################
resource "azurerm_cognitive_account" "this" {
  for_each              = var.openai
  name                  = "${var.common.prefix}-${var.common.env}-${each.value.name}"
  resource_group_name   = var.resource_group_name
  location              = each.value.location
  kind                  = each.value.kind
  sku_name              = each.value.sku_name
  custom_subdomain_name = "${var.common.prefix}-${var.common.env}-${each.value.name}"

  network_acls {
    default_action = each.value.network_acls.default_action
    ip_rules       = var.allowed_cidr
  }
}

resource "azurerm_cognitive_deployment" "this" {
  for_each               = var.openai_deployment
  name                   = each.value.name
  cognitive_account_id   = azurerm_cognitive_account.this[each.value.target_openai].id
  version_upgrade_option = each.value.version_upgrade_option

  model {
    format  = "OpenAI"
    name    = each.value.model.name
    version = each.value.model.version
  }

  scale {
    type     = each.value.scale.type
    capacity = each.value.scale.capacity
  }
}
