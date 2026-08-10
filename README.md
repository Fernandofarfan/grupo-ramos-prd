# Grupo Ramos - SAP CAR PRD (Infraestructura como Código)

Infraestructura Terraform para el despliegue del entorno de Producción (PRD) de SAP CAR con Alta Disponibilidad (HA) multizona en Google Cloud Platform (GCP).

---

## 📐 Arquitectura del Sistema

### 1. Inventario de Máquinas Virtuales (VMs) y Almacenamiento

| Capa / Rol | Nombre VM | Tipo de Máquina | Zona GCP | IP Privada | Disco Boot | Discos de Datos Adjuntos (`pd-balanced`) | IP Forwarding |
|---|---|---|---|---|---|---|---|
| **App Server** | `vhgrrcapapp01` | `n2d-highmem-8` | `us-east1-b` | `10.79.12.20` | 64 GB | `vhgrrcapapp01-data-disk` (512 GB) | Desactivado |
| **App Server HA** | `vhgrrcapapp02` | `n2d-highmem-8` | `us-east1-d` | `10.79.12.21` | 64 GB | `vhgrrcapapp02-data-disk` (512 GB) | Desactivado |
| **WebDispatcher** | `vhgrrwdp01` | `n2d-highmem-2` | `us-east1-b` | `10.79.12.24` | 30 GB | `vhgrrwdp01-data-disk` (128 GB) | Desactivado |
| **WebDispatcher HA** | `vhgrrwdp02` | `n2d-highmem-2` | `us-east1-d` | `10.79.12.25` | 30 GB | `vhgrrwdp02-data-disk` (128 GB) | Desactivado |
| **ASCS** | `vhgrrcapascs` | `n2d-standard-4` | `us-east1-b` | `10.79.12.26` | 30 GB | `vhgrrcapascs-data-disk` (128 GB) | **Activado** |
| **ERS** | `vhgrrcapesr` | `n2d-standard-4` | `us-east1-d` | `10.79.12.27` | 30 GB | `vhgrrcapesr-data-disk` (128 GB) | **Activado** |
| **HANA DB Primaria** | `vhgrrcapdb01` | `m3-ultramem-128` | `us-east1-b` | `10.79.12.22` | 64 GB | `/usr/sap` (260 GB)<br>`/hana/data` (8000 GB)<br>`/hana/log` (1024 GB)<br>`/hana/shared` (1024 GB)<br>`/backup` (6144 GB) | **Activado** |
| **HANA DB Secundaria** | `vhgrrcapdb02` | `m3-ultramem-128` | `us-east1-d` | `10.79.12.23` | 64 GB | `/usr/sap` (260 GB)<br>`/hana/data` (8000 GB)<br>`/hana/log` (1024 GB)<br>`/hana/shared` (1024 GB)<br>`/backup` (6144 GB) | **Activado** |

> [!NOTE]
> Todos los discos (tanto de arranque como de datos) utilizan el tipo de disco equilibrado **`pd-balanced`**.

### 2. Balanceadores de Carga Internos (ILB) y VIPs de Alta Disponibilidad

Para soportar la alta disponibilidad de los servicios SAP y la replicación del clúster Pacemaker, se configuran 3 Internal Load Balancers de GCP con sus correspondientes IPs virtuales (VIPs) y comprobaciones de estado (Health Checks):

| Servicio Clúster | VIP Estática | Puerto Health Check | Nombre Health Check | Backend Service | Grupos de Instancias (UMIG) |
|---|---|---|---|---|---|
| **ASCS / ERS** | `10.79.12.30` | `3600` (TCP) | `hc-sap-ascs-prd` | `bes-sap-ascs-prd` | `ig-sap-prd-zone-a` / `ig-sap-prd-zone-b` |
| **HANA DB (HSR)** | `10.79.12.31` | `23253` (TCP) | `hc-sap-hana-prd` | `bes-sap-hana-prd` | `ig-sap-prd-zone-a` / `ig-sap-prd-zone-b` |
| **WebDispatcher** | `10.79.12.32` | `44300` (TCP) | `hc-sap-wdp-prd` | `bes-sap-wdp-prd` | `ig-sap-prd-zone-a` / `ig-sap-prd-zone-b` |

### 3. Red y Contexto Cloud

- **Proyecto GCP Servicio:** `gramos-sap-car-rise-prd`
- **Proyecto GCP Host Red:** `gramos-prj-prod-shd-net-01`
- **Shared VPC:** `gramos-vpc-shared-prd`
- **Subred Compartida:** `gramos-shared-sap-prod-01` (`10.79.12.0/24`)
- **Región / Zonas:** `us-east1` (`us-east1-b` Primaria, `us-east1-d` Secundaria / HA)
- **Sistema Operativo:** SLES 15 SP7 for SAP Applications (`suse-sap-cloud/sles-15-sp7-sap`)

