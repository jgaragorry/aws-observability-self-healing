# 🏛️ System Architecture

Este documento detalla la topología y el flujo de datos del sistema de auto-remediación.

---

## 🔄 Flujo de Datos (Workflow)

1. **Activación:** EventBridge dispara un evento cada 60 segundos (Cron).
2. **Ejecución:** AWS Lambda se despierta e invoca el SDK `boto3`.
3. **Filtrado:** La función solicita a la API de EC2 todos los Security Groups con el puerto 22 abierto a `0.0.0.0/0`.
4. **Remediación:** Si encuentra coincidencias, ejecuta `revoke_security_group_ingress`.
5. **Audit Log:** El resultado (éxito/error) se persiste en **CloudWatch Logs**.

---

## 🧭 Flujo de Decisión (Decision Flow)

```mermaid
flowchart TD
    START([🚀 Inicio del Ciclo\nEventBridge Trigger]) --> LAMBDA[⚡ Lambda despierta\nboto3 inicializado]
    LAMBDA --> SCAN[🔍 Escanear todos los\nSecurity Groups en la región]
    SCAN --> CHECK{¿Existe regla\npuerto 22 → 0.0.0.0/0?}

    CHECK -->|NO| LOG_OK[📋 Log: Compliant\nCloudWatch]
    CHECK -->|SÍ| EXTRACT[📌 Extraer ID del\nSecurity Group vulnerable]

    EXTRACT --> REVOKE[🔒 Ejecutar\nrevoke_security_group_ingress]
    REVOKE --> SUCCESS{¿Revocación\nexitosa?}

    SUCCESS -->|✅ SÍ| LOG_FIX[📋 Log: Remediated\nCloudWatch]
    SUCCESS -->|❌ ERROR| LOG_ERR[🚨 Log: Error + Detalle\nCloudWatch]

    LOG_OK --> END([🔁 Esperar\nsiguiente ciclo 60s])
    LOG_FIX --> END
    LOG_ERR --> END

    style START fill:#E7157B,color:#fff,stroke:none
    style LAMBDA fill:#FF9900,color:#fff,stroke:none
    style SCAN fill:#232F3E,color:#fff,stroke:none
    style CHECK fill:#1565C0,color:#fff,stroke:none
    style EXTRACT fill:#FF9900,color:#fff,stroke:none
    style REVOKE fill:#d32f2f,color:#fff,stroke:none
    style SUCCESS fill:#1565C0,color:#fff,stroke:none
    style LOG_OK fill:#2e7d32,color:#fff,stroke:none
    style LOG_FIX fill:#2e7d32,color:#fff,stroke:none
    style LOG_ERR fill:#b71c1c,color:#fff,stroke:none
    style END fill:#6A1B9A,color:#fff,stroke:none
```

---

## 🛡️ Capas de Seguridad

* **IAM Least Privilege:** La Lambda solo tiene permisos para `Describe` y `Revoke` en EC2. No puede crear ni borrar instancias.
* **State Locking:** Terraform utiliza DynamoDB para evitar que dos personas modifiquen la infraestructura al mismo tiempo.

---

[← Volver al README](./README.md)
