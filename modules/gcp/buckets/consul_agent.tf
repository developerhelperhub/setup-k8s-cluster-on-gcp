# Upload the script file to the bucket
resource "google_storage_bucket_object" "upload_consul_agent_script" {
  name   = "consol/agent-node/consul-agent.sh" # destination path in bucket
  bucket = google_storage_bucket.secure_bucket.name
  source = "${path.module}/scripts/consul-agent.sh"
}