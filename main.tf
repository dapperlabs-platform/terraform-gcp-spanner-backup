locals {
  backup_name = var.instance_name
  backup_args = [
    for v in var.database_names : {
      backupId   = "${var.instance_name}-${v}",
      database   = "projects/${var.project_name}/instances/${var.instance_name}/databases/${v}",
      expireTime = var.backup_expire_time,
      parent     = "projects/${var.project_name}/instances/${var.instance_name}",
  }]
  instance_alias_name = var.instance_alias_name != "" ? var.instance_alias_name : var.instance_name
}

module "scheduler_service_account" {
  source     = "github.com/dapperlabs-platform/terraform-google-iam-service-account?ref=v1.1.8"
  project_id = var.project_name
  name       = "${instance_alias_name}-scheduler"
}

resource "google_project_iam_member" "scheduler_workflow_invoker" {
  project = var.project_name
  role    = "roles/workflows.invoker"
  member  = module.scheduler_service_account.iam_email
}

module "workflow_service_account" {
  source     = "github.com/dapperlabs-platform/terraform-google-iam-service-account?ref=v1.1.8"
  project_id = var.project_name
  name       = "${instance_alias_name}-workflow"
}

resource "google_project_iam_member" "workflow_spanner_backup_admin" {
  project = var.project_name
  role    = "roles/spanner.backupAdmin"
  member  = module.workflow_service_account.iam_email
}

module "workflow" {
  source                 = "github.com/dapperlabs-platform/terraform-google-cloud-workflows?ref=v0.1.0"
  project_id             = var.project_name
  workflow_name          = "${instance_alias_name}-backup-workflow"
  region                 = var.backup_schedule_region
  service_account_email  = module.workflow_service_account.email
  service_account_create = false

  workflow_trigger = {
    cloud_scheduler = {
      name                  = "${instance_alias_name}-backup-job"
      cron                  = var.backup_schedule
      time_zone             = var.backup_time_zone
      deadline              = var.backup_deadline
      service_account_email = module.scheduler_service_account.email
      argument              = jsonencode(local.backup_args)
    }
  }
  workflow_source = file("${path.module}/spanner_backup.yaml")

  depends_on = [
    module.scheduler_service_account,
    module.workflow_service_account
  ]
}