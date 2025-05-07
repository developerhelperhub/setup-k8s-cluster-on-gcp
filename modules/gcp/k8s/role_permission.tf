#-------------- Master Node Resource --------------
resource "google_service_account" "k8s_master_node_sa" {
  account_id   = "${lower(var.project_id)}-k8s-master-sa"
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

# #-------------- Worker Node Resource --------------

resource "google_service_account" "k8s_worker_node_sa" {
  depends_on = [ google_compute_instance.k8s_master_node ]
  account_id   = "${lower(var.project_id)}-k8s-worker-sa"
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