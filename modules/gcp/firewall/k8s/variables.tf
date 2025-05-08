variable "gcp_zone" {
  description = "GCP zone to deploy to"
  type        = string
}

variable "project_id" {
  description = "Id of the development project"
  type        = string
}

variable "gcp_helath_check_ip_ranges" {
  description = "GCP health check ip ranges for configuring firewall rule"
  type        = list
}

# #--------------------- Network Configuration ---------------------
variable "network_name" {
  description = "Network name of application"
  type        = string
}

variable "network_subnet_public_address_range" {
  description = "Network subnet public address ranges to assosiate for vms"
  type        = string
}

variable "network_subnet_private_address_range" {
  description = "Network subnet private address ranges to assosiate for vms"
  type        = string
}

variable "node_connect_port" {
  description = "Port number of worker node to connect from loadbalancer"
  type        = number
}
