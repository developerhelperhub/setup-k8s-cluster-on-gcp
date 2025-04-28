# Use the default network that GCP provides
data "google_compute_network" "network" {
  name = var.nw_network_name
}

# resource "google_compute_address" "network_internal_ip" {
#   name         = "${lower(var.project_id)}-internal-ip"
#   address_type = "INTERNAL"
#   subnetwork   = var.network_name
#   address      = var.network_address_range
#   region       = var.gcp_region
# }

# Public Subnet
resource "google_compute_subnetwork" "network_subnet_public" {
  name          = "${lower(var.project_id)}-${lower(terraform.workspace)}-public-subnet"
  ip_cidr_range = var.nw_subnet_public_address_range
  region        = var.gcp_region
  network       = var.nw_network_name
}

# Private Subnet
resource "google_compute_subnetwork" "network_subnet_private" {
  name                     = "${lower(var.project_id)}-${lower(terraform.workspace)}-private-subnet"
  ip_cidr_range            = var.nw_subnet_private_address_range
  region                   = var.gcp_region
  network                  = var.nw_network_name
  private_ip_google_access = true
}
