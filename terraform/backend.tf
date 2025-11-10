# -----------------------------------------------------------------------------
# REMOTE BACKEND CONFIGURATION
# -----------------------------------------------------------------------------
# Se deja el bloque backend sin valores para que se inyecten vía
# `terraform init -backend-config="resource_group_name=..." ...`
terraform {
  backend "azurerm" {}
}