variable "project_id" {
  description = "ID del proyecto GCP"
  type        = string
}

variable "zone" {
  description = "Zona GCP de despliegue"
  type        = string
}

variable "subnet_self_link" {
  description = "Self-link de la subred compartida"
  type        = string
}

variable "os_image" {
  description = "Imagen de sistema operativo SAP"
  type        = string
}

variable "instances" {
  description = "Lista de definiciones de instancias VM"
  type = list(object({
    name           = string
    machine_type   = string
    tags           = list(string)
    can_ip_forward = optional(bool, false)
    boot_disk_size = number
    boot_disk_type = string

    # SOLUCIÓN: Agregamos optional(string, null) para que no falle si no se define en locals.tf
    network_ip = optional(string, null)

    data_disks = list(object({
      name = string
      size = number
      type = string
    }))
  }))
}

variable "allow_stopping_for_update" {
  description = "Permitir detener instancias para actualizaciones"
  type        = bool
  default     = true
}