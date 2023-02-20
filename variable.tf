variable "location" {
  type    = string
  default = "westeurope"
}

variable "prefix" {
  type    = string
  default = "sola"
}

variable "stage" {
  type    = string
  default = "dev"
}

variable "name" {
  type    = string
  default = "aut"
}

variable "location_shortname" {
  type    = string
  default = "weu"
}

variable "remote_state_storage_account_name" {
  type    = string
  default = "parisatfstateaziac2weu"
}

variable "remote_state_resource_group_name" {
  type    = string
  default = "tfstate"
}
