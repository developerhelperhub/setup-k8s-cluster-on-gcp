module "gcp" {
  source = "./modules/gcp"

  project_id   = var.project_id
  project_name = var.project_name

  gcp_project_id = var.gcp_project_id
  gcp_region     = var.gcp_region
  gcp_zone       = var.gcp_zone

  nw_network_name          = var.nw_network_name
  nw_subnet_public_address_range = var.nw_subnet_public_address_range
  nw_subnet_private_address_range = var.nw_subnet_private_address_range

  secure_bucket_unique_name_prefix = var.secure_bucket_unique_name_prefix

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
  
}

module "app" {
  source = "./modules/app"
  depends_on = [ module.gcp ]

}