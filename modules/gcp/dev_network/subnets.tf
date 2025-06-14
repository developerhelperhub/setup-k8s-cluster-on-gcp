# Public Subnet
resource "google_compute_subnetwork" "dev_subnet_public" {
  name   = "dev-public-subnet"
  region = var.gcp_region

  network = google_compute_network.dev_vpc.name

  ip_cidr_range = var.dev_subnet_public_address_range
  
  private_ip_google_access = true
}

# Private Subnet
resource "google_compute_subnetwork" "dev_app_subnet_private" {
  name   = "dev-app-private-subnet"
  region = var.gcp_region

  network = google_compute_network.dev_vpc.name

  ip_cidr_range = var.dev_app_subnet_private_address_range

  private_ip_google_access = true
}

# Private Subnet
resource "google_compute_subnetwork" "dev_db_subnet_private" {
  name   = "dev-db-private-subnet"
  region = var.gcp_region

  network = google_compute_network.dev_vpc.name

  ip_cidr_range = var.dev_db_subnet_private_address_range

  private_ip_google_access = true
}
