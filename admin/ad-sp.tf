# Create Azure AD App
resource "azuread_application" "ws" {
  count = length(var.users)

  name                       = "ace-workshop-2019-${var.users[count.index].id}"
  available_to_other_tenants = false
}

# Create Service Principal associated with the Azure AD App
resource "azuread_service_principal" "ws" {
  count = length(var.users)

  application_id = azuread_application.ws[count.index].application_id
}

# Generate random string to be used for Service Principal password
resource "random_uuid" "password" {
  count = length(var.users)
}

# Create Service Principal password
resource "azuread_service_principal_password" "ws" {
  count = length(var.users)

  service_principal_id = azuread_service_principal.ws[count.index].id
  value                = random_uuid.password[count.index].result
  end_date             = "2020-01-01T01:00:00Z"
}

data "azurerm_subscription" "primary" {}

# Create role assignment for service principal
resource "azurerm_role_assignment" "ws" {
  count = length(var.users)

  scope                = "${data.azurerm_subscription.primary.id}/resourceGroups/${azurerm_resource_group.ws[count.index].name}"
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.ws[count.index].id
}
