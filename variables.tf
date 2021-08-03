variable "prefix" {
  description = "The prefix which should be used for all resources in this example"
  default = "foundry"
}

variable "resourcegroup" {
  description = "The prefix which should be used for all resources in this example"
  default = "foundry"
}

variable "virtualnetwork" {
  description = "The prefix which should be used for all resources in this example"
  default = "foundryvtt"
}

variable "subnet" {
  description = "The prefix which should be used for all resources in this example"
  default = "foundrysub"
}

variable "location" {
  description = "The Azure Region in which all resources in this example should be created."
  default = "westus"
}

variable "admin_username" {
  description = "The admin Username to be created"
  sensitive = true
  default = "adminuser"  
}

variable "vmsize" {
  description = "Instance type of Virtual Machine"
  default = "Standard_B2s"
}
variable "foundryurl" {
  validation {
    condition = (var.foundryurl != null)
    error_message = "No Foundry url has been supplied."
  }
  description = "Instance type of Virtual Machine"
  default = null
}
variable "WAN_IPs" {
  default = "*"
}

variable "default_tags" { 
    type = map 
    default = {
  }
}