#--------------------- Development Project Configuration ---------------------
#Development Project configuration, this project configuration is used to maintain resources for this project. eg: project_id will be used to create the GCP resources
project_id   = "myp"
project_name = "My Project"

# --------------------- GCP Project and Regsion Configuration ---------------------
gcp_region = "us-east1"
gcp_zone   = "us-east1-b"

#--------------------- Network Configuration ---------------------
nw_network_name          = "default"
nw_subnet_public_address_range = "10.0.0.0/24"
nw_subnet_private_address_range = "10.0.1.0/24"

#--------------------- Secure Bucket ---------------------
secure_bucket_unique_name_prefix = "18292002222x"

#--------------------- Loadbalancer (LB) Configuration ---------------------
lb_vm_instance_type          = "e2-micro"
lb_vm_os_image               = "ubuntu-minimal-2204-jammy-v20250408"
lb_vm_os_disk_size           = 10
lb_vm_os_disk_type           = "pd-balanced"
lb_vm_count                  = 1
lb_backend_connect_protocol  = "http"
lb_frontend_connect_protocol = "http"
lb_frontend_connect_port     = 80

#--------------------- K8s Configuration ---------------------
k8s_master_instance_type = "e2-medium"
k8s_master_os_image      = "ubuntu-minimal-2204-jammy-v20250408"
k8s_master_os_disk_size  = 10
k8s_master_os_disk_type  = "pd-balanced"

k8s_node_instance_type = "e2-medium"
k8s_node_os_image      = "ubuntu-minimal-2204-jammy-v20250408"
k8s_node_count         = 1
k8s_node_os_disk_size  = 10
k8s_node_os_disk_type  = "pd-balanced"
k8s_node_connect_port  = "30080"
