
locals {
  cluster_name = "Electro"
}

# EKS Cluster IAM Role
resource "aws_iam_role" "eks_cluster_role" {
  name = "${local.cluster_name}-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "eks.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}


# Attach the AmazonEKSClusterPolicy to the role
resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

# EKS Node IAM Role
resource "aws_iam_role" "eks_node_role" {
  name = "${local.cluster_name}-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_ebs_csi_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  #role       = module.eks.module.eks_managed_node_group["main"].aws_iam_role.this[0].name
  role       = module.eks.eks_managed_node_groups["main"].iam_role_name
}


# --- EKS Cluster ---

# Use the official Terraform EKS module
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0" # Use a specific version for production

  cluster_name    = local.cluster_name
  cluster_version = "1.33"

  cluster_endpoint_public_access = true


  vpc_id     = aws_default_vpc.default.id
  subnet_ids = [aws_default_subnet.public_subnet1.id, aws_default_subnet.public_subnet2.id, aws_default_subnet.public_subnet3.id]

  # --- Managed Node Group for EC2 instances ---
  eks_managed_node_groups = {
    main = {
      name           = "${local.cluster_name}-node-group"
      instance_types = ["t3.medium"]
      min_size       = 1
      max_size       = 3
      desired_size   = 2

      iam_role_arn = aws_iam_role.eks_node_role.arn
    }
  }

  tags = {
    Environment = "development"
    Project     = "my-eks-project"
  }
  access_entries = {
    my_admin_role = {
      kubernetes_groups = []
      principal_arn     = "arn:aws:iam::247487031771:user/adminuser" # Or user ARN

      policy_associations = {
        my_admin_role = {
          policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          principal_arn = "arn:aws:iam::247487031771:user/adminuser"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }
  cluster_addons = {
  #   # for EFS
  #   aws-efs-csi-driver = { 
  #   most_recent              = true
  #   service_account_role_arn = aws_iam_role.efs_csi.arn  # Fixed typo: service_account_role_arn
  # }
  # PVC stuff
    aws-ebs-csi-driver = {
      most_recent             = true # Use the latest compatible version
      #service_accout_role_arn = aws_iam_role.efs_csi.arn
    }
  }
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name, "--region", var.region]  # Assumes var.region is defined; adjust if needed
  }
}

# PVC stuff
# EBS StorageClass for gp3 volumes
resource "kubernetes_storage_class" "gp3" {
  metadata {
    name = "gp3"
  }
  storage_provisioner = "ebs.csi.aws.com"
  parameters = {
    type      = "gp3"      # General-purpose SSD (cost-effective default)
    encrypted = "true"     # Enable EBS encryption
    iops      = "3000"     # Optional: Baseline IOPS for gp3 (default 3,000)
    throughput = "125"     # Optional: Baseline MiB/s (default 125)
  }
  volume_binding_mode = "WaitForFirstConsumer"  # Delays binding until pod scheduling (recommended for EBS to match AZ)
  allow_volume_expansion = true                 # Allows resizing PVCs later
  reclaim_policy        = "Delete"              # Or "Retain" to keep volumes after PVC deletion
}

# --- Outputs ---

output "cluster_endpoint" {
  description = "Endpoint for EKS cluster."
  value       = module.eks.cluster_endpoint
}

output "cluster_name" {
  description = "Name of the EKS cluster."
  value       = module.eks.cluster_name
}

output "kubeconfig_command" {
  description = "Command to configure kubectl."
  value       = "aws eks update-kubeconfig --region ${var.region} --name ${module.eks.cluster_name}"
}
