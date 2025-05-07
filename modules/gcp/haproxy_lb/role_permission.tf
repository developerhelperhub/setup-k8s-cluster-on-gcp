#-------------- Server Node Resource --------------
resource "google_service_account" "lb_haproxy_server_node_sa" {
  account_id   = "${lower(var.project_id)}-lb-haproxy-sa"
  display_name = "Load Balancer HAProxy Node Service Account"
}

resource "google_storage_bucket_iam_member" "lb_haproxy_bucket_rw_roles" {
  depends_on = [ google_service_account.lb_haproxy_server_node_sa ]
  bucket = var.secure_bucket_name
  role   = "roles/storage.objectViewer"  # read access

  member = "serviceAccount:${google_service_account.lb_haproxy_server_node_sa.email}"

}
