variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "nomaddigital-rg"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "West Europe"
}

variable "ws1_nic_name" {
  description = "Name of the first VM's network interface"
  type        = string
  default     = "Workstation-1-nic"
}

variable "ws2_nic_name" {
  description = "Name of the second VM's network interface"
  type        = string
  default     = "Workstation-2-nic"
}
