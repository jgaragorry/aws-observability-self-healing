# =============================================================================
# CONFIGURACIÓN GLOBAL DE TERRAFORM
# =============================================================================
terraform {
  required_version = ">= 1.5.0"

  # Backend: Define dónde se almacena el estado de la infraestructura (.tfstate)
  # Se utiliza S3 para persistencia y DynamoDB para evitar ejecuciones simultáneas (Locking)
  backend "s3" {
    bucket         = "jgaragorry-sre-tfstate-533267117128" 
    key            = "self-healing/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock-table"
    encrypt        = true
  }

  # Proveedores: Define las librerías externas necesarias (en este caso, AWS)
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# =============================================================================
# CONFIGURACIÓN DEL PROVEEDOR AWS
# =============================================================================
provider "aws" {
  region = var.aws_region

  # FinOps & Gobierno: Aplicación automática de etiquetas a todos los recursos
  # Esto asegura que cada recurso creado herede los metadatos de 'default_tags'
  default_tags {
    tags = var.default_tags
  }
}

# =============================================================================
# CAPA 1: SEGURIDAD E IDENTIDAD (IAM)
# =============================================================================
# Este módulo gestiona los roles y políticas de ejecución.
# Provee los permisos necesarios para que Lambda pueda interactuar con otros servicios.
module "security" {
  source       = "./modules/security"
  project_name = var.project_name
}

# =============================================================================
# CAPA 2: CÓMPUTO (REMEDIACIÓN)
# =============================================================================
# Este módulo contiene la lógica principal (Lambda) que se activará
# ante fallos de salud en la infraestructura.
module "compute" {
  source          = "./modules/compute"
  project_name    = var.project_name
  lambda_role_arn = module.security.lambda_role_arn
}

# =============================================================================
# CAPA 3: OBSERVABILIDAD Y DISPARADORES (EVENTBRIDGE)
# =============================================================================
# Este módulo configura el monitoreo y las reglas de EventBridge.
# Actúa como el 'cerebro' que detecta eventos y dispara la Lambda de remediación.
module "observability" {
  source               = "./modules/observability"
  project_name         = var.project_name
  lambda_function_arn  = module.compute.lambda_function_arn
  lambda_function_name = "${var.project_name}-remediation"
}
