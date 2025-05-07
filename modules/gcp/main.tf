provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
  zone    = var.gcp_zone
}

module "app_network" {
  source = "./network"

  project_id   = var.project_id
  project_name = var.project_name

  gcp_zone   = var.gcp_zone
  gcp_region = var.gcp_region

  nw_network_name                 = var.nw_network_name
  nw_subnet_public_address_range  = var.nw_subnet_public_address_range
  nw_subnet_private_address_range = var.nw_subnet_private_address_range
}

module "secure_bucket" {
  source     = "./buckets"
  depends_on = [module.app_network]

  project_id   = var.project_id
  project_name = var.project_name

  gcp_zone   = var.gcp_zone
  gcp_region = var.gcp_region

  unique_name_prefix = var.secure_bucket_unique_name_prefix

}

module "consul_server_firewall_rule" {
  source     = "./firewall/consol_server"
  depends_on = [module.app_network]

  project_id = var.project_id

  gcp_zone = var.gcp_zone

  network_name                         = module.app_network.network_name
  network_subnet_private_address_range = var.nw_subnet_private_address_range
  network_subnet_public_address_range  = var.nw_subnet_public_address_range
}

module "consul_server" {
  source     = "./consul_server"
  depends_on = [module.secure_bucket, module.consul_server_firewall_rule]

  project_id   = var.project_id
  project_name = var.project_name

  gcp_zone   = var.gcp_zone
  gcp_region = var.gcp_region

  network_name                         = module.app_network.network_name
  network_subnet_private_address_range = var.nw_subnet_private_address_range
  network_subnet_private_name          = module.app_network.network_subnet_private_name

  secure_bucket_name = module.secure_bucket.bucket_name

  vm_instance_type = var.consule_server_vm_instance_type
  vm_os_image      = var.consule_server_vm_os_image
  vm_os_disk_size  = var.consule_server_vm_os_disk_size
  vm_os_disk_type  = var.consule_server_vm_os_disk_type
  vm_count         = var.consule_server_vm_count
}

module "k8s_cluster_firewall_rule" {
  source     = "./firewall/k8s"
  depends_on = [module.app_network]

  project_id = var.project_id

  gcp_zone = var.gcp_zone

  network_name                         = module.app_network.network_name
  network_subnet_public_address_range  = var.nw_subnet_public_address_range
  network_subnet_private_address_range = var.nw_subnet_private_address_range

  node_connect_port = var.k8s_node_connect_port
  gcp_helath_check_ip_ranges = var.gcp_helath_check_ip_ranges
}

module "k8s_cluster" {
  source     = "./k8s"
  depends_on = [module.secure_bucket, module.k8s_cluster_firewall_rule]

  project_id   = var.project_id
  project_name = var.project_name

  gcp_zone   = var.gcp_zone
  gcp_region = var.gcp_region

  network_name                         = module.app_network.network_name
  network_subnet_private_address_range = var.nw_subnet_private_address_range
  network_subnet_private_name          = module.app_network.network_subnet_private_name

  secure_bucket_name = module.secure_bucket.bucket_name

  master_instance_type = var.k8s_master_instance_type
  master_os_image      = var.k8s_master_os_image
  master_os_disk_size  = var.k8s_master_os_disk_size
  master_os_disk_type  = var.k8s_master_os_disk_type

  node_instance_type = var.k8s_node_instance_type
  node_os_image      = var.k8s_node_os_image
  node_os_disk_size  = var.k8s_node_os_disk_size
  node_os_disk_type  = var.k8s_node_os_disk_type
  node_count         = var.k8s_node_count

  k8s_node_connect_port = var.k8s_node_connect_port


  scale_cpu_utilization                  = var.k8s_node_scale_cpu_utilization
  scale_max_replicas                     = var.k8s_node_scale_max_replicas
  scale_cooldown_period                  = var.k8s_node_scale_cooldown_period
  scale_min_replicas                     = var.k8s_node_scale_min_replicas
  health_check_interval_sec              = var.k8s_node_health_check_interval_sec
  health_timeout_sec                     = var.k8s_node_health_timeout_sec
  health_healthy_threshold               = var.k8s_node_health_healthy_threshold
  health_unhealthy_threshold             = var.k8s_node_health_unhealthy_threshold
  mig_healing_policies_initial_delay_sec = var.k8s_node_mig_healing_policies_initial_delay_sec
  mig_target_size                        = var.k8s_node_mig_target_size

}

module "haproxy_lb_firewall_rule" {
  source     = "./firewall/haproxy_lb"
  depends_on = [module.app_network]

  project_id = var.project_id

  gcp_zone = var.gcp_zone

  network_name                         = module.app_network.network_name
  network_subnet_private_address_range = var.nw_subnet_private_address_range

  frontend_connect_port = var.lb_frontend_connect_port
}

module "haproxy_lb" {
  source = "./haproxy_lb"
  depends_on = [ module.haproxy_lb_firewall_rule ]

  project_id   = var.project_id
  project_name = var.project_name

  gcp_zone   = var.gcp_zone
  gcp_region = var.gcp_region

  network_name = module.app_network.network_name
  network_subnet_public_address_range = var.nw_subnet_public_address_range
  network_subnet_public_name = module.app_network.network_subnet_public_name

  secure_bucket_name = module.secure_bucket.bucket_name

  vm_instance_type = var.lb_vm_instance_type
  vm_os_image= var.lb_vm_os_image
  vm_os_disk_size= var.lb_vm_os_disk_size
  vm_os_disk_type= var.lb_vm_os_disk_type
  vm_count= var.lb_vm_count

  backend_connect_protocol = var.lb_backend_connect_protocol

  frontend_connect_protocol = var.lb_frontend_connect_protocol
  frontend_connect_port = var.lb_frontend_connect_port
}
