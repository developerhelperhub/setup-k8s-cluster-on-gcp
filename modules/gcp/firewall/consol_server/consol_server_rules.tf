# Firewall rule to allow HTTP traffic on port 80
resource "google_compute_firewall" "consol_node_incoming_from_consol_server_allow" {
  name    = "${lower(var.project_id)}-${lower(terraform.workspace)}-consol-incoming-from-consol-server"
  network = var.network_name

  allow {
    protocol = "tcp"
    ports    = [8301, 8600, 8300]
  }

  allow {
    protocol = "udp"
    ports    = [8600]
  }

  source_tags = ["consul-server", "consul-agent"]
  target_tags = ["consul-server", "consul-agent"]

  source_ranges = [var.network_subnet_private_address_range, var.network_subnet_public_address_range]
}

# Firewall rule to allow HTTP traffic on port 80
resource "google_compute_firewall" "consol_node_outgoing_to_consol_server_allow" {
  name    = "${lower(var.project_id)}-${lower(terraform.workspace)}-consol-outgoing-to-consol-server"
  network = var.network_name

  allow {
    protocol = "tcp"
    ports    = [8301, 8600, 8300]
  }

  allow {
    protocol = "udp"
    ports    = [8600]
  }

  source_tags = ["consul-server", "consul-agent"]
  target_tags = ["consul-server", "consul-agent"]

  source_ranges = [var.network_subnet_private_address_range, var.network_subnet_public_address_range]
}