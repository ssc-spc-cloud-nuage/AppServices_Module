terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.52.0"
    }
  }
}

locals {
    deployappservices = {
    for x in var.AppServicesPlan.AppServices : 
      "${x.nameappservice}" => x if lookup(x, "deploy", true) != false
  }
}

resource "azurerm_app_service_plan" "appservices-asp" {
  name                ="${var.environment}-cio-${var.AppServicesPlan["nameplan"]}"
  location            = var.location
  resource_group_name = var.AppServicesPlan["resource_group_name"]

  sku {
    tier = var.AppServicesPlan["tier"] # "PremiumV2"
    size = var.AppServicesPlan["size"] # "P1v2"
  }
}

resource  "azurerm_app_service" "appservices-aps" {
  for_each = local.deployappservices
  name                = "${var.environment}-cio-${each.value.nameappservice}"
  location            = var.location
  resource_group_name = each.value.resource_group_name
  app_service_plan_id = azurerm_app_service_plan.appservices-asp.id

  
  dynamic "site_config" {
    for_each =  each.value.dotnet_framework_version == null ? [] : [each.value.dotnet_framework_version]
     content {
      dotnet_framework_version =  each.value.dotnet_framework_version    
      use_32_bit_worker_process = true 
      managed_pipeline_mode = "Classic"
     }
  }

   dynamic "connection_string" {
      for_each =  each.value.name == null ? [] : [each.value.name]
      content {
        name  = each.value.name # "boardroom_directory"
        type  = each.value.type # "SQLAzure"
        value = each.value.value #"Server=tcp:scpc-cio-sqlsrvvcboardroom.database.windows.net,1433;Initial Catalog=scpc-cio-sqldb-vcboardroom;Persist Security Info=False;User ID=azureadmin;Password=Canada123!sqlserver;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
     }
  }

  app_settings = {
    "WEBSITE_DNS_SERVER" = each.value.WEBSITE_DNS_SERVER # "168.63.129.16",
    "WEBSITE_VNET_ROUTE_ALL" = each.value.WEBSITE_VNET_ROUTE_ALL # "1"             
  }
}

# resource "azurerm_private_endpoint" "privateendpoint" {  
#   for_each =  local.deployappservices
#     name                = "backwebappprivateendpoint"
#     location            = var.location
#     resource_group_name = each.value.resource_group_name
#     subnet_id           = var.subnet_id_EP

#     private_dns_zone_group {
#       name = "privatednszonegroup"
#       private_dns_zone_ids = [var.DnsPrivatezoneId]
#     }

#     private_service_connection {
#       name = "privateendpointconnection"
#       private_connection_resource_id = azurerm_app_service.appservices-aps[each.key].id 
#       subresource_names = ["sites"]
#       is_manual_connection = false
#     }
# }


resource "azurerm_app_service_virtual_network_swift_connection" "vnetintegrationconnection" {
  for_each = local.deployappservices
    app_service_id  = azurerm_app_service.appservices-aps[each.key].id    
    subnet_id       = var.subnet_id_APP
}