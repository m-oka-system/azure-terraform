################################
# Azure Functions
################################
resource "azurerm_linux_function_app" "this" {
  for_each                        = var.function
  name                            = "${var.common.prefix}-${var.common.env}-${each.value.name}"
  resource_group_name             = var.resource_group_name
  location                        = var.common.location
  service_plan_id                 = var.app_service_plan[each.value.target_service_plan].id
  virtual_network_subnet_id       = var.subnet[each.value.target_subnet].id
  storage_key_vault_secret_id     = var.key_vault_secret[each.value.target_key_vault_secret].id
  functions_extension_version     = each.value.functions_extension_version
  https_only                      = each.value.https_only
  public_network_access_enabled   = each.value.public_network_access_enabled
  builtin_logging_enabled         = each.value.builtin_logging_enabled
  key_vault_reference_identity_id = var.identity[each.value.target_user_assigned_identity].id

  identity {
    type = "UserAssigned"
    identity_ids = [
      var.identity[each.value.target_user_assigned_identity].id
    ]
  }

  app_settings = var.app_settings

  site_config {
    always_on                                     = each.value.site_config.always_on
    ftps_state                                    = each.value.site_config.ftps_state
    vnet_route_all_enabled                        = each.value.site_config.vnet_route_all_enabled
    scm_use_main_ip_restriction                   = each.value.site_config.scm_use_main_ip_restriction
    application_insights_connection_string        = var.application_insights[each.value.target_application_insights].connection_string
    container_registry_use_managed_identity       = each.value.site_config.container_registry_use_managed_identity
    container_registry_managed_identity_client_id = each.value.site_config.container_registry_use_managed_identity ? var.identity[each.value.target_user_assigned_identity].client_id : null

    dynamic "ip_restriction" {
      for_each = each.value.ip_restriction

      content {
        name        = ip_restriction.value.name
        priority    = ip_restriction.value.priority
        action      = ip_restriction.value.action
        ip_address  = lookup(ip_restriction.value, "ip_address", null) == "MyIP" ? join(",", [for ip in split(",", var.allowed_cidr) : "${ip}/32"]) : lookup(ip_restriction.value, "ip_address", null)
        service_tag = ip_restriction.value.service_tag
      }
    }

    dynamic "scm_ip_restriction" {
      for_each = each.value.scm_ip_restriction

      content {
        name        = scm_ip_restriction.value.name
        priority    = scm_ip_restriction.value.priority
        action      = scm_ip_restriction.value.action
        ip_address  = lookup(scm_ip_restriction.value, "ip_address", null) == "MyIP" ? join(",", [for ip in split(",", var.allowed_cidr) : "${ip}/32"]) : lookup(scm_ip_restriction.value, "ip_address", null)
        service_tag = scm_ip_restriction.value.service_tag
      }
    }

    application_stack {
      docker {
        # Initial container image (overwritten by CI/CD)
        registry_url = "https://mcr.microsoft.com"
        image_name   = "azure-functions/python"
        image_tag    = "4-python3.10"
      }
    }

    app_service_logs {
      disk_quota_mb         = each.value.app_service_logs.disk_quota_mb
      retention_period_days = each.value.app_service_logs.retention_period_days
    }
  }

  lifecycle {
    ignore_changes = [
      app_settings,
      site_config[0].application_stack,
      tags["hidden-link: /app-insights-conn-string"],
      tags["hidden-link: /app-insights-instrumentation-key"],
      tags["hidden-link: /app-insights-resource-id"],
    ]
  }
}

resource "azurerm_linux_function_app_slot" "this" {
  for_each                        = { for k, v in var.function : k => v if v.enable_deploy_slot }
  name                            = "staging"
  function_app_id                 = azurerm_linux_function_app.this[each.key].id
  virtual_network_subnet_id       = azurerm_linux_function_app.this[each.key].virtual_network_subnet_id
  storage_key_vault_secret_id     = azurerm_linux_function_app.this[each.key].storage_key_vault_secret_id
  functions_extension_version     = azurerm_linux_function_app.this[each.key].functions_extension_version
  https_only                      = azurerm_linux_function_app.this[each.key].https_only
  public_network_access_enabled   = azurerm_linux_function_app.this[each.key].public_network_access_enabled
  builtin_logging_enabled         = azurerm_linux_function_app.this[each.key].builtin_logging_enabled
  key_vault_reference_identity_id = azurerm_linux_function_app.this[each.key].key_vault_reference_identity_id

  identity {
    type = "UserAssigned"
    identity_ids = [
      var.identity[each.value.target_user_assigned_identity].id
    ]
  }

  app_settings = var.app_settings

  site_config {
    always_on                                     = azurerm_linux_function_app.this[each.key].site_config[0].always_on
    ftps_state                                    = azurerm_linux_function_app.this[each.key].site_config[0].ftps_state
    vnet_route_all_enabled                        = azurerm_linux_function_app.this[each.key].site_config[0].vnet_route_all_enabled
    scm_use_main_ip_restriction                   = azurerm_linux_function_app.this[each.key].site_config[0].scm_use_main_ip_restriction
    application_insights_connection_string        = azurerm_linux_function_app.this[each.key].site_config[0].application_insights_connection_string
    container_registry_use_managed_identity       = azurerm_linux_function_app.this[each.key].site_config[0].container_registry_use_managed_identity
    container_registry_managed_identity_client_id = azurerm_linux_function_app.this[each.key].site_config[0].container_registry_managed_identity_client_id

    application_stack {
      docker {
        # Initial container image (overwritten by CI/CD)
        registry_url = "https://mcr.microsoft.com"
        image_name   = "azure-functions/python"
        image_tag    = "4-python3.10"
      }
    }

    app_service_logs {
      disk_quota_mb         = azurerm_linux_function_app.this[each.key].site_config[0].app_service_logs[0].disk_quota_mb
      retention_period_days = azurerm_linux_function_app.this[each.key].site_config[0].app_service_logs[0].retention_period_days
    }
  }

  lifecycle {
    ignore_changes = [
      app_settings,
      site_config[0].application_stack,
      tags["hidden-link: /app-insights-conn-string"],
      tags["hidden-link: /app-insights-instrumentation-key"],
      tags["hidden-link: /app-insights-resource-id"],
    ]
  }
}
