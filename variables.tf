variable "project_id" {
  description = "ID del proyecto GCP donde se despliegan los recursos SAP CAR PRD"
  type        = string
  default     = "gramos-sap-car-rise-prd"
}

variable "host_project_id" {
  description = "ID del proyecto host de red (Shared VPC)"
  type        = string
  default     = "gramos-prj-qa-shd-net-01"
}

variable "region" {
  description = "Region GCP donde se despliega la solucion"
  type        = string
  default     = "us-east1"
}

variable "zone" {
  description = "Zona GCP primaria (us-east1-b)"
  type        = string
  default     = "us-east1-b"
}

variable "secondary_zone" {
  description = "Zona GCP secundaria para HA (us-east1-d)"
  type        = string
  default     = "us-east1-d"
}

variable "shared_vpc_name" {
  description = "Nombre de la red compartida (Shared VPC)"
  type        = string
  default     = "gramos-vpc-shared-qa"
}

variable "subnet_name" {
  description = "Nombre de la subred compartida SAP QA"
  type        = string
  default     = "gramos-shared-sap-qa-01"
}

variable "os_image" {
  description = "Imagen de sistema operativo SAP (SLES 15 SP7)"
  type        = string
  default     = "suse-sap-cloud/sles-15-sp7-sap"
}

variable "common_tags" {
  description = "Tags de red comunes a todas las VMs"
  type        = list(string)
  default     = ["allow-iap", "sap-vm"]
}

variable "allow_stopping_for_update" {
  description = "Permitir detener instancias para actualizaciones de configuracion"
  type        = bool
  default     = true
}
