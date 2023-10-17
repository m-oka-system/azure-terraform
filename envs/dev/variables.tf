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

variable "network" {
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
    name                                      = string
    target_vnet                               = string
    address_prefixes                          = list(string)
    private_endpoint_network_policies_enabled = bool
    service_delegation = object({
      name    = string
      actions = list(string)
    })
  }))
  default = {
    pe = {
      name                                      = "pe"
      target_vnet                               = "spoke1"
      address_prefixes                          = ["10.10.0.0/24"]
      private_endpoint_network_policies_enabled = true
      service_delegation                        = null
    }
    app = {
      name                                      = "app"
      target_vnet                               = "spoke1"
      address_prefixes                          = ["10.10.1.0/24"]
      private_endpoint_network_policies_enabled = false
      service_delegation = {
        name    = "Microsoft.Web/serverFarms"
        actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
      }
    }
    function = {
      name                                      = "function"
      target_vnet                               = "spoke1"
      address_prefixes                          = ["10.10.2.0/24"]
      private_endpoint_network_policies_enabled = false
      service_delegation = {
        name    = "Microsoft.Web/serverFarms"
        actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
      }
    }
    db = {
      name                                      = "db"
      target_vnet                               = "spoke1"
      address_prefixes                          = ["10.10.3.0/24"]
      private_endpoint_network_policies_enabled = false
      service_delegation = {
        name    = "Microsoft.DBforMySQL/flexibleServers"
        actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
      }
    }
    vm = {
      name                                      = "vm"
      target_vnet                               = "spoke1"
      address_prefixes                          = ["10.10.4.0/24"]
      private_endpoint_network_policies_enabled = false
      service_delegation                        = null
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
    target_storage_account        = string
    target_application_insights   = string
    functions_extension_version   = string
    python_version                = string
    https_only                    = bool
    public_network_access_enabled = bool
    builtin_logging_enabled       = bool
    site_config = object({
      always_on                   = bool
      ftps_state                  = string
      vnet_route_all_enabled      = bool
      scm_use_main_ip_restriction = bool
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
  }))
  default = {
    http_trigger = {
      name                          = "function"
      target_service_plan           = "function"
      target_subnet                 = "function"
      target_storage_account        = "function"
      target_application_insights   = "function"
      functions_extension_version   = "~4"
      python_version                = "3.10"
      https_only                    = true
      public_network_access_enabled = true
      builtin_logging_enabled       = false
      site_config = {
        always_on                   = true
        ftps_state                  = "Disabled"
        vnet_route_all_enabled      = true
        scm_use_main_ip_restriction = false
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
        myip = {
          name        = "AllowMyIP"
          priority    = 100
          action      = "Allow"
          ip_address  = "MyIP"
          service_tag = null
        }
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
