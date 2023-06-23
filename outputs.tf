output "workflow_id" {
  description = "The id of the workflow."
  value       = module.workflow.workflow_id
}

output "scheduler_job_id" {
  description = "Google Cloud scheduler job id"
  value       = module.workflow.scheduler_job_id
}
