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
variable "network_self_link" {
  description = "self link of network of application"
  type        = string
}

variable "network_subnet_private_self_link" {
  description = "Self link of subnet private"
  type        = string
}

variable "network_subnet_private_address_range" {
  description = "Network subnet private address ranges to assosiate for vms"
  type        = string
}

#--------------------- Secure bucket Configuration ---------------------
variable "secure_bucket_name" {
  description = "The bucket name where store the information securly"
  type        = string
}

#--------------------- Master instance Configuration ---------------------
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


#--------------------- Worker instance Configuration ---------------------
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
  default     = 1
}


variable "k8s_node_connect_port" {
  description = "Port number of worker node to connect from loadbalancer"
  type        = number
}

variable "scale_cpu_utilization" {
  description = "Average CPU utilization of worker node for scale"
  type        = number
  default     = 0.6
}

variable "scale_max_replicas" {
  description = "Maximum relicas of worker nodes for scale"
  type        = number
  default     = 2
}

variable "scale_cooldown_period" {
  description = "Cooldown period of worker nodes for scale"
  type        = number
  default     = 60
}


variable "scale_min_replicas" {
  description = "Minimum relicas of worker nodes for scale"
  type        = number
  default     = 2
}

variable "health_check_interval_sec" {
  description = "Interval second of health check"
  type        = number
  default     = 2
}

variable "health_timeout_sec" {
  description = "Timemout second of health check"
  type        = number
  default     = 2
}

variable "health_healthy_threshold" {
  description = "Healthy threshold of health check"
  type        = number
  default     = 2
}

variable "health_unhealthy_threshold" {
  description = "Unhealthy threshold of health check"
  type        = number
  default     = 2
}

variable "mig_healing_policies_initial_delay_sec" {
  description = "Healing policies initial delay in seconds of Machine instance group"
  type        = number
  default     = 60
}

variable "mig_target_size" {
  description = "Target sizeof Machine instance group"
  type        = number
  default     = 1
}
