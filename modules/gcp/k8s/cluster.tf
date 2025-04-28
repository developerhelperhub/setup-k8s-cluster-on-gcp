#-------------- Master Node Resource --------------
resource "google_service_account" "k8s_master_node_sa" {
  account_id   = "k8s-master-node-sa"
  display_name = "Kubernetes Master Node Service Account"
}

resource "google_storage_bucket_iam_member" "k8s_master_bucket_rw_roles" {
  depends_on = [ google_service_account.k8s_master_node_sa ]
  bucket = var.secure_bucket_name
  role   = "roles/storage.objectAdmin"  # read & write access

  member = "serviceAccount:${google_service_account.k8s_master_node_sa.email}"

  # condition {
  #   title       = "${lower(var.project_id)}-${lower(terraform.workspace)}-k8s-master-node-bucket-rw-access"
  #   description = "Allow access only to a specific folder"
  #   expression  = "resource.name.startsWith('projects/_/buckets/${var.secure_bucket_name}/objects/k8s/master-node/')"
  # }  
}


resource "google_compute_instance" "k8s_master_node" {
  depends_on = [ google_storage_bucket_iam_member.k8s_master_bucket_rw_roles ]
  name         = "${lower(var.project_id)}-${lower(terraform.workspace)}-k8s-master-node"
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
    network = var.network_name
    subnetwork = var.network_subnet_private_name
    # subnetwork_project = var.project_id
    # network_ip         = var.network_address_range
    access_config {} # for external IP
  }

  tags = ["env-${lower(terraform.workspace)}", "k8s-cluster", "k8s-master-node"]

  labels = {
    environment  = "${lower(terraform.workspace)}"
    project_id   = var.project_id
    cluster      = "k8s"
    node         = "master"
    owner        = "devops"
  }

    metadata = {
      startup-script      = file("${path.module}/script/k8s-install-master.sh")
      SECURE_BUCKET_NAME  = var.secure_bucket_name
    }
}

# #-------------- Worker Node Resource --------------

resource "google_service_account" "k8s_worker_node_sa" {
  depends_on = [ google_compute_instance.k8s_master_node ]
  account_id   = "k8s-worker-node-sa"
  display_name = "Kubernetes Worker Node Service Account"
}

resource "google_storage_bucket_iam_member" "k8s_worker_bucket_rw_roles" {
  depends_on = [ google_service_account.k8s_worker_node_sa ]
  bucket = var.secure_bucket_name
  role   = "roles/storage.objectViewer"  # read access

  member = "serviceAccount:${google_service_account.k8s_worker_node_sa.email}"

  # condition {
  #   title       = "${lower(var.project_id)}-${lower(terraform.workspace)}-k8s-worker-node-bucket-r-access"
  #   description = "Allow access only to a specific folder"
  #   expression  = "resource.name.startsWith('projects/_/buckets/${var.secure_bucket_name}/objects/k8s/master-node/')"
  # }  
}

resource "google_compute_instance" "k8s_worker_node" {
  depends_on = [google_storage_bucket_iam_member.k8s_worker_bucket_rw_roles]

  count        = var.node_count
  name         = "${lower(var.project_id)}-${lower(terraform.workspace)}-k8s-worker-node-${count.index + 1}"
  machine_type = var.node_instance_type
  zone         = var.gcp_zone

  boot_disk {
    initialize_params {
      image = var.node_os_image
      size  = var.node_os_disk_size # Optional: disk size in GB
      type  = var.node_os_disk_type # "pd-balanced"  Optional: change to pd-ssd or pd-standard if needed
    }
  }

  service_account {
    email  = google_service_account.k8s_worker_node_sa.email
    scopes = ["cloud-platform"]
  }

  network_interface {
    network = var.network_name
    subnetwork = var.network_subnet_private_name
    # subnetwork_project = var.project_id
    # network_ip         = var.network_address_range
    access_config {} # for external IP
  }

  tags = ["env-${lower(terraform.workspace)}", "k8s-cluster", "k8s-worker-node"]

  labels = {
    environment  = "${lower(terraform.workspace)}"
    project_id   = var.project_id
    cluster      = "k8s"
    node         = "worker"
    owner        = "devops"
  }

  metadata = {
    startup-script      = file("${path.module}/script/k8s-install-node.sh")
    SECURE_BUCKET_NAME  = var.secure_bucket_name
  }

}

