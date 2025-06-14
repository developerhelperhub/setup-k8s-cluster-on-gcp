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

variable "network_subnet_public_address_range" {
  description = "Subnet public address ranges to assosiate for vms"
  type        = string
}

variable "network_subnet_public_self_link" {
  description = "Self link of subnet public"
  type        = string
}

# --------------------- HAProxy Instance Configuration ---------------------
# vm configuration
variable "vm_instance_type" {
  description = "Instance type of haproxy lb to install to"
  type        = string
}

variable "vm_os_image" {
  description = "OS image of haproxy lb to install into VM"
  type        = string
}


variable "vm_os_disk_size" {
  description = "OS disk size of haproxy lb VM"
  type        = string
}

variable "vm_os_disk_type" {
  description = "OS disk type of haproxy lb VM"
  type        = string
}

variable "vm_count" {
  description = "Number of vm count needs to create"
  type        = number
  default = 1
}

variable "backend_connect_protocol" {
  description = "Backend connect protocol for loadbalancer"
  type        = string
}

variable "frontend_connect_protocol" {
  description = "Client connect protocol for loadbalancer"
  type        = string
}

variable "frontend_connect_port" {
  description = "Client connect port into loadbalancer"
  type        = number
}


variable "secure_bucket_name" {
  description = "The bucket name where store the information securly"
  type        = string
}
