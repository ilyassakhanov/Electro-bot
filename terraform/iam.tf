# Creating a policy for accessing
resource "aws_iam_policy" "secrets_manager_policy" {
  name        = "ecsSecretsManagerPolicy"
  description = "Allow ECS to retrieve secrets from Secrets Manager"
  
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ],
        Resource = [
          "arn:aws:secretsmanager:${var.region}:${var.account_id}:secret:${var.project-name}-secrets*"
        ]
      }
    ]
  })
}
