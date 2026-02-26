#!/bin/bash
# -------------------------------------------------------------------------------------------------
# SCRIPT DE DESTRUCCIÓN TOTAL (THE NUKE SCRIPT)
# Propósito: Eliminar toda la infraestructura del lab, logs residuales y el backend de Terraform.
# Práctica SRE/FinOps: Garantizar Costo $0 mediante eliminación de recursos huérfanos.
# -------------------------------------------------------------------------------------------------

set -e # Detener el script si ocurre un error inesperado

# Variables de entorno (Debe coincidir con tu despliegue)
REGION="us-east-1"
LOG_GROUP="/aws/lambda/self-healing-lab-remediation"
TF_DIR="terraform"

echo "-------------------------------------------------------"
echo "⚠️  INICIANDO PURGA TOTAL DEL LABORATORIO"
echo "-------------------------------------------------------"

# 1. DESTRUCCIÓN DE INFRAESTRUCTURA GESTIONADA POR TERRAFORM
# El comando 'destroy' elimina la Lambda, IAM Roles, y Reglas de EventBridge.
if [ -d "$TF_DIR" ]; then
    echo "🏗️  1/3: Destruyendo recursos gestionados por Terraform..."
    cd "$TF_DIR"
    # Aseguramos que haya un estado antes de intentar destruir
    if [ -f ".terraform.lock.hcl" ]; then
        terraform destroy -auto-approve
    else
        echo "ℹ️  No se detectó inicialización de Terraform. Saltando..."
    fi
    cd ..
else
    echo "❌ Error: Directorio $TF_DIR no encontrado."
fi

# 2. ELIMINACIÓN DE LOGS RESIDUALES (CLOUDWATCH)
# AWS Lambda crea Log Groups que Terraform no gestiona por defecto.
echo "📑 2/3: Eliminando CloudWatch Log Groups para evitar basura de datos..."
if aws logs describe-log-groups --log-group-name-prefix "$LOG_GROUP" --region "$REGION" | grep -q "$LOG_GROUP"; then
    aws logs delete-log-group --log-group-name "$LOG_GROUP" --region "$REGION"
    echo "✅ Logs eliminados correctamente."
else
    echo "ℹ️  No se encontraron logs residuales. Saltando..."
fi

# 3. ELIMINACIÓN DEL BACKEND (S3 + DYNAMODB)
# Invocamos el script de limpieza del backend que ya es idempotente y pide confirmación.
echo "🗄️  3/3: Ejecutando limpieza del cimiento (Backend)..."
if [ -f "scripts/cleanup_backend.sh" ]; then
    bash scripts/cleanup_backend.sh
else
    echo "❌ Error: scripts/cleanup_backend.sh no encontrado."
    exit 1
fi

echo "-------------------------------------------------------"
echo "✨ PURGA COMPLETADA: Tu cuenta de AWS está limpia."
echo "-------------------------------------------------------"
