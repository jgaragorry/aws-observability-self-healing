# Empaquetar el código Python en un ZIP (Requerido por AWS)
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/../../../src/remediation.py"
  output_path = "${path.module}/remediation.zip"
}

resource "aws_lambda_function" "remediation_lambda" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "${var.project_name}-remediation"
  role             = var.lambda_role_arn
  handler          = "remediation.lambda_handler"
  runtime          = "python3.12"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  timeout     = 10
  memory_size = 128
}
