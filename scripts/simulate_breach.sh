#!/bin/bash
# Propósito: Simular una brecha de seguridad abriendo el puerto 22 al mundo.
# Práctica SRE: Verificación de MTTR (Mean Time To Repair).

REGION="us-east-1"
SG_NAME="SRE-Lab-Target-SG"

echo "🎯 Creando Security Group vulnerable para la prueba..."
SG_ID=$(aws ec2 create-security-group \
    --group-name "$SG_NAME" \
    --description "SG para probar Self-Healing" \
    --region "$REGION" \
    --query 'GroupId' --output text)

echo "🔓 Abriendo puerto 22 (SSH) a todo el mundo (Inseguro)..."
aws ec2 authorize-security-group-ingress \
    --group-id "$SG_ID" \
    --protocol tcp \
    --port 22 \
    --cidr 0.0.0.0/0 \
    --region "$REGION"

echo "⏳ Evento disparado. Esperando 60 segundos para la autoreparación..."
sleep 60

echo "🔍 Verificando estado del puerto 22..."
RULES=$(aws ec2 describe-security-groups \
    --group-ids "$SG_ID" \
    --region "$REGION" \
    --query 'SecurityGroups[0].IpPermissions' --output json)

if [ "$RULES" == "[]" ] || [ "$RULES" == "null" ]; then
    echo "✅ ÉXITO: El puerto 22 fue revocado automáticamente por la Lambda."
else
    echo "❌ FALLO: El puerto sigue abierto. Revisa los logs en CloudWatch."
fi

# Limpieza del SG de prueba
echo "🧹 Eliminando Security Group de prueba..."
aws ec2 delete-security-group --group-id "$SG_ID" --region "$REGION"
