resource "azurerm_linux_function_app" "this" {
  for_each                      = var.function
  name                          = "${var.common.prefix}-${var.common.env}-${each.value.name}"
  resource_group_name           = var.resource_group_name
  location                      = var.common.location
  service_plan_id               = var.app_service_plan[each.value.target_service_plan].id
  virtual_network_subnet_id     = var.subnet[each.value.target_subnet].id
  storage_account_name          = var.storage_account[each.value.target_storage_account].name
  storage_account_access_key    = var.storage_account[each.value.target_storage_account].primary_access_key
  functions_extension_version   = each.value.functions_extension_version
  https_only                    = each.value.https_only
  public_network_access_enabled = each.value.public_network_access_enabled

  app_settings = {
    "AzureWebJobsFeatureFlags"       = "EnableWorkerIndexing"
    "BUILD_FLAGS"                    = "UseExpressBuild"
    "ENABLE_ORYX_BUILD"              = "true"
    "SCM_DO_BUILD_DURING_DEPLOYMENT" = "1"
    "XDG_CACHE_HOME"                 = "/tmp"
  }

  site_config {
    always_on                   = each.value.site_config.always_on
    ftps_state                  = each.value.site_config.ftps_state
    vnet_route_all_enabled      = each.value.site_config.vnet_route_all_enabled
    scm_use_main_ip_restriction = each.value.site_config.scm_use_main_ip_restriction
    # application_insights_connection_string = ""
    # application_insights_key               = ""

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
      python_version = each.value.python_version
    }
  }
}
