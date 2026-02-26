# 🛡️ AWS Cloud Self-Healing & Continuous Compliance

[![Terraform](https://img.shields.io/badge/IaC-Terraform-623CE4?style=for-the-badge&logo=terraform&logoColor=white)](https://www.terraform.io/)
[![AWS](https://img.shields.io/badge/Cloud-AWS-232F3E?style=for-the-badge&logo=amazon-aws&logoColor=FF9900)](https://aws.amazon.com/)
[![Python](https://img.shields.io/badge/Logic-Python_3.12-3776AB?style=for-the-badge&logo=python&logoColor=white)](https://www.python.org/)
[![Lambda](https://img.shields.io/badge/Compute-Lambda-FF9900?style=for-the-badge&logo=aws-lambda&logoColor=white)](https://aws.amazon.com/lambda/)
[![EventBridge](https://img.shields.io/badge/Events-EventBridge-E7157B?style=for-the-badge&logo=amazon-aws&logoColor=white)](https://aws.amazon.com/eventbridge/)
[![SRE](https://img.shields.io/badge/Role-SRE-FF6600?style=for-the-badge&logo=google-cloud&logoColor=white)](https://en.wikipedia.org/wiki/Site_Reliability_Engineering)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow?style=for-the-badge)](https://opensource.org/licenses/MIT)
[![Status](https://img.shields.io/badge/Status-Production_Ready-brightgreen?style=for-the-badge)](https://github.com/)

Sistema automatizado de **Remediación en Tiempo Real** para infraestructuras en la nube. Este proyecto implementa un bucle de reconciliación (Reconciliation Loop) que detecta y corrige brechas de seguridad en Security Groups de AWS de forma automática.

---

## 🎯 El Problema

Las configuraciones erróneas en la nube (Security Drift) son la causa principal de brechas de datos. Un puerto SSH (22) abierto al mundo (`0.0.0.0/0`) puede ser explotado en minutos.

## 💡 La Solución

Una arquitectura **Serverless & Event-Driven** que:

* **Monitorea:** Auditoría continua mediante EventBridge (Schedules).
* **Analiza:** Lógica en Python (Lambda) para identificar reglas inseguras.
* **Actúa:** Remediación inmediata mediante SDK Boto3.
* **Gobierna:** Infraestructura 100% modular con Terraform.

---

## 🏗️ Arquitectura del Sistema

```mermaid
graph TD
    A([⏰ EventBridge\nCron cada 60s]) -->|trigger| B[⚡ AWS Lambda\nPython 3.12]
    B -->|boto3 describe| C[(🔍 EC2 API\nSecurity Groups)]
    C -->|puerto 22 abierto| D{🚨 ¿Brecha\ndetectada?}
    D -->|✅ SÍ| E[🔒 revoke_security_group_ingress]
    D -->|❌ NO| F([✅ Sin acción\nrequerida])
    E -->|audit trail| G[(📋 CloudWatch\nLogs)]
    F -->|audit trail| G

    style A fill:#E7157B,color:#fff,stroke:none
    style B fill:#FF9900,color:#fff,stroke:none
    style C fill:#232F3E,color:#fff,stroke:none
    style D fill:#d32f2f,color:#fff,stroke:none
    style E fill:#1565C0,color:#fff,stroke:none
    style F fill:#2e7d32,color:#fff,stroke:none
    style G fill:#6A1B9A,color:#fff,stroke:none
```

> El detalle técnico completo de componentes y capas de seguridad se encuentra en:
> 👉 [ARCHITECTURE.md](./ARCHITECTURE.md)

---

## 🛠️ Stack Tecnológico

* **Infraestructura:** Terraform (Modules, Remote State, DynamoDB Locking).
* **Compute:** AWS Lambda (Python 3.12).
* **Observabilidad:** Amazon EventBridge & CloudWatch Logs.
* **Automation:** Bash Scripts (CI/CD ready).

---

## 📘 Guía de Operación (Runbook)

Para desplegar, probar y limpiar este laboratorio sin errores:
👉 [RUNBOOK.md](./RUNBOOK.md)

---

## 🤝 Contacto & Colaboración

¿Te interesa el SRE y la Automatización? ¡Conectemos!

* **Nombre:** Jose Garagorry
* **LinkedIn:** [linkedin.com/in/tu-perfil](https://linkedin.com/in/tu-perfil)
* **Portfolio:** [SoftrainCorp / GitHub](https://github.com/tu-usuario)
* **Ubicación:** Santiago, Chile 🇨🇱

---

## 🤝 Contacto & Colaboración

¿Te interesa el SRE y la Automatización? ¡Conectemos!

* **Nombre:** Jose Garagorry
* **LinkedIn:** [linkedin.com/in/jgaragorry](https://linkedin.com/in/jgaragorry)
* **Portfolio:** [Jose Garagorry/ GitHub](https://github.com/jgaragorry)
* **Ubicación:** Santiago, Chile 🇨🇱

---

*Desarrollado con mentalidad SRE: Si lo haces más de dos veces, automatízalo.*# 🛡️ AWS Cloud Self-Healing & Continuous Compliance
