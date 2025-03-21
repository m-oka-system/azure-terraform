variable "common" {
  type = map(string)
  default = {
    prefix   = "terraform"
    env      = "dev"
    location = "japaneast"
  }
}

variable "allowed_cidr" {
  type = string
}

variable "vnet" {
  type = map(object({
    name          = string
    address_space = list(string)
  }))
  default = {
    spoke1 = {
      name          = "spoke1"
      address_space = ["10.10.0.0/16"]
    }
  }
}

variable "subnet" {
  type = map(object({
    name                              = string
    target_vnet                       = string
    address_prefixes                  = list(string)
    private_endpoint_network_policies = string
    service_delegation = object({
      name    = string
      actions = list(string)
    })
  }))
  default = {
    pe = {
      name                              = "pe"
      target_vnet                       = "spoke1"
      address_prefixes                  = ["10.10.0.0/24"]
      private_endpoint_network_policies = "Enabled"
      service_delegation                = null
    }
    app = {
      name                              = "app"
      target_vnet                       = "spoke1"
      address_prefixes                  = ["10.10.1.0/24"]
      private_endpoint_network_policies = "Disabled"
      service_delegation = {
        name    = "Microsoft.Web/serverFarms"
        actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
      }
    }
    function = {
      name                              = "function"
      target_vnet                       = "spoke1"
      address_prefixes                  = ["10.10.2.0/24"]
      private_endpoint_network_policies = "Disabled"
      service_delegation = {
        name    = "Microsoft.Web/serverFarms"
        actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
      }
    }
    db = {
      name                              = "db"
      target_vnet                       = "spoke1"
      address_prefixes                  = ["10.10.3.0/24"]
      private_endpoint_network_policies = "Disabled"
      service_delegation = {
        name    = "Microsoft.DBforMySQL/flexibleServers"
        actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
      }
    }
    vm = {
      name                              = "vm"
      target_vnet                       = "spoke1"
      address_prefixes                  = ["10.10.4.0/24"]
      private_endpoint_network_policies = "Disabled"
      service_delegation                = null
    }
  }
}

variable "network_security_group" {
  type = map(object({
    name          = string
    target_subnet = string
    security_rule = list(object({
      name                       = string
      priority                   = number
      direction                  = string
      access                     = string
      protocol                   = string
      source_port_range          = string
      destination_port_range     = string
      source_address_prefix      = optional(string)
      source_address_prefixes    = optional(list(string))
      destination_address_prefix = string
    }))
  }))
  default = {
    pe = {
      name          = "pe"
      target_subnet = "pe"
      security_rule = []
    }
    app = {
      name          = "app"
      target_subnet = "app"
      security_rule = []
    }
    function = {
      name          = "function"
      target_subnet = "function"
      security_rule = []
    }
    db = {
      name          = "db"
      target_subnet = "db"
      security_rule = []
    }
    vm = {
      name          = "vm"
      target_subnet = "vm"
      security_rule = [
        {
          name                       = "AllowMyIpAddressHTTPInbound"
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "80"
          source_address_prefixes    = ["MyIP"]
          destination_address_prefix = "*"
        },
        {
          name                       = "AllowMyIpAddressHTTPSInbound"
          priority                   = 110
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "443"
          source_address_prefixes    = ["MyIP"]
          destination_address_prefix = "*"
        },
        {
          name                       = "AllowMyIpAddressSSHInbound"
          priority                   = 120
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "22"
          source_address_prefixes    = ["MyIP"]
          destination_address_prefix = "*"
        },
        {
          name                       = "AllowMyIpAddressRDPInbound"
          priority                   = 130
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "3389"
          source_address_prefixes    = ["MyIP"]
          destination_address_prefix = "*"
        }
      ]
    }
  }
}

