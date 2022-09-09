variable "governance_settings" {}

variable "subscriptions" {}

variable "aad_group_owner_ids" {
  type        = list(string)
  description = "(Required) List of Ids set as owner to the created AAD Groups."
}

variable "location" {}