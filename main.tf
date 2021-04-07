resource "azurerm_app_service_plan" "CIO-VCBOARDROOM-asp" {
  name                = "${local.environment}-cio-vcboardroom-asp"
  location            = local.resource_groups_L3.AppServices.location
  resource_group_name = local.resource_groups_L3.AppServices.name

  sku {
    tier = "PremiumV2"
    size = "P1v2"
  }
}

resource  "azurerm_app_service" "CIO-VCBOARDROOM-aps" {
  name                = "${local.environment}ciovcboardroom"
  location            = local.resource_groups_L3.AppServices.location
  resource_group_name = local.resource_groups_L3.AppServices.name
  app_service_plan_id = azurerm_app_service_plan.CIO-VCBOARDROOM-asp.id
  
  app_settings = {
    "WEBSITE_DNS_SERVER" = "168.63.129.16",
    "WEBSITE_VNET_ROUTE_ALL" = "1"
  }
}

resource "azurerm_app_service_virtual_network_swift_connection" "vnetintegrationconnection" {
  app_service_id  = azurerm_app_service.CIO-VCBOARDROOM-aps.id
  subnet_id       = local.subnets.APP.id
}