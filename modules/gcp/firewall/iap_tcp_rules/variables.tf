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

variable "allow_ip_ranges" {
  description = "Allow ip ranges which can connect bastion node"
  type        = string
}