locals {
  backup_name = var.instance_name
  backup_args = [
    for v in var.database_names : {
      backupId   = "${var.instance_name}-${v}-backup",
      database   = "projects/${var.project_name}/instances/${var.instance_name}/databases/${v}",
      expireTime = var.backup_expire_time,
      parent     = "projects/${var.project_name}/instances/${var.instance_name}",
  }]
}

module "scheduler_service_account" {
  source     = "github.com/dapperlabs-platform/terraform-google-iam-service-account?ref=v1.1.8"
  project_id = var.project_name
  name       = "${var.instance_name}-scheduler"
  iam_project_roles = {
    "${var.project_name}" = [
      "roles/workflows.invoker"
    ]
  }
}

module "workflow_service_account" {
  source     = "github.com/dapperlabs-platform/terraform-google-iam-service-account?ref=v1.1.8"
  project_id = var.project_name
  name       = "${var.instance_name}-workflow"
  iam_project_roles = {
    "${var.project_name}" = [
      "roles/spanner.backupAdmin"
    ]
  }
}

module "workflow" {
  source                 = "github.com/dapperlabs-platform/terraform-google-cloud-workflows?ref=v0.1.0"
  project_id             = var.project_name
  workflow_name          = "${var.instance_name}-backup-workflow"
  region                 = var.backup_schedule_region
  service_account_email  = module.workflow_service_account.email
  service_account_create = false

  workflow_trigger = {
    cloud_scheduler = {
      name                  = "${var.instance_name}-backup-job"
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