variable "storage" {
  type = map(object({
    name                          = string
    account_tier                  = string
    account_kind                  = string
    account_replication_type      = string
    access_tier                   = string
    enable_https_traffic_only     = bool
    public_network_access_enabled = bool
    is_hns_enabled                = bool
    blob_properties = object({
      versioning_enabled                = bool
      change_feed_enabled               = bool
      last_access_time_enabled          = bool
      delete_retention_policy           = number
      container_delete_retention_policy = number
    })
    network_rules = object({
      default_action             = string
      bypass                     = list(string)
      ip_rules                   = list(string)
      virtual_network_subnet_ids = list(string)
    })
  }))
  default = {
    app = {
      name                          = "app"
      account_tier                  = "Standard"
      account_kind                  = "StorageV2"
      account_replication_type      = "LRS"
      access_tier                   = "Hot"
      enable_https_traffic_only     = true
      public_network_access_enabled = true
      is_hns_enabled                = false
      blob_properties = {
        versioning_enabled                = false
        change_feed_enabled               = false
        last_access_time_enabled          = false
        delete_retention_policy           = 7
        container_delete_retention_policy = 7
      }
      network_rules = {
        default_action             = "Allow"
        bypass                     = ["AzureServices"]
        ip_rules                   = []
        virtual_network_subnet_ids = []
      }
    }
    function = {
      name                          = "function"
      account_tier                  = "Standard"
      account_kind                  = "StorageV2"
      account_replication_type      = "LRS"
      access_tier                   = "Hot"
      enable_https_traffic_only     = true
      public_network_access_enabled = true
      is_hns_enabled                = false
      blob_properties = {
        versioning_enabled                = false
        change_feed_enabled               = false
        last_access_time_enabled          = false
        delete_retention_policy           = 7
        container_delete_retention_policy = 7
      }
      network_rules = {
        default_action             = "Deny"
        bypass                     = ["AzureServices"]
        ip_rules                   = ["MyIP"]
        virtual_network_subnet_ids = []
      }
    }
    log = {
      name                          = "log"
      account_tier                  = "Standard"
      account_kind                  = "StorageV2"
      account_replication_type      = "LRS"
      access_tier                   = "Hot"
      enable_https_traffic_only     = true
      public_network_access_enabled = true
      is_hns_enabled                = false
      blob_properties = {
        versioning_enabled                = false
        change_feed_enabled               = false
        last_access_time_enabled          = false
        delete_retention_policy           = 7
        container_delete_retention_policy = 7
      }
      network_rules = {
        default_action             = "Deny"
        bypass                     = ["AzureServices"]
        ip_rules                   = ["MyIP"]
        virtual_network_subnet_ids = []
      }
    }
  }
}

variable "blob_container" {
  type = map(map(string))
  default = {
    app_static = {
      storage_account_key   = "app"
      container_name        = "static"
      container_access_type = "blob"
    }
    app_media = {
      storage_account_key   = "app"
      container_name        = "media"
      container_access_type = "blob"
    }
  }
}

variable "app_service_plan" {
  type = map(map(string))
  default = {
    function = {
      name     = "function"
      os_type  = "Linux"
      sku_name = "B1"
    }
  }
}

variable "function" {
  type = map(object({
    name                          = string
    target_service_plan           = string
    target_subnet                 = string
    target_user_assigned_identity = string
    target_key_vault_secret       = string
    target_user_assigned_identity = string
    target_application_insights   = string
    functions_extension_version   = string
    https_only                    = bool
    public_network_access_enabled = bool
    builtin_logging_enabled       = bool
    enable_deploy_slot            = bool
    site_config = object({
      always_on                               = bool
      ftps_state                              = string
      vnet_route_all_enabled                  = bool
      scm_use_main_ip_restriction             = bool
      container_registry_use_managed_identity = bool
    })
    ip_restriction = map(object({
      name        = string
      priority    = number
      action      = string
      ip_address  = string
      service_tag = string
    }))
    scm_ip_restriction = map(object({
      name        = string
      priority    = number
      action      = string
      ip_address  = string
      service_tag = string
    }))
    app_service_logs = object({
      disk_quota_mb         = number
      retention_period_days = number
    })
  }))
  default = {
    function = {
      name                          = "function"
      target_service_plan           = "function"
      target_subnet                 = "function"
      target_user_assigned_identity = "function"
      target_key_vault_secret       = "FUNCTION_STORAGE_ACCOUNT_CONNECTION_STRING"
      target_user_assigned_identity = "function"
      target_application_insights   = "function"
      functions_extension_version   = "~4"
      https_only                    = true
      public_network_access_enabled = true
      builtin_logging_enabled       = false
      enable_deploy_slot            = false
      site_config = {
        always_on                               = true
        ftps_state                              = "Disabled"
        vnet_route_all_enabled                  = true
        scm_use_main_ip_restriction             = false
        container_registry_use_managed_identity = true
      }
      ip_restriction = {
        myip = {
          name        = "AllowMyIP"
          priority    = 100
          action      = "Allow"
          ip_address  = "MyIP"
          service_tag = null
        }
      }
      scm_ip_restriction = {
        devops = {
          name        = "AllowDevOps"
          priority    = 100
          action      = "Allow"
          ip_address  = null
          service_tag = "AzureCloud"
        }
        myip = {
          name        = "AllowMyIP"
          priority    = 200
          action      = "Allow"
          ip_address  = "MyIP"
          service_tag = null
        }
      }
      app_service_logs = {
        disk_quota_mb         = 35
        retention_period_days = 7
      }
    }
  }
}

