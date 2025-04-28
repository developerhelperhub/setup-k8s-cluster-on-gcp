output "network_name" {
  value = data.google_compute_network.network.name
}

output "network_subnet_public_name" {
  value = google_compute_subnetwork.network_subnet_public.name
}

output "network_subnet_private_name" {
  value = google_compute_subnetwork.network_subnet_private.name
}
