#-------------- Server Node Resource --------------
resource "google_service_account" "consul_server_node_sa" {
  account_id   = "${lower(var.project_id)}-consul-sa"
  display_name = "Consule Server Node Service Account"
}

resource "google_storage_bucket_iam_member" "consul_server_bucket_rw_roles" {
  depends_on = [ google_service_account.consul_server_node_sa ]
  bucket = var.secure_bucket_name
  role   = "roles/storage.objectAdmin"  # read & write access

  member = "serviceAccount:${google_service_account.consul_server_node_sa.email}"

}
