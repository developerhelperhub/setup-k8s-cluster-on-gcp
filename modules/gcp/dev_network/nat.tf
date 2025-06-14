resource "google_compute_address" "dev_nat_ip" {
  name     = "dev-nat-ip"

  project = var.gcp_project_id
  region  = var.gcp_region
}

resource "google_compute_router" "dev_router_nat" {
  name     = "dev-router-nat"

  project = var.gcp_project_id
  region  = var.gcp_region

  network = google_compute_network.dev_vpc.id

}

resource "google_compute_router_nat" "dev_router_nat_config" {
  depends_on = [google_compute_address.dev_nat_ip, google_compute_router.dev_router_nat, google_compute_subnetwork.dev_app_subnet_private, google_compute_subnetwork.dev_db_subnet_private]
  name       = "dev-router-nat-config"

  project = var.gcp_project_id
  region  = var.gcp_region

  router = google_compute_router.dev_router_nat.name

  nat_ip_allocate_option = "MANUAL_ONLY"
  nat_ips                = [google_compute_address.dev_nat_ip.self_link] # Provied static IP for NAT gateway

  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  # subnetwork {
  #   name                    = google_compute_subnetwork.dev_subnet_public.name
  #   source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  # }

  subnetwork {
    name                    = google_compute_subnetwork.dev_app_subnet_private.name
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }

  subnetwork {
    name                    = google_compute_subnetwork.dev_db_subnet_private.name
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }


}
