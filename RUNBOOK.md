# 📘 Operaciones: Step-by-Step Guide

Este Runbook garantiza un despliegue exitoso e idempotente.

## ⏱️ Ciclo de Vida del Proyecto

| Fase | Acción | Comando | Estado |
| :--- | :--- | :--- | :--- |
| 1. Bootstrap | Crear Backend | `./scripts/bootstrap_backend.sh` | ✅ Listo |
| 2. Deploy | Terraform Apply | `cd terraform && terraform apply` | ✅ Listo |
| 3. Chaos | Simular Brecha | `./scripts/simulate_breach.sh` | ⚠️ Test |
| 4. Nuke | Limpieza Total | `./scripts/nuke_lab.sh` | 🔥 FinOps |
| 5. Audit | Verificar Purga | `./scripts/verify_purge.sh` | 🔍 Check |

---

## 🛠️ Procedimiento Detallado

### 🟢 Paso 1: Inicialización (Bootstrap)

Preparamos el terreno creando el Bucket S3 y DynamoDB para el estado remoto.

```bash
./scripts/bootstrap_backend.sh
```

### 🔵 Paso 2: Despliegue de Infraestructura

Materializamos los recursos en AWS.

```bash
cd terraform
terraform init
terraform apply -auto-approve
cd ..
```

### 🟡 Paso 3: Simulación de Ataque

Creamos un Security Group vulnerable para ver al sistema en acción.

```bash
./scripts/simulate_breach.sh
```

### 🔴 Paso 4: Destrucción y Auditoría (FinOps)

Garantizamos el costo $0.00 eliminando todo rastro.

```bash
./scripts/nuke_lab.sh
./scripts/verify_purge.sh
```

---
