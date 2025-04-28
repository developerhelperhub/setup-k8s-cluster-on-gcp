variable "gcp_zone" {
  description = "GCP zone to deploy to"
  type        = string
}

variable "project_name" {
  description = "Name of the development project"
  type        = string
}

variable "gcp_region" {
  description = "GCP region to deploy to"
  type        = string
}

variable "project_id" {
  description = "Id of the development project"
  type        = string
}

#--------------------- Network Configuration ---------------------
variable "network_name" {
  description = "Network name of application"
  type        = string
}

variable "network_subnet_private_address_range" {
  description = "Network subnet private address ranges to assosiate for vms"
  type        = string
}

variable "network_subnet_private_name" {
  description = "Network subnet private name"
  type        = string
}

variable "secure_bucket_name" {
  description = "The bucket name where store the information securly"
  type        = string
}

# master vm configuration
variable "master_instance_type" {
  description = "Instance type of master k8s to install to"
  type        = string
}

variable "master_os_image" {
  description = "OS image of master to install into VM"
  type        = string
}


variable "master_os_disk_size" {
  description = "OS disk size of master VM"
  type        = string
}

variable "master_os_disk_type" {
  description = "OS disk type of master VM"
  type        = string
}


# node vm configuration
variable "node_instance_type" {
  description = "Instance type of node k8s to install to"
  type        = string
}

variable "node_os_image" {
  description = "OS image of node to install into VM"
  type        = string
}

variable "node_os_disk_size" {
  description = "OS disk size of node VM"
  type        = string
}

variable "node_os_disk_type" {
  description = "OS disk type of node VM"
  type        = string
}

variable "node_count" {
  description = "Number of node count needs to create in the cluster"
  type        = number
  default = 1
}
