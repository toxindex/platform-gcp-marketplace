terraform {
  required_version = ">= 1.5"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.0"
    }
  }
}

provider "google" {
  project = var.project_id
}

locals {
  ksas = ["sage-agent", "flow-engine", "flow-worker", "sysrev-api"]
}

resource "google_project_service" "this" {
  for_each           = toset(["container.googleapis.com", "aiplatform.googleapis.com"])
  service            = each.value
  disable_on_destroy = false
}

resource "google_container_cluster" "this" {
  name                = var.cluster_name
  location            = var.zone
  initial_node_count  = 0
  deletion_protection = true

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  depends_on = [google_project_service.this]
}

resource "google_container_node_pool" "general" {
  name     = "general"
  cluster  = google_container_cluster.this.id
  location = var.zone

  autoscaling {
    min_node_count = var.general_min_nodes
    max_node_count = var.general_max_nodes
  }

  node_config {
    machine_type = var.general_machine_type
    disk_size_gb = 200
    oauth_scopes = ["https://www.googleapis.com/auth/cloud-platform"]

    workload_metadata_config {
      mode = "GKE_METADATA"
    }
  }
}

resource "google_container_node_pool" "gpu" {
  count      = var.gpu_pool ? 1 : 0
  name       = "gpu"
  cluster    = google_container_cluster.this.id
  location   = var.zone
  node_count = 1

  node_config {
    machine_type = var.gpu_machine_type
    disk_size_gb = 200
    oauth_scopes = ["https://www.googleapis.com/auth/cloud-platform"]

    guest_accelerator {
      type  = var.gpu_type
      count = 1

      gpu_driver_installation_config {
        gpu_driver_version = "LATEST"
      }

      gpu_sharing_config {
        gpu_sharing_strategy       = "TIME_SHARING"
        max_shared_clients_per_gpu = 4
      }
    }

    workload_metadata_config {
      mode = "GKE_METADATA"
    }
  }
}

resource "google_service_account" "vertex" {
  account_id   = "toxindex-vertex"
  display_name = "ToxIndex Vertex AI"
}

resource "google_project_iam_member" "vertex" {
  project = var.project_id
  role    = "roles/aiplatform.user"
  member  = google_service_account.vertex.member
}

resource "google_service_account_iam_member" "workload_identity" {
  for_each           = toset(local.ksas)
  service_account_id = google_service_account.vertex.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[${var.namespace}/${each.value}]"

  depends_on = [google_container_cluster.this]
}
