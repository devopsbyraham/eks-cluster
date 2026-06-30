# ───────────────────────────────────────────────
# Outputs — everything you need after `terraform apply`
# ───────────────────────────────────────────────

output "cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "EKS cluster API endpoint"
  value       = module.eks.cluster_endpoint
}

output "cluster_version" {
  description = "Kubernetes version running on the EKS control plane"
  value       = module.eks.cluster_version
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = module.eks.cluster_security_group_id
}

output "vpc_id" {
  description = "VPC ID where EKS and the bastion host are deployed"
  value       = module.vpc.vpc_id
}

output "oidc_provider_arn" {
  description = "IAM OIDC provider ARN (equivalent to: eksctl utils associate-iam-oidc-provider)"
  value       = module.eks.oidc_provider_arn
}

output "configure_kubectl" {
  description = "Run this command on the bastion host (or locally) to configure kubectl"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}"
}

output "nodegroup_name" {
  description = "EKS managed nodegroup name"
  value       = var.nodegroup_name
}
