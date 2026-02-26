# -------------------------------------------------------------------------------------------------
# VARIABLES GLOBALES DEL PROYECTO
# -------------------------------------------------------------------------------------------------

variable "aws_region" {
  description = "Región de AWS donde se desplegará la infraestructura"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Nombre del proyecto para prefijos de recursos"
  type        = string
  default     = "self-healing-lab"
}

# -------------------------------------------------------------------------------------------------
# ETIQUETADO (TAGGING) - CRÍTICO PARA FINOPS
# -------------------------------------------------------------------------------------------------
variable "default_tags" {
  description = "Etiquetas estándar para todos los recursos del proyecto"
  type        = map(string)
  default = {
    Project     = "Self-Healing-Lab"
    Environment = "Workshop"
    Owner       = "JoseGaragorry"
    ManagedBy   = "Terraform"
    CostCenter  = "Learning-SRE"
  }
}
