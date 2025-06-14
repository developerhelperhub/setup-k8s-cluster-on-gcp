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
variable "network_self_link" {
  description = "self link of network of application"
  type        = string
}

variable "network_subnet_private_address_range" {
  description = "Subnet private address ranges to assosiate for vms"
  type        = string
}

variable "network_subnet_private_self_link" {
  description = "Self link of subnet private"
  type        = string
}

# --------------------- Consul server Instance Configuration ---------------------
# vm configuration
variable "vm_instance_type" {
  description = "Instance type of consul server lb to install to"
  type        = string
}

variable "vm_os_image" {
  description = "OS image of consul server to install into VM"
  type        = string
}


variable "vm_os_disk_size" {
  description = "OS disk size of consul server VM"
  type        = string
}

variable "vm_os_disk_type" {
  description = "OS disk type of consul server VM"
  type        = string
}

variable "vm_count" {
  description = "Number of vm count needs to create"
  type        = number
  default = 1
}

variable "secure_bucket_name" {
  description = "The bucket name where store the information securly"
  type        = string
}
