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
variable "gcp_project_id" {
  description = "GCP project id"
  type        = string
}

variable "gcp_region" {
  description = "GCP region to deploy to"
  type        = string
}

variable "gcp_zone" {
  description = "GCP zone to deploy to"
  type        = string
}

#--------------------- Dev Network Configuration ---------------------

variable "dev_subnet_public_address_range" {
  description = "Network address ranges of public subnet of development vpc to assosiate for vms"
  type        = string
}

variable "dev_app_subnet_private_address_range" {
  description = "Network address ranges of private subnet of development vpc to assosiate for vms application"
  type        = string
}

variable "dev_db_subnet_private_address_range" {
  description = "Network address ranges of private subnet of development vpc to assosiate for vms database"
  type        = string
}
