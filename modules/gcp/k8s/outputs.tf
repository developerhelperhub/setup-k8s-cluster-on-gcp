output "master_node_sa_email" {
  value = google_service_account.k8s_master_node_sa.email
}

output "master_node_ip" {
  value = google_compute_instance.k8s_master_node.network_interface[0].network_ip
}
