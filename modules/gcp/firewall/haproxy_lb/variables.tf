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

variable "network_subnet_private_address_range" {
  description = "Subnet private address ranges to assosiate for vms"
  type        = string
}


variable "frontend_connect_port" {
  description = "Client connect port into loadbalancer"
  type        = number
}
