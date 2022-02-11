data "azurerm_resource_group" "rg" {
  name = "tfrg"
}

resource "random_id" "server" {
  keepers = {
    resource_group_name = data.azurerm_resource_group.rg.name
  }
  byte_length = 8
}

resource "azurerm_app_service_plan" "example" {
  name                = "appserviceplan${random_id.server.hex}"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "example" {
  name                = "appservice${random_id.server.hex}"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  app_service_plan_id = azurerm_app_service_plan.example.id

  site_config {
    dotnet_framework_version = "v4.0"
    scm_type                 = "LocalGit"
  }

  app_settings = {
    "SOME_KEY" = "some-value"
  }

  connection_string {
    name  = "Database"
    type  = "SQLServer"
    value = "Server=some-server.mydomain.com;Integrated Security=SSPI"
  }
}