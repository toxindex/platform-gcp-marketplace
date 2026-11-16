output "get_credentials" {
  value = "gcloud container clusters get-credentials ${google_container_cluster.this.name} --zone ${var.zone} --project ${var.project_id}"
}

output "install_parameters" {
  value = {
    "sage.agent.serviceAccount.gcpServiceAccount"  = google_service_account.vertex.email
    "flow.engine.serviceAccount.gcpServiceAccount" = google_service_account.vertex.email
    "flow.worker.serviceAccount.gcpServiceAccount" = google_service_account.vertex.email
    "sage.agent.vertex.project"                    = var.project_id
    "flow.engine.vertex.project"                   = var.project_id
    "sage.agent.vertex.region"                     = "global"
    "flow.engine.vertex.region"                    = "global"
    "sysrev.api.serviceAccount.gcpServiceAccount"  = google_service_account.vertex.email
    "sysrev.api.vertex.project"                    = var.project_id
    "sysrev.api.vertex.region"                     = "global"
  }
}
