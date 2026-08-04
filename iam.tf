# ----------------------------------------------------------------
# Permisos IAM para STONITH / Fencing de Pacemaker (fence_gce)
# ----------------------------------------------------------------
resource "google_project_iam_member" "stonith_compute_admin" {
  project = var.project_id
  role    = "roles/compute.instanceAdmin.v1"
  member  = "serviceAccount:${data.google_project.service_project.number}-compute@developer.gserviceaccount.com"
}
