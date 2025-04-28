resource "google_storage_bucket" "secure_bucket" {
  name     = "${lower(var.project_id)}-${lower(terraform.workspace)}-${var.unique_name_prefix}-secure-bukcet"
  location = var.gcp_region

  force_destroy               = true
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"

  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      age = 2
    }
  }

  labels = {
    environment  = "${lower(terraform.workspace)}"
    project_id   = var.project_id
    storage      = "bucket"
    type         = "secure"
    owner        = "devops"
  }
}
