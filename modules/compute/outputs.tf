output "vm_names" {
  description = "Nombres de todas las VMs desplegadas"
  value       = [for inst in var.instances : inst.name]
}

output "vm_internal_ips" {
  description = "IPs internas de todas las VMs desplegadas"
  value       = [for inst in var.instances : google_compute_instance.vm[inst.name].network_interface[0].network_ip]
}

output "vm_self_links" {
  description = "Self-links de todas las VMs desplegadas"
  value       = [for inst in var.instances : google_compute_instance.vm[inst.name].self_link]
}

output "disk_self_links" {
  description = "Mapa de nombre de disco => self_link de todos los discos de datos"
  value = {
    for disk_name, disk in google_compute_disk.data_disks : disk_name => disk.self_link
  }
}
