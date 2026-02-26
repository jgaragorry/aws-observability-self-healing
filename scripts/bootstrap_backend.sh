#!/bin/bash
# Propósito: Creación del Backend e inyección automática en Terraform
# Práctica SRE: Automatización "Hands-off"

REGION="us-east-1"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
BUCKET_NAME="jgaragorry-sre-tfstate-${ACCOUNT_ID}"
TABLE_NAME="terraform-lock-table"
TF_FILE="terraform/main.tf"

echo "🚀 Iniciando Bootstrap..."

# 1. Crear Bucket S3 (Idempotente)
if ! aws s3api head-bucket --bucket "$BUCKET_NAME" 2>/dev/null; then
    aws s3api create-bucket --bucket "$BUCKET_NAME" --region "$REGION"
    aws s3api wait bucket-exists --bucket "$BUCKET_NAME"
fi

# 2. Crear Tabla DynamoDB (Idempotente)
if ! aws dynamodb describe-table --table-name "$TABLE_NAME" --region "$REGION" >/dev/null 2>&1; then
    aws dynamodb create-table \
        --table-name "$TABLE_NAME" \
        --attribute-definitions AttributeName=LockID,AttributeType=S \
        --key-schema AttributeName=LockID,KeyType=HASH \
        --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
        --region "$REGION"
    aws dynamodb wait table-exists --table-name "$TABLE_NAME" --region "$REGION"
fi

# 3. AUTOMATIZACIÓN: Inyectar el nombre del bucket en el archivo main.tf
if [ -f "$TF_FILE" ]; then
    echo "🤖 Inyectando bucket $BUCKET_NAME en $TF_FILE..."
    # Usamos sed para reemplazar el placeholder por el nombre real
    sed -i "s/_BUCKET_NAME_/$BUCKET_NAME/g" "$TF_FILE"
    echo "✅ Archivo main.tf actualizado automáticamente."
else
    echo "❌ Error: No se encontró el archivo $TF_FILE"
    exit 1
fi

echo "-------------------------------------------------------"
echo "✅ Backend listo e inyectado. Ya puedes correr: terraform init"
