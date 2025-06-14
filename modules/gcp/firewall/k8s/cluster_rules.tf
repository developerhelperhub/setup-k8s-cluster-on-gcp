# ----------------- Master Node and Worker Node rules ---------------------

# Firewall rule to allow TCP port 10250 from Haproxy LB
# Allow Master Node to Talk to Worker Node (Private Subnet)
resource "google_compute_firewall" "k8s_wroker_incoming_from_k8s_master_allow" {
  name    = "${lower(var.project_id)}-${lower(terraform.workspace)}-k8s-wroker-incoming-from-k8s-master"
  network = var.network_self_link

  direction = "INGRESS"
  priority  = 1000

  source_ranges = [var.network_subnet_private_address_range] #10.0.1.0/24 Only private subnet (Master source)

  #Why use multiple tags?
  #The master needs to connect to workers (for kubelet, pods, etc.)
  #The workers also sometimes connect to the master (for control plane APIs, DNS, etc.)
  source_tags = ["k8s-master-node", "k8s-worker-node"]
  target_tags = ["k8s-master-node", "k8s-worker-node"]

  allow {
    protocol = "tcp"
    ports    = ["10250", "30000-32767", "10255", "6443"]
  }

  # allow {
  #   protocol = "all"
  # }

  description = "Allow Incoming Master VM to access K8s Worker VM"
}

resource "google_compute_firewall" "k8s_wroker_egress_to_k8s_master_allow" {
  name    = "${lower(var.project_id)}-${lower(terraform.workspace)}-k8s-wroker-egress-to-k8s-master"
  network = var.network_self_link

  direction = "EGRESS"
  priority  = 1000

  destination_ranges = [var.network_subnet_private_address_range] #10.0.1.0/24 Only private subnet (Master source)

  #Why use multiple tags?
  #The master needs to connect to workers (for kubelet, pods, etc.)
  #The workers also sometimes connect to the master (for control plane APIs, DNS, etc.)
  target_tags = ["k8s-master-node", "k8s-worker-node"]

  allow {
    protocol = "tcp"
    ports    = ["6443", "443"]
  }

  # allow {
  #   protocol = "all"
  # }

  description = "Allow Outgoing K8s Worker VM to access Master node"
}