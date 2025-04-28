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
variable "network_name" {
  description = "Network name of application"
  type        = string
}

variable "network_subnet_public_address_range" {
  description = "Subnet public address ranges to assosiate for vms"
  type        = string
}

variable "network_subnet_public_name" {
  description = "Subnet public name"
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


variable "backend_k8s_worker_ips" {
  description = "Worker node ips of k8s for loadbalancing"
  type        = string
}

variable "backend_k8s_worker_port" {
  description = "Worker node port of k8s for loadbalancing"
  type        = string
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
