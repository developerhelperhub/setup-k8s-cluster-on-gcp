output "network_self_link" {
  value = google_compute_network.dev_vpc.self_link
}

output "subnet_public_self_link" {
  value = google_compute_subnetwork.dev_subnet_public.self_link
}

output "app_subnet_private_self_link" {
  value = google_compute_subnetwork.dev_app_subnet_private.self_link
}

output "db_subnet_private_self_link" {
  value = google_compute_subnetwork.dev_db_subnet_private.self_link
}


