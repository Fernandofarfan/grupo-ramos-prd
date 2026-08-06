# Grupo Ramos - SAP CAR PRD (Infraestructura como Codigo)

Infraestructura Terraform para el despliegue del entorno de Produccion (PRD) de SAP CAR con Alta Disponibilidad (HA) en Google Cloud Platform.

## Arquitectura

| Capa | VM | Tipo | IP | Discos |
|---|---|---|---|---|
| App Server | vhgrrcapapp01 | n2d-highmem-8 | 10.79.12.20 | Boot 64GB + Data 512GB (hyperdisk-balanced) |
| App Server HA | vhgrrcapapp02 | n2d-highmem-8 | 10.79.12.21 | Boot 64GB + Data 512GB (hyperdisk-balanced) |
| WebDispatcher | vhgrrwdp01 | n2d-highmem-2 | 10.79.12.24 | Boot 30GB + Data 128GB (hyperdisk-balanced) |
| WebDispatcher HA | vhgrrwdp02 | n2d-highmem-2 | 10.79.12.25 | Boot 30GB + Data 128GB (hyperdisk-balanced) |
| ASCS | vhgrrcapascs | n2d-standard-4 | 10.79.12.26 | Boot 30GB + Data 128GB (hyperdisk-balanced) |
| ERS | vhgrrcapesr | n2d-standard-4 | 10.79.12.27 | Boot 30GB + Data 128GB (hyperdisk-balanced) |
| HANA DB Primaria | vhgrrcapdb01 | m3-ultramem-128 | 10.79.12.22 | Boot 64GB + /usr/sap:260GB + /hana/data:8000GB + /hana/log:1024GB + /hana/shared:1024GB + /backup:6144GB (hyperdisk-balanced) |
| HANA DB Secundaria | vhgrrcapdb02 | m3-ultramem-128 | 10.79.12.23 | Idem DB01 |

- **Proyecto GCP:** `gramos-sap-car-rise-prd`
- **Shared VPC:** `gramos-vpc-shared-prd` (Host: `gramos-prj-prd-shd-net-01`)
- **Subred:** `gramos-shared-sap-prd-01` (CIDR: `10.79.12.0/24`)
- **Region/Zona:** `us-east1` / `us-east1-b`
- **SO:** SLES 15 SP7 for SAP Applications

## Estructura del Proyecto

```
.
├── apis.tf               # Activacion de APIs GCP
├── main.tf               # Provider Google, backend GCS, modulos
├── variables.tf          # Variables globales de configuracion
├── locals.tf             # Definiciones de instancias y discos
├── outputs.tf            # Outputs (IPs, self-links)
├── .gitignore
└── modules/
    └── compute/          # Modulo de computo reutilizable
        ├── main.tf       # Recursos: VM, discos, attached disks
        ├── variables.tf  # Input del modulo
        └── outputs.tf    # Outputs del modulo
```

## Requisitos

- Terraform >= 1.5.0
- Provider `hashicorp/google` >= 5.0
- Credenciales GCP configuradas (ADC o service account key)
- Permisos sobre los proyectos `gramos-sap-car-rise-prd` y `gramos-prj-prd-shd-net-01`

## Uso

### 1. Configurar Backend (Estado Remoto)

Editar `main.tf` y configurar el bucket de estado:

```hcl
backend "gcs" {
  bucket = "gramos-terraform-state-prd"
  prefix = "sap-car/prd"
}
```

### 2. Inicializar

```bash
terraform init
```

### 3. Planificar

```bash
terraform plan
```

### 4. Aplicar

```bash
terraform apply
```

### 5. Destruir (NO USAR EN PRD)

Los discos de datos tienen proteccion `prevent_destroy = true`. Para destruir, primero remover manualmente esa proteccion de cada disco en el state o via GCP Console.

## Gobernanza IaC

| Regla | Recurso |
|---|---|
| `prevent_destroy = true` | `google_compute_disk` (todos los discos de datos) |
| `ignore_changes = [boot_disk, attached_disk]` | `google_compute_instance` (todas las VMs) |
| Discos desacoplados | `google_compute_disk` independientes + `google_compute_attached_disk` |
| `can_ip_forward = true` | ASCS, ERS, DB01, DB02 (VIP/Pacemaker) |

## Outputs

| Output | Descripcion |
|---|---|
| `vm_ips` | IPs internas de todas las VMs (nombre => IP) |
| `vm_self_links` | Self-links de todas las VMs |
| `disk_self_links` | Self-links de todos los discos de datos |
| `shared_vpc_self_link` | Self-link de la VPC compartida |
| `shared_subnet_self_link` | Self-link de la subred compartida |