---

## 📁 Estructura del Proyecto

```
.
├── apis.tf               # Habilitación de APIs GCP requeridas (Compute, IAM, IAP, Filestore, etc.)
├── filestore.tf          # Configuración de Filestore NFS 1TB para almacenamiento compartido SAP (opcional)
├── iam.tf                # Permisos IAM para STONITH / Fencing de Pacemaker (fence_gce)
├── ilb.tf                # Internal Load Balancers, Health Checks, UMIGs y Forwarding Rules (VIPs)
├── imports.tf            # Declaraciones de importación HCL (Terraform 1.5+) para recursos existentes
├── locals.tf             # Definición centralizada de instancias VM, discos y mapeos
├── main.tf               # Configuración del Provider Google, Shared VPC IAM y llamada al módulo compute
├── outputs.tf            # Mapeo de salidas (IPs internas, Self-Links, VIPs de ILB)
├── terraform.tfvars      # Valores de variables específicos de entorno
├── variables.tf          # Declaración de variables de configuración global
└── modules/
    └── compute/          # Módulo reutilizable de cómputo (VMs, discos independientes y attachments)
        ├── main.tf       # Recursos compute_instance, compute_disk y compute_attached_disk
        ├── outputs.tf    # Outputs exportados por el módulo
        ├── README.md     # Documentación técnica del módulo compute
        └── variables.tf  # Variables de entrada del módulo compute
```

---

## ⚙️ Permisos IAM y Seguridad

1. **Shared VPC Network User**: Se concede el rol `roles/compute.networkUser` a la Service Account por defecto de compute (`service-<PROJECT_NUMBER>@compute-system.iam.gserviceaccount.com`) sobre la subred compartida del proyecto Host.
2. **Pacemaker STONITH / Fencing**: Se otorga el rol `roles/compute.instanceAdmin.v1` a la cuenta de servicio de cómputo para permitir operaciones de fencing (`fence_gce`) en clústeres Pacemaker (HANA y ASCS/ERS).

---

## 📋 Requisitos Previos

- **Terraform** >= 1.5.0
- **Google Provider** >= 5.0
- Credenciales GCP configuradas (`gcloud auth application-default login` o Service Account Key)
- Permisos suficientes en los proyectos `gramos-sap-car-rise-prd` y `gramos-prj-prod-shd-net-01`

---

## 🚀 Guía de Uso

### 1. Configurar Backend de Estado (GCS)

Verificar la configuración del estado remoto en `main.tf`:

```hcl
terraform {
  backend "gcs" {
    bucket = "gramos-terraform-state-prd"
    prefix = "sap-car/prd"
  }
}
```

### 2. Inicializar el Proyecto

```bash
terraform init
```

### 3. Validar y Planificar

```bash
terraform plan
```

### 4. Aplicar la Infraestructura

```bash
terraform apply
```

### 5. Destrucción de Recursos (Precaución en Producción)

Los discos independientes de datos cuentan con mecanismos de protección. Para proceder con una destrucción en entornos no productivos:
1. Remover la protección `prevent_destroy` si aplica.
2. Ejecutar `terraform destroy`.

---

## 🛡️ Gobernanza IaC y Políticas de Recursos

| Regla / Configuración | Recurso Afectado | Propósito / Impacto |
|---|---|---|
| `ignore_changes = [boot_disk, attached_disk]` | `google_compute_instance` | Evita el reemplazo destructivo de VMs por cambios en discos o adjuntos. |
| **Discos Desacoplados** | `google_compute_disk` + `attached_disk` | Desvincula el ciclo de vida del almacenamiento del ciclo de vida de la VM. |
| `can_ip_forward = true` | ASCS, ERS, DB01, DB02 | Requerido para la conmutación de VIPs y funcionamiento de Pacemaker en Linux HA. |
| `allow_stopping_for_update = true` | `google_compute_instance` | Permite reinicios controlados de la VM cuando se modifican propiedades del tipo de máquina. |

---

## 📤 Outputs Exportados

| Output | Descripción | Tipo |
|---|---|---|
| `vm_ips` | Lista de IPs internas asignadas a las instancias | `list(string)` |
| `vm_self_links` | Lista de Self-Links de todas las VMs | `list(string)` |
| `disk_self_links` | Mapa de `nombre_disco => self_link` para todos los discos de datos | `map(string)` |
| `shared_vpc_self_link` | Self-link de la VPC compartida utilizada | `string` |
| `shared_subnet_self_link` | Self-link de la subred compartida utilizada | `string` |
| `ilb_vips` | Mapa con las VIPs estáticas de los balanceadores internos (ASCS, HANA, WebDispatcher) | `map(string)` |

