#--------------------- Development Project Configuration ---------------------
variable "project_id" {
  description = "Id of the development project"
  type        = string
}

variable "project_name" {
  description = "Name of the development project"
  type        = string
}

# --------------------- GCP Project and Regsion Configuration ---------------------
variable "gcp_region" {
  description = "GCP region to deploy to"
  type        = string
}

variable "gcp_zone" {
  description = "GCP zone to deploy to"
  type        = string
}

#--------------------- Network Configuration ---------------------
variable "nw_network_name" {
  description = "Network name of application"
  type        = string
}

variable "nw_subnet_public_address_range" {
  description = "Network address ranges of public subnet to assosiate for vms"
  type        = string
}

variable "nw_subnet_private_address_range" {
  description = "Network address ranges of private subnet to assosiate for vms"
  type        = string
}