variable "container_registry" {
  type = map(object({
    sku_name                      = string
    admin_enabled                 = bool
    public_network_access_enabled = bool
    zone_redundancy_enabled       = bool
  }))
  default = {
    app = {
      sku_name                      = "Basic"
      admin_enabled                 = false
      public_network_access_enabled = true
      zone_redundancy_enabled       = false
    }
  }
}

variable "user_assigned_identity" {
  type = map(object({
    name = string
  }))
  default = {
    app = {
      name = "app"
    }
    function = {
      name = "function"
    }
  }
}

variable "role_assignment" {
  type = map(object({
    target_identity      = string
    role_definition_name = string
  }))
  default = {
    app_acr_pull = {
      target_identity      = "app"
      role_definition_name = "AcrPull"
    }
    app_key_vault_secrets_user = {
      target_identity      = "app"
      role_definition_name = "Key Vault Secrets User"
    }
    app_storage_blob_data_contributor = {
      target_identity      = "app"
      role_definition_name = "Storage Blob Data Contributor"
    }
    function_acr_pull = {
      target_identity      = "function"
      role_definition_name = "AcrPull"
    }
    function_key_vault_secrets_user = {
      target_identity      = "function"
      role_definition_name = "Key Vault Secrets User"
    }
  }
}

variable "log_analytics" {
  type = map(object({
    sku                        = string
    retention_in_days          = number
    internet_ingestion_enabled = bool
    internet_query_enabled     = bool
  }))
  default = {
    logs = {
      sku                        = "PerGB2018"
      retention_in_days          = 30
      internet_ingestion_enabled = false
      internet_query_enabled     = true
    }
  }
}

variable "application_insights" {
  type = map(object({
    name                       = string
    application_type           = string
    target_workspace           = string
    retention_in_days          = number
    internet_ingestion_enabled = bool
    internet_query_enabled     = bool
  }))
  default = {
    app = {
      name                       = "app"
      target_workspace           = "logs"
      application_type           = "web"
      retention_in_days          = 90
      internet_ingestion_enabled = false
      internet_query_enabled     = true
    }
    function = {
      name                       = "function"
      target_workspace           = "logs"
      application_type           = "web"
      retention_in_days          = 90
      internet_ingestion_enabled = false
      internet_query_enabled     = true
    }
  }
}

variable "key_vault" {
  type = map(object({
    name                       = string
    sku_name                   = string
    enable_rbac_authorization  = bool
    purge_protection_enabled   = bool
    soft_delete_retention_days = number
    network_acls = object({
      default_action             = string
      bypass                     = string
      ip_rules                   = list(string)
      virtual_network_subnet_ids = list(string)
    })
  }))
  default = {
    app = {
      name                       = "app"
      sku_name                   = "standard"
      enable_rbac_authorization  = true
      purge_protection_enabled   = false
      soft_delete_retention_days = 7
      network_acls = {
        default_action             = "Deny"
        bypass                     = "AzureServices"
        ip_rules                   = ["MyIP"]
        virtual_network_subnet_ids = []
      }
    }
  }
}

variable "cosmosdb_account" {
  type = map(object({
    name                          = string
    offer_type                    = string
    kind                          = string
    free_tier_enabled             = bool
    public_network_access_enabled = bool
    ip_range_filter               = string
    consistency_policy = object({
      consistency_level       = string
      max_interval_in_seconds = number
      max_staleness_prefix    = number
    })
    geo_location = object({
      location          = string
      failover_priority = number
      zone_redundant    = bool
    })
    capacity = object({
      total_throughput_limit = number
    })
    backup = object({
      type = string
      tier = string
    })
  }))
  default = {
    app = {
      name                          = "cosmosdb"
      offer_type                    = "Standard"
      kind                          = "GlobalDocumentDB"
      free_tier_enabled             = false
      public_network_access_enabled = true
      ip_range_filter               = "104.42.195.92,40.76.54.131,52.176.6.30,52.169.50.45,52.187.184.26,13.91.105.215,4.210.172.107,13.88.56.148,40.91.218.243" # Allow access from Azure Portal
      consistency_policy = {
        consistency_level       = "Session"
        max_interval_in_seconds = 5
        max_staleness_prefix    = 100
      }
      geo_location = {
        location          = "japaneast"
        failover_priority = 0
        zone_redundant    = false
      }
      capacity = {
        total_throughput_limit = 1000
      }
      backup = {
        type = "Continuous"
        tier = "Continuous7Days"
      }
    }
  }
}

