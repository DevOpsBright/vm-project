variable "resource_group_name" {
    type = string
    default = "my-resource-group"
  
}

variable "location" {
  type        = string
  default     = "East US"
}

variable "vnetname" {
  type = string
  default = "my-virtual-network"
}

variable "address_space" {
  type = list(string)
  default = [ "10.0.1.0/24" ]
}

variable "ipprefixes" {
  type = list(string)
  default = [ "10.0.1.0/24" ]
}

variable "nic_name" {
  type = string
  default = "blessterra"
}

variable "hostname" {
  type = string
  default = "blesstest1"
}

variable "image_version" {
  description = "Version of the Ubuntu image to use for the VM"
  default     = "latest"  # Or specify a specific version like "20_04-lts"
}
