
resource "google_compute_firewall" "cmm_private_vm_incoming_from_iap_ips" {
  name    = "${lower(var.project_id)}-${lower(terraform.workspace)}-private-vm-from-iap-ips"
  network = var.network_self_link

  direction = "INGRESS"
  priority  = 1000

  allow {
    ports    = ["22"]
    protocol = "tcp"
  }

  source_ranges = [var.allow_ip_ranges] #35.235.240.0/20.
  target_tags   = ["iap-ssh-target"]

  description = "Allow Private VM TCP SSH access from IAP IPs"
}
