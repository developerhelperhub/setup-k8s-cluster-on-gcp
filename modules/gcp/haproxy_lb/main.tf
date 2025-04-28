# Create the VM instance in the default network
resource "google_compute_instance" "haproxy_lb_vm" {
  count        = var.vm_count
  name         = "${lower(var.project_id)}-${lower(terraform.workspace)}-haproxy-lb-${var.vm_count}"
  machine_type = var.vm_instance_type
  zone         = var.gcp_zone

  boot_disk {
    initialize_params {
      image = var.vm_os_image
      size  = var.vm_os_disk_size # Optional: disk size in GB
      type  = var.vm_os_disk_type # "pd-balanced"  Optional: change to pd-ssd or pd-standard if needed
    }
  }

  network_interface {
    network = var.network_name
    subnetwork = var.network_subnet_public_name
    access_config {} # for external IP
  }

  tags = ["env-${lower(terraform.workspace)}", "haprox-lb", "vm"]

  labels = {
    environment = "${lower(terraform.workspace)}"
    project_id  = var.project_id
    cluster     = "haprox-lb"
    owner       = "devops"
  }

  metadata = {
    startup-script            = file("${path.module}/install-script.sh")
    FRONTEND_CONNECT_PORT     = var.frontend_connect_port
    FRONTEND_CONNECT_PROTOCOL = var.frontend_connect_protocol
    BACKEND_CONNECT_PROTOCOL  = var.backend_connect_protocol
    BACKEND_K8S_WORKER_IPS    = var.backend_k8s_worker_ips
    BACKEND_K8S_WORKER_PORT   = var.backend_k8s_worker_port
  }
}
