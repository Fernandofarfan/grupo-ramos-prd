# Módulo de Cómputo (Compute Module)

Módulo reutilizable de Terraform para la creación de Máquinas Virtuales (VMs) en GCP Compute Engine con discos de datos desacoplados.

## Recursos Creados

- `google_compute_disk.data_disks`: Discos independientes de datos (`pd-balanced`).
- `google_compute_instance.vm`: Instancias de Compute Engine con SO SLES for SAP.
- `google_compute_attached_disk.attached`: Vínculos (attachment) entre las VMs y los discos de datos correspondientes.

## Características

1. **Desacoplamiento de almacenamiento**: Los discos de datos tienen un ciclo de vida independiente de la instancia virtual.
2. **Protección de ciclo de vida**: Las instancias ignoran cambios en `boot_disk` y `attached_disk` para evitar recreaciones accidentales.
3. **Múltiples discos por VM**: Soporta listas dinámicas de discos por cada definición de instancia usando funciones `flatten` en `locals`.

## Inputs

| Nombre | Descripción | Tipo | Requerido | Default |
|---|---|---|---|---|
| `project_id` | ID del proyecto GCP | `string` | Sí | N/A |
| `zone` | Zona GCP por defecto para el despliegue | `string` | Sí | N/A |
| `subnet_self_link` | Self-link de la subred donde se conectarán las VMs | `string` | Sí | N/A |
| `os_image` | URI o familia de la imagen de sistema operativo | `string` | Sí | N/A |
| `instances` | Lista de objetos con la especificación de VMs y discos | `list(object(...))` | Sí | N/A |
| `allow_stopping_for_update` | Permite detener la VM para cambiar machine_type | `bool` | No | `true` |

## Outputs

| Nombre | Descripción | Tipo |
|---|---|---|
| `vm_names` | Lista de nombres de las VMs creadas | `list(string)` |
| `vm_internal_ips` | Lista de IPs internas de las VMs creadas | `list(string)` |
| `vm_self_links` | Lista de self-links de las VMs creadas | `list(string)` |
| `disk_self_links` | Mapa `nombre_disco => self_link` de los discos de datos | `map(string)` |
