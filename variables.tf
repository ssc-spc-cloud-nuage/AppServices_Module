variable "location" {
  description = "Specifies the supported Azure location where the resource exists"
  default     = "canadacentral"
}

variable "environment" {
  description = ""
}

variable "deploy" {
  default     = false
}

variable "subnet_id" {
  description = "The ID of the subnet that the Apps Service server will be connected to"
}

variable "AppServicesPlan" {
  description = "Collection of service Plan and App Services"
  type = any
}

variable "DnsPrivatezoneId" {
  description = ""
  type = list(string)
}
