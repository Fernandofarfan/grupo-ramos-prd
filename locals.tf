locals {
  vm_instances = [
    # ----------------------------------------------------------------
    # Capa de Aplicacion y WebDispatcher
    # ----------------------------------------------------------------
    {
      name           = "vhgrrcapapp01"
      machine_type   = "c4d-highmem-8"
      tags           = ["allow-iap", "sap-app", "sap-vm"]
      can_ip_forward = false
      boot_disk_size = 30
      boot_disk_type = "hyperdisk-balanced"
      data_disks = [
        { name = "vhgrrcapapp01-data-disk", size = 400, type = "hyperdisk-balanced" }
      ]
    },
    {
      name           = "vhgrrcapapp02"
      machine_type   = "c4d-highmem-8"
      tags           = ["allow-iap", "sap-app", "sap-vm"]
      can_ip_forward = false
      boot_disk_size = 30
      boot_disk_type = "hyperdisk-balanced"
      data_disks = [
        { name = "vhgrrcapapp02-data-disk", size = 400, type = "hyperdisk-balanced" }
      ]
    },
    {
      name           = "vhgrrwdp01"
      machine_type   = "n2d-highmem-2"
      tags           = ["allow-iap", "sap-app", "sap-vm"]
      can_ip_forward = false
      boot_disk_size = 30
      boot_disk_type = "pd-balanced"
      data_disks = [
        { name = "vhgrrwdp01-data-disk", size = 128, type = "pd-balanced" }
      ]
    },
    {
      name           = "vhgrrwdp02"
      machine_type   = "n2d-highmem-2"
      tags           = ["allow-iap", "sap-app", "sap-vm"]
      can_ip_forward = false
      boot_disk_size = 30
      boot_disk_type = "pd-balanced"
      data_disks = [
        { name = "vhgrrwdp02-data-disk", size = 128, type = "pd-balanced" }
      ]
    },

    # ----------------------------------------------------------------
    # Capa de Servicios Centrales (Cluster ASCS / ERS)
    # ----------------------------------------------------------------
    {
      name           = "vhgrrcapascs01"
      machine_type   = "n2d-highmem-4"
      tags           = ["allow-iap", "sap-app", "sap-vm"]
      can_ip_forward = true
      boot_disk_size = 30
      boot_disk_type = "pd-balanced" # N2D requiere pd-balanced
      data_disks = [
        { name = "vhgrrcapascs01-data-disk", size = 128, type = "pd-balanced" } # N2D requiere pd-balanced
      ]
    },
    {
      name           = "vhgrrcapers01"
      machine_type   = "n2d-highmem-4"
      tags           = ["allow-iap", "sap-app", "sap-vm"]
      can_ip_forward = true
      boot_disk_size = 30
      boot_disk_type = "pd-balanced" # N2D requiere pd-balanced
      data_disks = [
        { name = "vhgrrcapers01-data-disk", size = 128, type = "pd-balanced" } # N2D requiere pd-balanced
      ]
    },

    # ----------------------------------------------------------------
    # Capa de Base de Datos HANA (HSR Cluster)
    # ----------------------------------------------------------------
    {
      name           = "vhgrrcapdb01"
      machine_type   = "m3-ultramem-128"
      tags           = ["allow-iap", "sap-db", "sap-vm"]
      can_ip_forward = true
      boot_disk_size = 30
      boot_disk_type = "hyperdisk-balanced"
      data_disks = [
        { name = "vhgrrcapdb01-sap-disk", size = 260, type = "hyperdisk-balanced" },
        { name = "vhgrrcapdb01-hana-data-disk", size = 8956, type = "hyperdisk-balanced" },
        { name = "vhgrrcapdb01-hana-log-disk", size = 512, type = "hyperdisk-balanced" },
        { name = "vhgrrcapdb01-hana-shared-disk", size = 1024, type = "hyperdisk-balanced" },
        { name = "vhgrrcapdb01-backup-disk", size = 6144, type = "hyperdisk-balanced" },
      ]
    },
    {
      name           = "vhgrrcapdb02"
      machine_type   = "m3-ultramem-128"
      tags           = ["allow-iap", "sap-db", "sap-vm"]
      can_ip_forward = true
      boot_disk_size = 30
      boot_disk_type = "hyperdisk-balanced"
      data_disks = [
        { name = "vhgrrcapdb02-sap-disk", size = 260, type = "hyperdisk-balanced" },
        { name = "vhgrrcapdb02-hana-data-disk", size = 8956, type = "hyperdisk-balanced" },
        { name = "vhgrrcapdb02-hana-log-disk", size = 512, type = "hyperdisk-balanced" },
        { name = "vhgrrcapdb02-hana-shared-disk", size = 1024, type = "hyperdisk-balanced" },
        { name = "vhgrrcapdb02-backup-disk", size = 6144, type = "hyperdisk-balanced" },
      ]
    },
  ]
}