variable "cosmosdb_sql_database" {
  type = map(object({
    name                    = string
    target_cosmosdb_account = string
    autoscale_settings = object({
      max_throughput = number
    })
  }))
  default = {
    app = {
      name                    = "cosmos-sql-db"
      target_cosmosdb_account = "app"
      autoscale_settings = {
        max_throughput = 1000
      }
    }
  }
}

variable "cosmosdb_sql_container" {
  type = map(object({
    name                         = string
    target_cosmosdb_account      = string
    target_cosmosdb_sql_database = string
    partition_key_path           = string
    partition_key_version        = number
    autoscale_settings = object({
      max_throughput = number
    })
  }))
  default = {
    container1 = {
      name                         = "container1"
      target_cosmosdb_account      = "app"
      target_cosmosdb_sql_database = "app"
      partition_key_path           = "/id"
      partition_key_version        = 2
      autoscale_settings           = null
    }
  }
}

variable "mysql" {
  type = map(object({
    name                         = string
    target_vnet                  = string
    target_subnet                = string
    db_port                      = number
    db_size                      = string
    version                      = string
    zone                         = string
    backup_retention_days        = number
    geo_redundant_backup_enabled = bool
    storage = object({
      auto_grow_enabled = bool
      iops              = number
      size_gb           = number
    })
  }))
  default = {
    app = {
      name                         = "mysql"
      target_vnet                  = "spoke1"
      target_subnet                = "db"
      db_port                      = 3306
      db_size                      = "B_Standard_B1ms"
      version                      = "8.0.21"
      zone                         = "1"
      backup_retention_days        = 7
      geo_redundant_backup_enabled = false
      storage = {
        auto_grow_enabled = true
        iops              = 360
        size_gb           = 20
      }
    }
  }
}

variable "db_username" {
  type = string
}

variable "db_password" {
  type = string
}

variable "mysql_database" {
  type = map(map(string))
  default = {
    app = {
      name                = "photo"
      target_mysql_server = "app"
      charset             = "utf8mb4"
      collation           = "utf8mb4_0900_ai_ci"
    }
  }
}

variable "redis" {
  type = map(object({
    name                          = string
    capacity                      = number
    family                        = string
    sku_name                      = string
    redis_version                 = number
    public_network_access_enabled = bool
    enable_non_ssl_port           = bool
    minimum_tls_version           = string
  }))
  default = {
    app = {
      name                          = "redis"
      capacity                      = 0
      family                        = "C"
      sku_name                      = "Basic"
      redis_version                 = 6
      public_network_access_enabled = false
      enable_non_ssl_port           = false
      minimum_tls_version           = "1.2"
    }
  }
}

variable "openai" {
  type = map(object({
    name     = string
    location = string
    kind     = string
    sku_name = string
    network_acls = object({
      default_action = string
      ip_rules       = list(string)
    })
  }))
  default = {
    eastus = {
      name     = "oai-eastus"
      location = "eastus"
      kind     = "OpenAI"
      sku_name = "S0"
      network_acls = {
        default_action = "Deny"
        ip_rules       = []
      }
    }
  }
}

variable "openai_deployment" {
  type = map(object({
    name                   = string
    target_openai          = string
    version_upgrade_option = string
    model = object({
      name    = string
      version = optional(string)
    })
    scale = object({
      type     = string
      capacity = number
    })
  }))
  default = {
    gpt-4o = {
      name                   = "gpt-4o"
      target_openai          = "eastus"
      version_upgrade_option = "OnceNewDefaultVersionAvailable"
      model = {
        name    = "gpt-4o"
        version = "2024-05-13"
      }
      scale = {
        type     = "Standard"
        capacity = 10
      }
    }
    gpt-35-turbo = {
      name                   = "gpt-35-turbo"
      target_openai          = "eastus"
      version_upgrade_option = "OnceNewDefaultVersionAvailable"
      model = {
        name    = "gpt-35-turbo"
        version = "0301"
      }
      scale = {
        type     = "Standard"
        capacity = 10
      }
    }
  }
}

variable "aisearch" {
  type = map(object({
    name                          = string
    sku                           = string
    semantic_search_sku           = string
    partition_count               = number
    replica_count                 = number
    public_network_access_enabled = bool
    allowed_ips                   = list(string)
  }))
  default = {
    app = {
      name                          = "search"
      sku                           = "standard"
      semantic_search_sku           = "standard"
      partition_count               = 1
      replica_count                 = 1
      public_network_access_enabled = true
      allowed_ips                   = []
    }
  }
}
