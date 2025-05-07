# Firewall rule to allow HTTP traffic on port 80
resource "google_compute_firewall" "haproxy_lb_allow_http" {
  name    = "${lower(var.project_id)}-${lower(terraform.workspace)}-haproxy-lb-allow-http"
  network = var.network_name

  allow {
    protocol = "tcp"
    ports    = [var.frontend_connect_port]
  }

  source_ranges = ["0.0.0.0/0"]
}