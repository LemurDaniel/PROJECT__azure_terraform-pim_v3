terraform {

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.4"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.22"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.1"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.7"
    }
  }
  backend "local" {}
}


provider "azurerm" {
  features {}
}
