variable "backup_deadline" {
  description = "The deadline for the backup schedule"
  type        = string
  default     = "320s"
}

variable "backup_enabled" {
  description = "Whether to enable the backup schedule"
  type        = bool
  default     = true
}

variable "backup_expire_time" {
  description = "Seconds until the backup expires"
  type        = number
  default     = 86400
}

variable "backup_schedule" {
  description = "The Backup Schedule in CRON format"
  type        = string
  default     = "0 0 * * *"
}

variable "backup_schedule_region" {
  description = "The schedule to be enabled on scheduler to trigger spanner DB backup"
  type        = string
  default     = "us-west1"
}

variable "backup_time_zone" {
  description = "The timezone to be used for the backup schedule"
  type        = string
  default     = "America/Vancouver"
}

variable "database_names" {
  description = "The databases to backup"
  type        = list(string)
}

variable "instance_name" {
  description = "The instance containing the database to backup"
  type        = string
}

variable "project_name" {
  description = "The project name to deploy to"
  type        = string
}
