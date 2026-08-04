# ----------------------------------------------------------------
# Filestore (Almacenamiento Compartido NFS 1TB para SAP /sapmnt)
# ----------------------------------------------------------------
resource "google_filestore_instance" "sap_nfs" {
  project  = var.project_id
  name     = "filestore-sap-shared"
  location = var.zone
  tier     = "BASIC_HDD"

  file_shares {
    capacity_gb = 1024
    name        = "nfs_sap_shared"
  }

  networks {
    network = data.google_compute_network.shared_vpc.name
    modes   = ["MODE_IPV4"]
  }

  depends_on = [
    google_project_service.apis
  ]
}
