# IAM role for ECS
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2008-10-17",
    Statement = [{
      Effect = "Allow",
      Action = "sts:AssumeRole"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
      "Sid" : ""
    }]
  })
}

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

# Attach the policy to your ECS task execution role
resource "aws_iam_role_policy_attachment" "ecs_secrets_attachment" {
  policy_arn = aws_iam_policy.secrets_manager_policy.arn
  role       = aws_iam_role.ecs_task_execution_role.name
}