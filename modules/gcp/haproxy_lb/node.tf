locals {
  server_node_name_pefix = "${lower(var.project_id)}-${lower(terraform.workspace)}-haproxy-lb"
}

# Create the VM instance in the default network
resource "google_compute_instance" "haproxy_lb_vm" {
  depends_on = [ google_service_account.lb_haproxy_server_node_sa ]

  count        = var.vm_count
  name         = "${local.server_node_name_pefix}-${count.index + 1}"
  machine_type = var.vm_instance_type
  zone         = var.gcp_zone

  boot_disk {
    initialize_params {
      image = var.vm_os_image
      size  = var.vm_os_disk_size # Optional: disk size in GB
      type  = var.vm_os_disk_type # "pd-balanced"  Optional: change to pd-ssd or pd-standard if needed
    }
  }


  service_account {
    email  = google_service_account.lb_haproxy_server_node_sa.email
    scopes = ["cloud-platform"]
  }


  network_interface {
    network    = var.network_name
    subnetwork = var.network_subnet_public_name
    access_config {} # for external IP
  }

  tags = ["env-${lower(terraform.workspace)}", "haprox-lb", "consul-agent"]

  labels = {
    environment = "${lower(terraform.workspace)}"
    project_id  = var.project_id
    cluster     = "haprox-lb"
    owner       = "devops"
  }

  metadata = {
    startup-script            = file("${path.module}/install-script.sh")
    SECURE_BUCKET_NAME        = var.secure_bucket_name
    FRONTEND_CONNECT_PORT     = var.frontend_connect_port
    FRONTEND_CONNECT_PROTOCOL = var.frontend_connect_protocol
    BACKEND_CONNECT_PROTOCOL  = var.backend_connect_protocol
  }
}
