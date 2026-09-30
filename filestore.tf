# ----------------------------------------------------------------
# Google Cloud Filestore Regional (HA Multi-Zona) para SAP CAR PRD
# ----------------------------------------------------------------
resource "google_filestore_instance" "sap_nfs" {
  project  = var.project_id
  name     = "filestore-sap-shared-prd"
  location = var.region
  tier     = "ENTERPRISE"

  file_shares {
    capacity_gb = 1024
    name        = "nfs_sap_shared"
  }

  networks {
    network = data.google_compute_network.shared_vpc.id
    modes   = ["MODE_IPV4"]
  }

  description = "NFS HA compartido para SAP CAR PRD (/sapmnt/CAP, ASCS/ERS)"

  depends_on = [
    google_project_service.apis
  ]
}
