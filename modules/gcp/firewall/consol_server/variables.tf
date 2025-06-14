#--------------------- Development Project Configuration ---------------------
variable "project_id" {
  description = "Id of the development project"
  type        = string
}

# --------------------- GCP Project and Regsion Configuration ---------------------

variable "gcp_zone" {
  description = "GCP zone to deploy to"
  type        = string
}

#--------------------- Network Configuration ---------------------
variable "network_self_link" {
  description = "self link of network of application"
  type        = string
}

variable "subnet_public_address_range" {
  description = "Network address ranges of public subnet of vpc to assosiate for vms"
  type        = string
}

variable "app_subnet_private_address_range" {
  description = "Network address ranges of private subnet of vpc to assosiate for vms application"
  type        = string
}