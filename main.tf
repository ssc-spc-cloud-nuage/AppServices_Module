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
      "${x.name}" => x if lookup(x, "deploy", true) != false
  }
}

resource "azurerm_app_service_plan" "appservices-asp" {
  name                ="${var.environment}-cio-${var.AppServicesPlan["name"]}"
  location            = var.location
  resource_group_name = var.AppServicesPlan["resource_group_name"]

  sku {
    tier = var.AppServicesPlan["tier"] # "PremiumV2"
    size = var.AppServicesPlan["size"] # "P1v2"
  }
}

resource  "azurerm_app_service" "appservices-aps" {
  for_each = local.deploydbs
  name                = "${var.environment}-cio-${each.value.name}"
  location            = var.location
  resource_group_name = each.value.resource_group_name
  app_service_plan_id = azurerm_app_service_plan.appservices-asp.id
  
  dynamic "app_settings" {
     for_each =  each.value.WEBSITE_DNS_SERVER == null ? [] : [each.value.WEBSITE_DNS_SERVER]
      content {
        WEBSITE_DNS_SERVER = each.value.WEBSITE_DNS_SERVER # "168.63.129.16",
        WEBSITE_VNET_ROUTE_ALL = each.value.WEBSITE_VNET_ROUTE_ALL # "1"
      }         
  }
}

resource "azurerm_app_service_virtual_network_swift_connection" "vnetintegrationconnection" {
  app_service_id  = azurerm_app_service.appservices-aps.id
  subnet_id       = local.subnets.APP.id
}