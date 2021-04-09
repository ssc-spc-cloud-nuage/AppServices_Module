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
      dotnet_framework_version = "v4.0"
      scm_type                 = "LocalGit"
     }
  }

  app_settings = {
    "WEBSITE_DNS_SERVER" = each.value.WEBSITE_DNS_SERVER # "168.63.129.16",
    "WEBSITE_VNET_ROUTE_ALL" = each.value.WEBSITE_VNET_ROUTE_ALL # "1"             
  }


}

resource "azurerm_app_service_virtual_network_swift_connection" "vnetintegrationconnection" {
  for_each = local.deployappservices
    app_service_id  = azurerm_app_service.appservices-aps[each.key].id
    subnet_id       = var.subnet_id
}