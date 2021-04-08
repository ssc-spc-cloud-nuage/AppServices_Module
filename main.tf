terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.52.0"
    }
  }
}

# locals {
#     deploydbs = {
#     for x in var.server.SQL_Database : 
#       "${x.sqldbname}" => x if lookup(x, "deploy", true) != false
#   }
# }

resource "azurerm_app_service_plan" "appservices-asp" {
  name                ="${var.environment}-cio-${var.AppServicesPlan["name"]}"
  location            = var.location
  resource_group_name = var.AppServicesPlan["resource_group_name"]

  sku {
    tier = var.AppServicesPlan["tier"] # "PremiumV2"
    size = var.AppServicesPlan["size"] # "P1v2"
  }
}

# resource  "azurerm_app_service" "appservices-aps" {
#   name                = "${var.environment}-cio-${var.AppServices["name"]}"
#   location            = var.location
#   resource_group_name = var.AppServices["resource_group_name"]
#   app_service_plan_id = azurerm_app_service_plan.appservices-asp.id
  
#   dynamic "app_settings" {
#      for_each =  each.value.policyretention_days == null ? [] : [ each.value.policyretention_days]
#       content {
#         WEBSITE_DNS_SERVER = var.AppServices["WEBSITE_DNS_SERVER"] # "168.63.129.16",
#         WEBSITE_VNET_ROUTE_ALL = var.AppServices["WEBSITE_VNET_ROUTE_ALL"] # "1"
#       }         
#   }
# }

# resource "azurerm_app_service_virtual_network_swift_connection" "vnetintegrationconnection" {
#   app_service_id  = azurerm_app_service.appservices-aps.id
#   subnet_id       = local.subnets.APP.id
# }