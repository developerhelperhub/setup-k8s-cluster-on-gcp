locals {
  master_node_name_pefix = "${lower(var.project_id)}-${lower(terraform.workspace)}-k8s-master-node"
  worker_node_name_pefix = "${lower(var.project_id)}-${lower(terraform.workspace)}-k8s-worker-node"
}


#-------------- Master Node Resource --------------

resource "google_compute_instance" "k8s_master_node" {
  depends_on   = [google_service_account.k8s_master_node_sa, google_storage_bucket_iam_member.k8s_master_bucket_rw_roles]
  name         = local.master_node_name_pefix
  machine_type = var.master_instance_type
  zone         = var.gcp_zone

  boot_disk {
    initialize_params {
      image = var.master_os_image
      size  = var.master_os_disk_size # Optional: disk size in GB
      type  = var.master_os_disk_type # "pd-balanced"  Optional: change to pd-ssd or pd-standard if needed
    }
  }

  service_account {
    email  = google_service_account.k8s_master_node_sa.email
    scopes = ["cloud-platform"]
  }

  network_interface {
    network    = var.network_name
    subnetwork = var.network_subnet_private_name
    # subnetwork_project = var.project_id
    # network_ip         = var.network_address_range
    access_config {} # for external IP
  }

  tags = ["env-${lower(terraform.workspace)}", "k8s-cluster", "k8s-master-node"]

  labels = {
    environment = "${lower(terraform.workspace)}"
    project_id  = var.project_id
    cluster     = "k8s"
    node        = "master"
    owner       = "devops"
  }

  metadata = {
    startup-script     = file("${path.module}/script/k8s-install-master.sh")
    SECURE_BUCKET_NAME = var.secure_bucket_name
  }
}

# # #-------------- Worker Node Resource --------------

# resource "google_compute_instance" "k8s_worker_node" {
#   depends_on = [google_compute_instance.k8s_master_node, google_storage_bucket_iam_member.k8s_worker_bucket_rw_roles]

#   count        = var.node_count
#   name         = "${local.worker_node_name_pefix}-${count.index + 1}"
#   machine_type = var.node_instance_type
#   zone         = var.gcp_zone

#   boot_disk {
#     initialize_params {
#       image = var.node_os_image
#       size  = var.node_os_disk_size # Optional: disk size in GB
#       type  = var.node_os_disk_type # "pd-balanced"  Optional: change to pd-ssd or pd-standard if needed
#     }
#   }

#   service_account {
#     email  = google_service_account.k8s_worker_node_sa.email
#     scopes = ["cloud-platform"]
#   }

#   network_interface {
#     network    = var.network_name
#     subnetwork = var.network_subnet_private_name
#     # subnetwork_project = var.project_id
#     # network_ip         = var.network_address_range
#     access_config {} # for external IP
#   }

#   tags = ["env-${lower(terraform.workspace)}", "k8s-cluster", "k8s-worker-node", "consul-agent"]

#   labels = {
#     environment = "${lower(terraform.workspace)}"
#     project_id  = var.project_id
#     cluster     = "k8s"
#     node        = "worker"
#     owner       = "devops"
#   }

#   metadata = {
#     startup-script        = file("${path.module}/script/k8s-install-node.sh")
#     SECURE_BUCKET_NAME    = var.secure_bucket_name
#     K8S_NODE_CONNECT_PORT = var.k8s_node_connect_port
#   }

# }



resource "google_compute_instance_template" "k8s_worker_node_tmplate" {
  depends_on = [google_compute_instance.k8s_master_node, google_storage_bucket_iam_member.k8s_worker_bucket_rw_roles]

  name         = "${local.worker_node_name_pefix}-template"
  machine_type = var.node_instance_type
  region       = var.gcp_region

  disk {
    auto_delete  = true
    boot         = true
    disk_size_gb = var.node_os_disk_size
    source_image = var.node_os_image
    disk_type    = var.node_os_disk_type # "pd-balanced"  Optional: change to pd-ssd or pd-standard if needed
  }

  service_account {
    email  = google_service_account.k8s_worker_node_sa.email
    scopes = ["cloud-platform"]
  }

  network_interface {
    network    = var.network_name
    subnetwork = var.network_subnet_private_name
    # subnetwork_project = var.project_id
    # network_ip         = var.network_address_range
    access_config {} # for external IP
  }

  tags = ["env-${lower(terraform.workspace)}", "k8s-cluster", "k8s-worker-node", "consul-agent"]

  labels = {
    environment = "${lower(terraform.workspace)}"
    project_id  = var.project_id
    cluster     = "k8s"
    node        = "worker"
    owner       = "devops"
  }

  metadata = {
    startup-script        = file("${path.module}/script/k8s-install-node.sh")
    SECURE_BUCKET_NAME    = var.secure_bucket_name
    K8S_NODE_CONNECT_PORT = var.k8s_node_connect_port
  }

}

resource "google_compute_health_check" "k8s_worker_node_health_check" {
  depends_on          = [google_compute_instance_template.k8s_worker_node_tmplate]
  name                = "${local.worker_node_name_pefix}-health-check"
  check_interval_sec  = var.health_check_interval_sec
  timeout_sec         = var.health_timeout_sec
  healthy_threshold   = var.health_healthy_threshold
  unhealthy_threshold = var.health_unhealthy_threshold

  tcp_health_check {
    port = 10250
  }
}

resource "google_compute_region_instance_group_manager" "k8s_worker_node_mig" {
  depends_on         = [google_compute_health_check.k8s_worker_node_health_check]
  name               = "${local.worker_node_name_pefix}-mig"
  base_instance_name = local.worker_node_name_pefix
  region             = var.gcp_region

  version {
    instance_template = google_compute_instance_template.k8s_worker_node_tmplate.id
  }

  target_size = var.mig_target_size

  auto_healing_policies {
    health_check      = google_compute_health_check.k8s_worker_node_health_check.id
    initial_delay_sec = var.mig_healing_policies_initial_delay_sec
  }

  distribution_policy_zones = [
    var.gcp_zone
  ]

}

resource "google_compute_region_autoscaler" "k8s_worker_node_autoscaler" {
  depends_on = [google_compute_region_instance_group_manager.k8s_worker_node_mig]
  name       = "${local.worker_node_name_pefix}-autoscaler"
  target     = google_compute_region_instance_group_manager.k8s_worker_node_mig.self_link

  autoscaling_policy {
    max_replicas    = var.scale_max_replicas
    min_replicas    = var.scale_min_replicas
    cooldown_period = var.scale_cooldown_period

    cpu_utilization {
      target = var.scale_cpu_utilization
    }
  }

}
