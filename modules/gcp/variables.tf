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

variable "gcp_helath_check_ip_ranges" {
  description = "GCP health check ip ranges for configuring firewall rule"
  type        = list
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

#--------------------- Secure Bucket ---------------------
variable "secure_bucket_unique_name_prefix" {
  description = "Unique prefix name of secure bucket to make unique globaly"
  type        = string
}


# --------------------- Consul Server Instance Configuration ---------------------
# vm configuration
variable "consule_server_vm_instance_type" {
  description = "Instance type of consul server to install to"
  type        = string
}

variable "consule_server_vm_os_image" {
  description = "OS image of consul server to install into VM"
  type        = string
}


variable "consule_server_vm_os_disk_size" {
  description = "OS disk size of consul server VM"
  type        = string
}

variable "consule_server_vm_os_disk_type" {
  description = "OS disk type of consul server VM"
  type        = string
}

variable "consule_server_vm_count" {
  description = "Number of vm count needs to create"
  type        = number
  default = 1
}


# --------------------- HAProxy Instance Configuration ---------------------
# vm configuration
variable "lb_vm_instance_type" {
  description = "Instance type of haproxy lb to install to"
  type        = string
}

variable "lb_vm_os_image" {
  description = "OS image of haproxy lb to install into VM"
  type        = string
}


variable "lb_vm_os_disk_size" {
  description = "OS disk size of haproxy lb VM"
  type        = string
}

variable "lb_vm_os_disk_type" {
  description = "OS disk type of haproxy lb VM"
  type        = string
}

variable "lb_vm_count" {
  description = "Number of vm count needs to create"
  type        = number
  default = 1
}

variable "lb_backend_connect_protocol" {
  description = "Backend connect protocol for loadbalancer"
  type        = string
}

variable "lb_frontend_connect_protocol" {
  description = "Client connect protocol for loadbalancer"
  type        = string
}

variable "lb_frontend_connect_port" {
  description = "Client connect port into loadbalancer"
  type        = number
}



#--------------------- K8s Configuration ---------------------
# master vm configuration
variable "k8s_master_instance_type" {
  description = "Instance type of master k8s to install to"
  type        = string
}

variable "k8s_master_os_image" {
  description = "OS image of master to install into VM"
  type        = string
}


variable "k8s_master_os_disk_size" {
  description = "OS disk size of master VM"
  type        = string
}

variable "k8s_master_os_disk_type" {
  description = "OS disk type of master VM"
  type        = string
}


# node vm configuration
variable "k8s_node_instance_type" {
  description = "Instance type of node k8s to install to"
  type        = string
}

variable "k8s_node_os_image" {
  description = "OS image of node to install into VM"
  type        = string
}

variable "k8s_node_os_disk_size" {
  description = "OS disk size of node VM"
  type        = string
}

variable "k8s_node_os_disk_type" {
  description = "OS disk type of node VM"
  type        = string
}

variable "k8s_node_count" {
  description = "Number of node count needs to create in the cluster"
  type        = number
  default = 1
}

variable "k8s_node_connect_port" {
  description = "Port number of worker node to connect from loadbalancer"
  type        = number
}


# ----------Scale configuration of K8s worker node----------
variable "k8s_node_scale_cpu_utilization" {
  description = "Average CPU utilization of worker node for scale"
  type        = number
  default     = 0.6
}

variable "k8s_node_scale_max_replicas" {
  description = "Maximum relicas of worker nodes for scale"
  type        = number
  default     = 2
}

variable "k8s_node_scale_cooldown_period" {
  description = "Cooldown period of worker nodes for scale"
  type        = number
  default     = 60
}


variable "k8s_node_scale_min_replicas" {
  description = "Minimum relicas of worker nodes for scale"
  type        = number
  default     = 2
}

variable "k8s_node_health_check_interval_sec" {
  description = "Interval second of health check"
  type        = number
  default     = 2
}

variable "k8s_node_health_timeout_sec" {
  description = "Timemout second of health check"
  type        = number
  default     = 2
}

variable "k8s_node_health_healthy_threshold" {
  description = "Healthy threshold of health check"
  type        = number
  default     = 2
}

variable "k8s_node_health_unhealthy_threshold" {
  description = "Unhealthy threshold of health check"
  type        = number
  default     = 2
}

variable "k8s_node_mig_healing_policies_initial_delay_sec" {
  description = "Healing policies initial delay in seconds of Machine instance group"
  type        = number
  default     = 60
}

variable "k8s_node_mig_target_size" {
  description = "Target sizeof Machine instance group"
  type        = number
  default     = 1
}

