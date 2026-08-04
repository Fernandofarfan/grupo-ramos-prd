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

output "filestore_ip" {
  description = "IP privada de Filestore NFS 1TB"
  value       = google_filestore_instance.sap_nfs.networks[0].ip_addresses[0]
}

output "ilb_vips" {
  description = "VIPs de los Internal Load Balancers para los clústeres HA"
  value = {
    ascs_vip = google_compute_forwarding_rule.ascs_vip.ip_address
    hana_vip = google_compute_forwarding_rule.hana_vip.ip_address
    wdp_vip  = google_compute_forwarding_rule.wdp_vip.ip_address
  }
}
