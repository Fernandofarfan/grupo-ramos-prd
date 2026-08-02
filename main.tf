terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.0"
    }
  }

  backend "gcs" {
    # Bucket de backend state; ajustar segun bucket de PRD existente
    # bucket = "gramos-terraform-state-prd"
    # prefix = "sap-car/prd"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

data "google_compute_network" "shared_vpc" {
  project = var.host_project_id
  name    = var.shared_vpc_name
}

data "google_compute_subnetwork" "shared_subnet_prd" {
  project = var.host_project_id
  name    = var.subnet_name
  region  = var.region
}

module "compute" {
  source = "./modules/compute"

  project_id       = var.project_id
  zone             = var.zone
  subnet_self_link = data.google_compute_subnetwork.shared_subnet_prd.self_link
  os_image         = var.os_image
  depends_on       = [google_project_service.apis]

  instances = local.vm_instances
}
