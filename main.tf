terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.0"
    }
  }

  # backend "gcs" {
  #   bucket = "gramos-terraform-state-prd"
  #   prefix = "sap-car/prd"
  # }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# ----------------------------------------------------------------
# Lectura de Red Compartida (Host Project)
# ----------------------------------------------------------------
data "google_compute_network" "shared_vpc" {
  project = var.host_project_id
  name    = var.shared_vpc_name
}

data "google_compute_subnetwork" "shared_subnet_prd" {
  project = var.host_project_id
  name    = var.subnet_name
  region  = var.region
}

# Terraform obtiene el número de proyecto automáticamente de la API de GCP
data "google_project" "service_project" {
  project_id = var.project_id
}

# ----------------------------------------------------------------
# Permisos IAM Cross-Project para Shared VPC
# ----------------------------------------------------------------

# 1. Asigna permiso al Compute Engine Service Agent de PRD sobre la Subred Host
resource "google_compute_subnetwork_iam_member" "compute_agent_network_user" {
  project    = var.host_project_id
  region     = var.region
  subnetwork = data.google_compute_subnetwork.shared_subnet_prd.name
  role       = "roles/compute.networkUser"
  member     = "serviceAccount:service-${data.google_project.service_project.number}@compute-system.iam.gserviceaccount.com"
}

# ----------------------------------------------------------------
# Módulo de Cómputo (VMs y Discos)
# ----------------------------------------------------------------
module "compute" {
  source = "./modules/compute"

  project_id       = var.project_id
  zone             = var.zone
  subnet_self_link = data.google_compute_subnetwork.shared_subnet_prd.self_link
  os_image         = var.os_image

  instances = local.vm_instances

  # Garantiza que el permiso de red del agente se aplique ANTES de intentar crear las VMs
  depends_on = [
    google_compute_subnetwork_iam_member.compute_agent_network_user
  ]
}