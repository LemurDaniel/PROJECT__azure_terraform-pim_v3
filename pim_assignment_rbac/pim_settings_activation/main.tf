terraform {

  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
    }
    random = {
      source  = "hashicorp/random"
    }
    time = {
      source  = "hashicorp/time"
    }
    null = {
      source = "hashicorp/null"
    }

  }

}
