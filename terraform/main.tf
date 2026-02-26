terraform {
  required_version = ">= 1.5.0"

  # El backend se configura después de correr el bootstrap script
  backend "s3" {
    bucket         = "jgaragorry-sre-tfstate-533267117128" # <--- Este es nuestro placeholder
    key            = "self-healing/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock-table"
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  # FinOps: Etiquetado Automático Global
  default_tags {
    tags = {
      Project     = "Self-Healing-Lab"
      Owner       = "JoseGaragorry"
      Environment = "Workshop"
      CostCenter  = "Learning-SRE"
      ManagedBy   = "Terraform"
    }
  }
}

# Capa 1: Seguridad e Identidad
module "security" {
  source       = "./modules/security"
  project_name = var.project_name
}

# Capa 2: Cómputo (Lambda de Remediación)
module "compute" {
  source          = "./modules/compute"
  project_name    = var.project_name
  lambda_role_arn = module.security.lambda_role_arn
}

# Capa 3: Observabilidad y Disparadores
module "observability" {
  source               = "./modules/observability"
  project_name         = var.project_name
  lambda_function_arn  = module.compute.lambda_function_arn
  lambda_function_name = "${var.project_name}-remediation" # Consistencia con el módulo compute
}
