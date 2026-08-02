output "vm_ips" {
  description = "IPs internas de todas las VMs desplegadas (nombre => IP)"
  value       = zipmap(module.compute.vm_names, module.compute.vm_internal_ips)
}

output "vm_self_links" {
  description = "Self-links de todas las VMs desplegadas (nombre => self_link)"
  value       = zipmap(module.compute.vm_names, module.compute.vm_self_links)
}

output "disk_self_links" {
  description = "Self-links de todos los discos de datos (nombre_disco => self_link)"
  value       = module.compute.disk_self_links
}

output "shared_vpc_self_link" {
  description = "Self-link de la VPC compartida utilizada"
  value       = data.google_compute_network.shared_vpc.self_link
}

output "shared_subnet_self_link" {
  description = "Self-link de la subred compartida utilizada"
  value       = data.google_compute_subnetwork.shared_subnet_prd.self_link
}
