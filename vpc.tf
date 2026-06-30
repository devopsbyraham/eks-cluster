# ───────────────────────────────────────────────
# VPC + Subnets for EKS
# Public subnets  → bastion host, NAT gateway, load balancers
# Private subnets → EKS worker nodes (best practice: nodes never get public IPs)
# ───────────────────────────────────────────────

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.8"

  name = "${var.project_name}-vpc"
  cidr = var.vpc_cidr

  azs             = var.azs
  public_subnets  = var.public_subnet_cidrs
  private_subnets = var.private_subnet_cidrs

  enable_nat_gateway   = true
  single_nat_gateway   = true # cost-optimised: one NAT gateway shared across all AZs
  enable_dns_hostnames = true
  enable_dns_support   = true

  # Required tags for EKS to auto-discover subnets for load balancers
  public_subnet_tags = {
    "kubernetes.io/role/elb"                       = "1"
    "kubernetes.io/cluster/${var.cluster_name}"    = "shared"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb"              = "1"
    "kubernetes.io/cluster/${var.cluster_name}"    = "shared"
  }

  tags = {
    Name = "${var.project_name}-vpc"
  }
}
