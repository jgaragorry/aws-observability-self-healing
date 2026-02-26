resource "aws_iam_role" "remediation_lambda_role" {
  name = "${var.project_name}-remediation-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_policy" "remediation_policy" {
  name        = "${var.project_name}-remediation-policy"
  description = "Permite a la Lambda cerrar puertos inseguros"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
        Effect = "Allow"
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Action = ["ec2:RevokeSecurityGroupIngress", "ec2:DescribeSecurityGroups"]
        Effect = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "remediation_attach" {
  role       = aws_iam_role.remediation_lambda_role.name
  policy_arn = aws_iam_policy.remediation_policy.arn
}
