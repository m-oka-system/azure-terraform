################################
# Azure AI Search
################################
resource "azurerm_search_service" "this" {
  for_each                      = var.aisearch
  name                          = "${var.common.prefix}-${var.common.env}-${each.value.name}"
  resource_group_name           = var.resource_group_name
  location                      = var.common.location
  sku                           = each.value.sku
  semantic_search_sku           = each.value.semantic_search_sku
  partition_count               = each.value.partition_count
  replica_count                 = each.value.replica_count
  public_network_access_enabled = each.value.public_network_access_enabled
  allowed_ips                   = var.allowed_cidr
}
