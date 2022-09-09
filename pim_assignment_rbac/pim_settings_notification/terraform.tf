terraform {
  required_version = "~> 1.2"
  experiments      = [module_variable_optional_attrs] # TO Activate fature

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.3"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.3"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.7"
    }

  }

}
