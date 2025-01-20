# module "eks" {
#   source  = "terraform-aws-modules/eks/aws"
#   version = "~> 20.33"

#   cluster_name                             = "fargate-cluster"
#   cluster_version                          = "1.31"
#   cluster_endpoint_public_access           = true
#   enable_cluster_creator_admin_permissions = true

#   cluster_compute_config = {
#     enabled    = true
#     node_pools = ["general-purpose"]
#   }
#   vpc_id     = aws_default_vpc.default.id
#   subnet_ids = [aws_default_subnet.public_subnet1.id, aws_default_subnet.public_subnet2.id, aws_default_subnet.public_subnet3.id]
# }

resource "aws_eks_cluster" "eks" {
  name     = "fargate-cluster"
  role_arn = aws_iam_role.eks_auto_cluster_role.arn


  vpc_config {
    subnet_ids          = [aws_default_subnet.public_subnet1.id, aws_default_subnet.public_subnet2.id, aws_default_subnet.public_subnet3.id]
    public_access_cidrs = ["0.0.0.0/0"]
  }

  # EKS Auto Mode config
  bootstrap_self_managed_addons = false
  compute_config {
    node_pools = [
      "general-purpose",
      "system"
    ]
    enabled       = true
    node_role_arn = aws_iam_role.eks_auto_cluster_role.arn
  }

  kubernetes_network_config {
    elastic_load_balancing {
      enabled = true
    }
  }

  storage_config {
    block_storage {
      enabled = true
    }
  }

  depends_on = [aws_iam_role_policy_attachment.eks_cluster_policy]
}

# EKS Fargate profile
# resource "aws_eks_fargate_profile" "fargate_profile" {
#   cluster_name           = aws_eks_cluster.eks.name
#   fargate_profile_name   = "fargate-profile"
#   pod_execution_role_arn = aws_iam_role.eks_fargate_pod_role.arn
#   subnet_ids = [aws_subnet.private_subnet1.id]

#   selector {
#     namespace = "default"
#   }
# }