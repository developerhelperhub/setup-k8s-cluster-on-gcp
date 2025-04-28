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

module "k8s_cluster_firewall_rule" {
  source     = "./k8s_firewall_rule"
  depends_on = [module.app_network]

  project_id   = var.project_id

  gcp_zone   = var.gcp_zone

  network_name                         = module.app_network.network_name
  network_subnet_public_address_range  = var.nw_subnet_public_address_range
  network_subnet_private_address_range = var.nw_subnet_private_address_range

  node_connect_port = var.k8s_node_connect_port

}

module "k8s_cluster" {
  source     = "./k8s"
  depends_on = [module.k8s_cluster_firewall_rule]

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

}




module "haproxy_lb" {
  source = "./haproxy_lb"
  depends_on = [ module.k8s_cluster ]

  project_id   = var.project_id
  project_name = var.project_name

  gcp_zone   = var.gcp_zone
  gcp_region = var.gcp_region

  network_name = module.app_network.network_name
  network_subnet_public_address_range = var.nw_subnet_public_address_range
  network_subnet_public_name = module.app_network.network_subnet_public_name

  vm_instance_type = var.lb_vm_instance_type
  vm_os_image= var.lb_vm_os_image
  vm_os_disk_size= var.lb_vm_os_disk_size
  vm_os_disk_type= var.lb_vm_os_disk_type
  vm_count= var.lb_vm_count

  backend_k8s_worker_ips = module.k8s_cluster.worker_node_ips
  backend_k8s_worker_port = var.k8s_node_connect_port
  backend_connect_protocol = var.lb_backend_connect_protocol

  frontend_connect_protocol = var.lb_frontend_connect_protocol
  frontend_connect_port = var.lb_frontend_connect_port
}
