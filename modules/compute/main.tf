resource "google_compute_disk" "data_disks" {
  for_each = {
    for disk in local.all_data_disks : disk.name => disk
  }

  project = var.project_id
  name    = each.value.name
  type    = each.value.type
  zone    = each.value.zone
  size    = each.value.size
}

resource "google_compute_instance" "vm" {
  for_each = { for inst in var.instances : inst.name => inst }

  project      = var.project_id
  name         = each.value.name
  machine_type = each.value.machine_type
  zone         = lookup(each.value, "zone", var.zone)

  can_ip_forward = each.value.can_ip_forward

  boot_disk {
    initialize_params {
      image = var.os_image
      size  = each.value.boot_disk_size
      type  = lookup(each.value, "boot_disk_type", "pd-balanced")
    }
    auto_delete = true
  }

  network_interface {
    subnetwork = var.subnet_self_link
    network_ip = lookup(each.value, "network_ip", null) != "" ? lookup(each.value, "network_ip", null) : null
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
  zone        = each.value.zone
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
        zone          = lookup(inst, "zone", var.zone)
      }
    ]
  ])

  attached_disk_mappings = flatten([
    for inst in var.instances : [
      for disk in inst.data_disks : {
        instance_name = inst.name
        disk_name     = disk.name
        zone          = lookup(inst, "zone", var.zone)
      }
    ]
  ])
}