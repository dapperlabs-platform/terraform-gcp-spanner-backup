variable "gcp_project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "uniform_bucket_level_access" {
  type    = bool
  default = false
}

variable "schedule" {
  type        = string
  description = "schedule on which you want to call the cloud scheduler job. The below is set to run every 1 hour"
  default     = "0 1 * * *"
  //Every day at 1am
}

variable "time_zone" {
  type    = string
  default = "America/Vancouver"
}

variable "pubsub_topic" {
  type = string
}

variable "local_output_path" {
  type    = string
  default = "build"
}

variable "database_ids" {
  type        = set(string)
  description = "Spanner Databases you want to backup"
}

variable "spanner_instance_id" {
  type        = string
  description = "Spanner Instance ID where you database is located that you want to backup"
}

variable "location" {
  type        = string
  description = "location for App Engine"
}
