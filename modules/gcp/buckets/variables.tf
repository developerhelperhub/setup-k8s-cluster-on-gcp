variable "gcp_zone" {
  description = "GCP zone to deploy to"
  type        = string
}

variable "gcp_region" {
  description = "GCP region to deploy to"
  type        = string
}

variable "project_id" {
  description = "Id of the development project"
  type        = string
}

variable "project_name" {
  description = "Name of the development project"
  type        = string
}

variable "unique_name_prefix" {
  description = "Unique prefix name of bucket"
  type        = string
}