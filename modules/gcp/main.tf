locals {
  unsupport_env = "unsupported-workspace-${terraform.workspace}"
}

provider "google" {
  project                     = var.gcp_project_id
  region                      = var.gcp_region
  zone                        = var.gcp_zone
  impersonate_service_account = var.terrafor_impersonate_service_account
}

module "dev_netowrk" {
  source = "./dev_network"
  count  = terraform.workspace == "dev" ? 1 : 0

  project_id   = var.project_id
  project_name = var.project_name

  gcp_project_id = var.gcp_project_id
  gcp_zone       = var.gcp_zone
  gcp_region     = var.gcp_region

  dev_subnet_public_address_range      = var.dev_subnet_public_address_range
  dev_app_subnet_private_address_range = var.dev_app_subnet_private_address_range
  dev_db_subnet_private_address_range  = var.dev_db_subnet_private_address_range
}

module "iap_tcp_forwarding_firewall_rule" {
  source     = "./firewall/iap_tcp_rules"
  depends_on = [module.dev_netowrk[0]]

  project_id = var.project_id

  gcp_zone = var.gcp_zone

  network_self_link = module.dev_netowrk[0].network_self_link
  allow_ip_ranges   = var.iap_tcp_forwarding_allow_ip_ranges
}


module "secure_bucket" {
  source     = "./buckets"
  depends_on = [module.dev_netowrk[0]]

  project_id   = var.project_id
  project_name = var.project_name

  gcp_zone   = var.gcp_zone
  gcp_region = var.gcp_region

  unique_name_prefix = var.secure_bucket_unique_name_prefix

}

module "consul_server_firewall_rule" {
  source     = "./firewall/consol_server"
  depends_on = [module.dev_netowrk[0]]

  project_id = var.project_id

  gcp_zone = var.gcp_zone

  network_self_link                = lower(terraform.workspace) == "dev" ? module.dev_netowrk[0].network_self_link : local.unsupport_env
  subnet_public_address_range      = lower(terraform.workspace) == "dev" ? var.dev_subnet_public_address_range : local.unsupport_env
  app_subnet_private_address_range = lower(terraform.workspace) == "dev" ? var.dev_app_subnet_private_address_range : local.unsupport_env
}

module "consul_server" {
  source     = "./consul_server"
  depends_on = [module.secure_bucket, module.consul_server_firewall_rule]

  project_id   = var.project_id
  project_name = var.project_name

  gcp_zone   = var.gcp_zone
  gcp_region = var.gcp_region

  network_self_link                    = lower(terraform.workspace) == "dev" ? module.dev_netowrk[0].network_self_link : local.unsupport_env
  network_subnet_private_address_range = lower(terraform.workspace) == "dev" ? var.dev_app_subnet_private_address_range : local.unsupport_env
  network_subnet_private_self_link     = lower(terraform.workspace) == "dev" ? module.dev_netowrk[0].app_subnet_private_self_link : local.unsupport_env

  secure_bucket_name = module.secure_bucket.bucket_name

  vm_instance_type = var.consule_server_vm_instance_type
  vm_os_image      = var.consule_server_vm_os_image
  vm_os_disk_size  = var.consule_server_vm_os_disk_size
  vm_os_disk_type  = var.consule_server_vm_os_disk_type
  vm_count         = var.consule_server_vm_count
}

module "k8s_cluster_firewall_rule" {
  source     = "./firewall/k8s"
  depends_on = [module.dev_netowrk[0]]

  project_id = var.project_id

  gcp_zone = var.gcp_zone

  network_self_link                    = lower(terraform.workspace) == "dev" ? module.dev_netowrk[0].network_self_link : local.unsupport_env
  network_subnet_public_address_range  = lower(terraform.workspace) == "dev" ? var.dev_subnet_public_address_range : local.unsupport_env
  network_subnet_private_address_range = lower(terraform.workspace) == "dev" ? var.dev_app_subnet_private_address_range : local.unsupport_env

  node_connect_port          = var.k8s_node_connect_port
  gcp_helath_check_ip_ranges = var.gcp_helath_check_ip_ranges
}

module "k8s_cluster" {
  source     = "./k8s"
  depends_on = [module.secure_bucket, module.k8s_cluster_firewall_rule]

  project_id   = var.project_id
  project_name = var.project_name

  gcp_zone   = var.gcp_zone
  gcp_region = var.gcp_region

  network_self_link                    = lower(terraform.workspace) == "dev" ? module.dev_netowrk[0].network_self_link : local.unsupport_env
  network_subnet_private_self_link     = lower(terraform.workspace) == "dev" ? module.dev_netowrk[0].app_subnet_private_self_link : local.unsupport_env
  network_subnet_private_address_range = lower(terraform.workspace) == "dev" ? var.dev_app_subnet_private_address_range : local.unsupport_env

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
  depends_on = [module.dev_netowrk[0]]

  project_id = var.project_id

  gcp_zone = var.gcp_zone

  network_self_link                    = lower(terraform.workspace) == "dev" ? module.dev_netowrk[0].network_self_link : local.unsupport_env
  network_subnet_private_address_range = lower(terraform.workspace) == "dev" ? module.dev_netowrk[0].app_subnet_private_self_link : local.unsupport_env

  frontend_connect_port = var.lb_frontend_connect_port
}

module "haproxy_lb" {
  source     = "./haproxy_lb"
  depends_on = [module.haproxy_lb_firewall_rule]

  project_id   = var.project_id
  project_name = var.project_name

  gcp_zone   = var.gcp_zone
  gcp_region = var.gcp_region

  network_self_link                   = lower(terraform.workspace) == "dev" ? module.dev_netowrk[0].network_self_link : local.unsupport_env
  network_subnet_public_self_link     = lower(terraform.workspace) == "dev" ? module.dev_netowrk[0].subnet_public_self_link : local.unsupport_env
  network_subnet_public_address_range = lower(terraform.workspace) == "dev" ? var.dev_subnet_public_address_range : local.unsupport_env

  secure_bucket_name = module.secure_bucket.bucket_name

  vm_instance_type = var.lb_vm_instance_type
  vm_os_image      = var.lb_vm_os_image
  vm_os_disk_size  = var.lb_vm_os_disk_size
  vm_os_disk_type  = var.lb_vm_os_disk_type
  vm_count         = var.lb_vm_count

  backend_connect_protocol = var.lb_backend_connect_protocol

  frontend_connect_protocol = var.lb_frontend_connect_protocol
  frontend_connect_port     = var.lb_frontend_connect_port
}
