# ----------------------------------------------------------------
# Grupos de Instancias No Administrados (UMIG) para Backend ILB
# ----------------------------------------------------------------
resource "google_compute_instance_group" "umig_zone_a" {
  project = var.project_id
  name    = "ig-sap-prd-zone-a"
  zone    = var.zone
  instances = [
    module.compute.vm_self_links[0], # app01
    module.compute.vm_self_links[2], # wdp01
    module.compute.vm_self_links[4], # ascs
    module.compute.vm_self_links[6]  # db01
  ]
}

resource "google_compute_instance_group" "umig_zone_b" {
  project = var.project_id
  name    = "ig-sap-prd-zone-b"
  zone    = var.secondary_zone
  instances = [
    module.compute.vm_self_links[1], # app02
    module.compute.vm_self_links[3], # wdp02
    module.compute.vm_self_links[5], # esr
    module.compute.vm_self_links[7]  # db02
  ]
}

# ----------------------------------------------------------------
# Health Checks para Clústeres SAP (ASCS, HANA, WebDispatcher)
# ----------------------------------------------------------------
resource "google_compute_health_check" "ascs_hc" {
  project            = var.project_id
  name               = "hc-sap-ascs-prd"
  check_interval_sec = 5
  timeout_sec        = 3

  tcp_health_check {
    port = 3600
  }
}

resource "google_compute_health_check" "hana_hc" {
  project            = var.project_id
  name               = "hc-sap-hana-prd"
  check_interval_sec = 5
  timeout_sec        = 3

  tcp_health_check {
    port = 23253
  }
}

resource "google_compute_health_check" "wdp_hc" {
  project            = var.project_id
  name               = "hc-sap-wdp-prd"
  check_interval_sec = 5
  timeout_sec        = 3

  tcp_health_check {
    port = 44300
  }
}

# ----------------------------------------------------------------
# Backend Services para Internal Load Balancers (ILB)
# ----------------------------------------------------------------
resource "google_compute_region_backend_service" "ascs_backend" {
  project               = var.project_id
  name                  = "bes-sap-ascs-prd"
  region                = var.region
  protocol              = "TCP"
  load_balancing_scheme = "INTERNAL"
  health_checks         = [google_compute_health_check.ascs_hc.id]

  backend {
    group = google_compute_instance_group.umig_zone_a.id
  }
  backend {
    group = google_compute_instance_group.umig_zone_b.id
  }
}

resource "google_compute_region_backend_service" "hana_backend" {
  project               = var.project_id
  name                  = "bes-sap-hana-prd"
  region                = var.region
  protocol              = "TCP"
  load_balancing_scheme = "INTERNAL"
  health_checks         = [google_compute_health_check.hana_hc.id]

  backend {
    group = google_compute_instance_group.umig_zone_a.id
  }
  backend {
    group = google_compute_instance_group.umig_zone_b.id
  }
}

resource "google_compute_region_backend_service" "wdp_backend" {
  project               = var.project_id
  name                  = "bes-sap-wdp-prd"
  region                = var.region
  protocol              = "TCP"
  load_balancing_scheme = "INTERNAL"
  health_checks         = [google_compute_health_check.wdp_hc.id]

  backend {
    group = google_compute_instance_group.umig_zone_a.id
  }
  backend {
    group = google_compute_instance_group.umig_zone_b.id
  }
}

# ----------------------------------------------------------------
# Forwarding Rules / VIPs Estáticas para Clústeres HA
# ----------------------------------------------------------------
resource "google_compute_forwarding_rule" "ascs_vip" {
  project               = var.project_id
  name                  = "vip-sap-ascs-prd"
  region                = var.region
  load_balancing_scheme = "INTERNAL"
  backend_service       = google_compute_region_backend_service.ascs_backend.id
  all_ports             = true
  network               = data.google_compute_network.shared_vpc.self_link
  subnetwork            = data.google_compute_subnetwork.shared_subnet_prd.self_link
  ip_address            = "10.79.12.30"
}

resource "google_compute_forwarding_rule" "hana_vip" {
  project               = var.project_id
  name                  = "vip-sap-hana-prd"
  region                = var.region
  load_balancing_scheme = "INTERNAL"
  backend_service       = google_compute_region_backend_service.hana_backend.id
  all_ports             = true
  network               = data.google_compute_network.shared_vpc.self_link
  subnetwork            = data.google_compute_subnetwork.shared_subnet_prd.self_link
  ip_address            = "10.79.12.31"
}

resource "google_compute_forwarding_rule" "wdp_vip" {
  project               = var.project_id
  name                  = "vip-sap-wdp-prd"
  region                = var.region
  load_balancing_scheme = "INTERNAL"
  backend_service       = google_compute_region_backend_service.wdp_backend.id
  all_ports             = true
  network               = data.google_compute_network.shared_vpc.self_link
  subnetwork            = data.google_compute_subnetwork.shared_subnet_prd.self_link
  ip_address            = "10.79.12.32"
}
