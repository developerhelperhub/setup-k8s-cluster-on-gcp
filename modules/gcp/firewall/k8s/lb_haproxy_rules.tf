# ----------------- HAPorxy LB and Worker Node rules ---------------------

# Firewall rule to allow TCP incoming traffic on node port 30080 from Haproxy LB
# Allow HAProxy to Talk to Backend (Private Subnet)
resource "google_compute_firewall" "k8s_incoming_from_haproxy_lb_allow" {
  name    = "${lower(var.project_id)}-${lower(terraform.workspace)}-k8s-incoming-from-haproxy-lb"
  network = var.network_self_link

  direction = "INGRESS"
  priority  = 1000

  source_ranges = [var.network_subnet_public_address_range] #10.0.0.0/24 Only public subnet (HAProxy source)

  target_tags = ["k8s-worker-node"] # Add this tag to worker node VMs

  allow {
    protocol = "tcp"
    ports    = [var.node_connect_port]
  }

  description = "Allow Incoming HAProxy VM to access K8s NodePorts"
}

# Firewall rule to allow TCP outgoing from traffic on node port 30080 to Haproxy LB
# Allow Backend VMs to Accept Traffic Only from HAProxy
resource "google_compute_firewall" "k8s_outgoing_to_haproxy_lb_allow" {
  name    = "${lower(var.project_id)}-${lower(terraform.workspace)}-k8s-outgoing-to-haproxy-lb-allow"
  network = var.network_self_link

  direction = "EGRESS"
  priority  = 1000

  destination_ranges = [var.network_subnet_private_address_range] #10.0.1.0/24 Only private subnet (HAProxy source)

  target_tags = ["haprox-lb"] # Add this tag to lb haproxy VMs

  allow {
    protocol = "tcp"
    ports    = [var.node_connect_port]
  }

  description = "Allow Outgoing access K8s NodePorts to HAProxy VM"
}
