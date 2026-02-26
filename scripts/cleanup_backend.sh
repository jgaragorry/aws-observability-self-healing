#!/bin/bash
# Propósito: Eliminación total del backend con purga de versiones de S3.
# Práctica SRE: Confirmación interactiva y limpieza de basura (zombies).

REGION="us-east-1"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
BUCKET_NAME="jgaragorry-sre-tfstate-${ACCOUNT_ID}"
TABLE_NAME="terraform-lock-table"

echo "⚠️  ADVERTENCIA: Vas a eliminar el Backend de Terraform."
echo "Esto destruirá el historial de estados y el bloqueo de concurrencia."
read -p "🤔 ¿Estás seguro de que deseas proceder? (escribe 'ELIMINAR'): " CONFIRM

if [ "$CONFIRM" != "ELIMINAR" ]; then
    echo "❌ Operación cancelada por el usuario."
    exit 1
fi

echo "-------------------------------------------------------"
echo "🗑️ Iniciando desmantelamiento del Backend..."
echo "-------------------------------------------------------"

# 1. Vaciar Bucket (Versiones y Delete Markers) - Esto es lo que evita el error de BucketNotEmpty
if aws s3api head-bucket --bucket "$BUCKET_NAME" 2>/dev/null; then
    echo "🧹 Purgando versiones y objetos de $BUCKET_NAME..."
    
    # Eliminar todas las versiones de objetos
    versions=$(aws s3api list-object-versions --bucket "$BUCKET_NAME" --output json --query 'Versions[].{Key:Key,VersionId:VersionId}')
    if [ "$versions" != "null" ]; then
        echo "   - Eliminando versiones de archivos..."
        aws s3api delete-objects --bucket "$BUCKET_NAME" --delete "$(echo $versions | jq -c '{Objects: .}')" > /dev/null
    fi

    # Eliminar marcadores de eliminación (Delete Markers)
    markers=$(aws s3api list-object-versions --bucket "$BUCKET_NAME" --output json --query 'DeleteMarkers[].{Key:Key,VersionId:VersionId}')
    if [ "$markers" != "null" ]; then
        echo "   - Eliminando marcadores de borrado..."
        aws s3api delete-objects --bucket "$BUCKET_NAME" --delete "$(echo $markers | jq -c '{Objects: .}')" > /dev/null
    fi

    # 2. Borrar el bucket
    echo "🔥 Eliminando bucket S3..."
    aws s3api delete-bucket --bucket "$BUCKET_NAME" --region "$REGION"
    aws s3api wait bucket-not-exists --bucket "$BUCKET_NAME"
else
    echo "ℹ️ El bucket no existe. Omitiendo."
fi

# 3. Borrar Tabla DynamoDB
if aws dynamodb describe-table --table-name "$TABLE_NAME" --region "$REGION" >/dev/null 2>&1; then
    echo "🔥 Eliminando tabla DynamoDB..."
    aws dynamodb delete-table --table-name "$TABLE_NAME" --region "$REGION"
    aws dynamodb wait table-not-exists --table-name "$TABLE_NAME" --region "$REGION"
else
    echo "ℹ️ La tabla no existe. Omitiendo."
fi

echo "-------------------------------------------------------"
echo "✨ Limpieza completada. No quedan recursos huérfanos."
echo "-------------------------------------------------------"
