resource "google_compute_disk" "data_disks" {
  for_each = {
    for disk in local.all_data_disks : disk.name => disk
  }

  project = var.project_id
  name    = each.value.name
  type    = each.value.type
  zone    = var.zone
  size    = each.value.size

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_compute_instance" "vm" {
  for_each = { for inst in var.instances : inst.name => inst }

  project      = var.project_id
  name         = each.value.name
  machine_type = each.value.machine_type
  zone         = var.zone

  can_ip_forward = each.value.can_ip_forward

  boot_disk {
    initialize_params {
      image = var.os_image
      size  = each.value.boot_disk_size
      type  = each.value.boot_disk_type
    }
    auto_delete = true
  }

  network_interface {
    subnetwork = var.subnet_self_link
    network_ip = each.value.network_ip
  }

  tags = each.value.tags

  service_account {
    scopes = ["cloud-platform"]
  }

  allow_stopping_for_update = var.allow_stopping_for_update

  lifecycle {
    ignore_changes = [boot_disk, attached_disk]
  }
}

resource "google_compute_attached_disk" "attached" {
  for_each = {
    for entry in local.attached_disk_mappings : "${entry.instance_name}__${entry.disk_name}" => entry
  }

  project     = var.project_id
  zone        = var.zone
  instance    = google_compute_instance.vm[each.value.instance_name].self_link
  disk        = google_compute_disk.data_disks[each.value.disk_name].self_link
  device_name = each.value.disk_name
}

locals {
  all_data_disks = flatten([
    for inst in var.instances : [
      for disk in inst.data_disks : {
        name          = disk.name
        size          = disk.size
        type          = disk.type
        instance_name = inst.name
      }
    ]
  ])

  attached_disk_mappings = flatten([
    for inst in var.instances : [
      for disk in inst.data_disks : {
        instance_name = inst.name
        disk_name     = disk.name
      }
    ]
  ])
}
