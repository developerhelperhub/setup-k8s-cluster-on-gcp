module "gcp" {
  source = "./modules/gcp"

  project_id   = var.project_id
  project_name = var.project_name

  gcp_project_id             = var.gcp_project_id
  gcp_region                 = var.gcp_region
  gcp_zone                   = var.gcp_zone
  gcp_helath_check_ip_ranges = var.gcp_helath_check_ip_ranges

  nw_network_name                 = var.nw_network_name
  nw_subnet_public_address_range  = var.nw_subnet_public_address_range
  nw_subnet_private_address_range = var.nw_subnet_private_address_range

  secure_bucket_unique_name_prefix = var.secure_bucket_unique_name_prefix

  consule_server_vm_instance_type = var.consule_server_vm_instance_type
  consule_server_vm_os_image      = var.consule_server_vm_os_image
  consule_server_vm_os_disk_size  = var.consule_server_vm_os_disk_size
  consule_server_vm_os_disk_type  = var.consule_server_vm_os_disk_type
  consule_server_vm_count         = var.consule_server_vm_count

  lb_vm_instance_type = var.lb_vm_instance_type
  lb_vm_os_image      = var.lb_vm_os_image
  lb_vm_os_disk_size  = var.lb_vm_os_disk_size
  lb_vm_os_disk_type  = var.lb_vm_os_disk_type
  lb_vm_count         = var.lb_vm_count

  lb_backend_connect_protocol  = var.lb_backend_connect_protocol
  lb_frontend_connect_port     = var.lb_frontend_connect_port
  lb_frontend_connect_protocol = var.lb_frontend_connect_protocol

  k8s_master_instance_type = var.k8s_master_instance_type
  k8s_master_os_image      = var.k8s_master_os_image
  k8s_master_os_disk_size  = var.k8s_master_os_disk_size
  k8s_master_os_disk_type  = var.k8s_master_os_disk_type

  k8s_node_instance_type = var.k8s_node_instance_type
  k8s_node_os_image      = var.k8s_node_os_image
  k8s_node_os_disk_size  = var.k8s_node_os_disk_size
  k8s_node_os_disk_type  = var.k8s_node_os_disk_type
  k8s_node_count         = var.k8s_node_count
  k8s_node_connect_port  = var.k8s_node_connect_port

  k8s_node_scale_cpu_utilization                  = var.k8s_node_scale_cpu_utilization
  k8s_node_scale_max_replicas                     = var.k8s_node_scale_max_replicas
  k8s_node_scale_cooldown_period                  = var.k8s_node_scale_cooldown_period
  k8s_node_scale_min_replicas                     = var.k8s_node_scale_min_replicas
  k8s_node_health_check_interval_sec              = var.k8s_node_health_check_interval_sec
  k8s_node_health_timeout_sec                     = var.k8s_node_health_timeout_sec
  k8s_node_health_healthy_threshold               = var.k8s_node_health_healthy_threshold
  k8s_node_health_unhealthy_threshold             = var.k8s_node_health_unhealthy_threshold
  k8s_node_mig_healing_policies_initial_delay_sec = var.k8s_node_mig_healing_policies_initial_delay_sec
  k8s_node_mig_target_size                        = var.k8s_node_mig_target_size
}

module "app" {
  source     = "./modules/app"
  depends_on = [module.gcp]

}
