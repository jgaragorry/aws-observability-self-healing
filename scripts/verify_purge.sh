#!/bin/bash
# -------------------------------------------------------------------------------------------------
# SCRIPT DE AUDITORÍA POST-PURGA (POST-MORTEM FINOPS)
# Propósito: Verificar minuciosamente la inexistencia de cada recurso del laboratorio.
# -------------------------------------------------------------------------------------------------

REGION="us-east-1"
PROJECT="self-healing-lab"
BUCKET_PREFIX="jgaragorry-sre-tfstate"

echo "-------------------------------------------------------"
echo "🔍 INICIANDO AUDITORÍA DE LIMPIEZA TOTAL"
echo "-------------------------------------------------------"

# Función para imprimir resultados con color
check_result() {
    if [ $1 -eq 0 ]; then
        echo -e "❌ [ALERTA] El recurso $2 TODAVÍA EXISTE."
    else
        echo -e "✅ [LIMPIO] El recurso $2 no existe."
    fi
}

echo "1️⃣ Verificando Security Groups de prueba..."
SG1=$(aws ec2 describe-security-groups --filters Name=group-name,Values=SRE-Lab-Target-SG --region $REGION --query 'SecurityGroups[*].GroupId' --output text)
check_result "$(if [ -z "$SG1" ]; then echo 1; else echo 0; fi)" "Security Group (SRE-Lab-Target-SG)"

SG2=$(aws ec2 describe-security-groups --filters Name=group-name,Values=Manual-Test-SG --region $REGION --query 'SecurityGroups[*].GroupId' --output text)
check_result "$(if [ -z "$SG2" ]; then echo 1; else echo 0; fi)" "Security Group (Manual-Test-SG)"

echo -e "\n2️⃣ Verificando Lógica de Cómputo (Lambda)..."
aws lambda get-function --function-name "$PROJECT-remediation" --region $REGION >/dev/null 2>&1
check_result $? "Lambda Function ($PROJECT-remediation)"

echo -e "\n3️⃣ Verificando Observabilidad (EventBridge)..."
aws events describe-rule --name "$PROJECT-security-scan" --region $REGION >/dev/null 2>&1
check_result $? "EventBridge Rule ($PROJECT-security-scan)"

echo -e "\n4️⃣ Verificando Identidades (IAM Roles & Policies)..."
aws iam get-role --role-name "$PROJECT-remediation-role" >/dev/null 2>&1
check_result $? "IAM Role ($PROJECT-remediation-role)"

aws iam list-policies --scope Local --query "Policies[?PolicyName=='$PROJECT-remediation-policy'].Arn" --output text | grep -q "$PROJECT"
check_result $? "IAM Policy ($PROJECT-remediation-policy)"

echo -e "\n5️⃣ Verificando Almacenamiento de Logs..."
aws logs describe-log-groups --log-group-name-prefix "/aws/lambda/$PROJECT-remediation" --region $REGION --query 'logGroups[*].logGroupName' --output text | grep -q "$PROJECT"
check_result $? "CloudWatch Log Group"

echo -e "\n6️⃣ Verificando Backend de Terraform (Cimientos)..."
# Verificación de S3 (usando grep para el prefijo)
aws s3 ls | grep -q "$BUCKET_PREFIX"
check_result $? "Bucket S3 de Estado"

# Verificación de DynamoDB
aws dynamodb describe-table --table-name "terraform-lock-table" --region $REGION >/dev/null 2>&1
check_result $? "Tabla DynamoDB de Lock"

echo "-------------------------------------------------------"
echo "🏁 AUDITORÍA FINALIZADA"
# Usamos \$ para que Bash no lo interprete como la variable $0
echo "Si todos los puntos marcan ✅ [LIMPIO], tu cuenta está en \$0.00 de deuda técnica."
echo "-------------------------------------------------------"
