# ───────────────────────────────────────────────
# EKS Cluster + Managed Nodegroup
# Equivalent to your eksctl commands:
#   eksctl create cluster --name=raham-cluster --version 1.32 ...
#   eksctl utils associate-iam-oidc-provider ...
#   eksctl create nodegroup --cluster=raham-cluster --node-type=t3.micro ...
# ───────────────────────────────────────────────

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.31"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  cluster_endpoint_public_access = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  # Equivalent to: eksctl utils associate-iam-oidc-provider --approve
  enable_irsa = true

  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"
  }

  eks_managed_node_groups = {
    (var.nodegroup_name) = {
      instance_types = var.node_instance_types
      capacity_type  = "ON_DEMAND"

      min_size     = var.node_min_size
      max_size     = var.node_max_size
      desired_size = var.node_desired_size

      disk_size = var.node_volume_size

      # Equivalent to: --ssh-access --ssh-public-key=eksss
      remote_access = {
        ec2_ssh_key               = var.key_pair_name
        source_security_group_ids = [aws_security_group.bastion_sg.id]
      }

      # Equivalent to: --asg-access --external-dns-access
      #                --full-ecr-access --appmesh-access --alb-ingress-access
      iam_role_additional_policies = {
        AmazonEKSWorkerNodePolicy          = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
        AmazonEKS_CNI_Policy               = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
        AmazonEC2ContainerRegistryFullAccess = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
        AmazonEC2ContainerRegistryReadOnly = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
        ElasticLoadBalancingFullAccess     = "arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess"
        AutoScalingFullAccess              = "arn:aws:iam::aws:policy/AutoScalingFullAccess"
      }

      labels = {
        role = "worker"
      }

      tags = {
        Name = "${var.project_name}-eks-node"
      }
    }
  }

  # Allow the bastion host to reach the cluster API
  cluster_security_group_additional_rules = {
    ingress_from_bastion = {
      description              = "Allow bastion host to access EKS API"
      protocol                 = "tcp"
      from_port                = 443
      to_port                  = 443
      type                     = "ingress"
      source_security_group_id = aws_security_group.bastion_sg.id
    }
  }

  tags = {
    Name = var.cluster_name
  }
}
