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

resource "aws_iam_role" "eks_auto_cluster_role" {
  name = "AmazonEKSAutoClusterRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = [
        "sts:AssumeRole",
        "sts:TagSession"
      ]

      Principal = {
        Service = "eks.amazonaws.com"
      },
      Effect = "Allow"
    }]
  })
  tags = {
    Name = "eks_auto_cluster_role"
  }
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks_auto_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "eks_vpc_resource_controller_policy" {
  role       = aws_iam_role.eks_auto_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
}

resource "aws_iam_role_policy_attachment" "eks_vpc_block_storage_policy" {
  role       = aws_iam_role.eks_auto_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSBlockStoragePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_vpc_compute_policy" {
  role       = aws_iam_role.eks_auto_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSComputePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_vpc_load_balancing_policy" {
  role       = aws_iam_role.eks_auto_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSLoadBalancingPolicy"
}

resource "aws_iam_role_policy_attachment" "eks_vpc_networking_policy" {
  role       = aws_iam_role.eks_auto_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSNetworkingPolicy"
}
