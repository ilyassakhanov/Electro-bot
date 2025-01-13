resource "aws_eks_cluster" "eks" {
  name     = "fargate-cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = [aws_default_subnet.public_subnet1.id, aws_default_subnet.public_subnet2.id, aws_default_subnet.public_subnet3.id]
  }

  depends_on = [aws_iam_role_policy_attachment.eks_cluster_policy]
}

# EKS Fargate profile
resource "aws_eks_fargate_profile" "fargate_profile" {
  cluster_name           = aws_eks_cluster.eks.name
  fargate_profile_name   = "fargate-profile"
  pod_execution_role_arn = aws_iam_role.eks_fargate_pod_role.arn
  subnet_ids = [aws_subnet.private_subnet1.id]

  selector {
    namespace = "default"
  }
}