resource "google_project_service" "apis" {
  for_each = toset([
    "compute.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "iam.googleapis.com",
    "iap.googleapis.com",
    "oslogin.googleapis.com",
  ])

  project                    = var.project_id
  service                    = each.key
  disable_dependent_services = false
  disable_on_destroy         = false
}
