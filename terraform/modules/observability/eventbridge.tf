# -------------------------------------------------------------------------------------------------
# REGLA DE EVENTBRIDGE: EL TEMPORIZADOR SRE
# Este recurso actúa como el 'latido' del sistema, disparando la revisión de seguridad periódicamente.
# -------------------------------------------------------------------------------------------------
resource "aws_cloudwatch_event_rule" "security_drift_rule" {
  name                = "${var.project_name}-security-scan"
  description         = "Auditoría de seguridad continua cada 60 segundos (Idempotente y Free Tier)"
  
  # Práctica SRE: Definimos un intervalo constante para garantizar que ninguna brecha dure más de 1 min.
  schedule_expression = "rate(1 minute)"
}

# -------------------------------------------------------------------------------------------------
# TARGET DE EVENTOS: VÍNCULO SENSOR-ACTUADOR
# Define que la Lambda de remediación es el destino final de cada pulsación del temporizador.
# -------------------------------------------------------------------------------------------------
resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.security_drift_rule.name
  target_id = "SendToLambda"
  arn       = var.lambda_function_arn
}

# -------------------------------------------------------------------------------------------------
# PERMISOS DE LAMBDA: PRINCIPIO DE MENOR PRIVILEGIO (IAM)
# Autoriza explícitamente al servicio de eventos de AWS para invocar nuestra función.
# Sin esto, el sensor disparará el evento pero la Lambda rechazará la ejecución (403 Forbidden).
# -------------------------------------------------------------------------------------------------
resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.security_drift_rule.arn
}
