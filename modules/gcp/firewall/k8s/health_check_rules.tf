resource "google_compute_firewall" "k8s_incoming_from_from_gcp_helath_service" {
  name    = "${lower(var.project_id)}-${lower(terraform.workspace)}-k8s-incoming-from-gcp-helath-service"
  network = var.network_name

  allow {
    protocol = "tcp"
    ports    = ["10250"]
  }

  source_ranges = var.gcp_helath_check_ip_ranges # GCP health check ranges

  target_tags = ["k8s-master-node", "k8s-worker-node"] # This should match tags on your VM instances

  direction = "INGRESS"
  priority  = 1000
}

