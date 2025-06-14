

# Use the development network that GCP provides
resource "google_compute_network" "dev_vpc" {
  name                    = "development-vpc"
  project                 = var.gcp_project_id
  auto_create_subnetworks = false
}