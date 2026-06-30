variable "aws_region" {
  description = "AWS region to deploy all resources"
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Project name used as a prefix for all resources"
  type        = string
  default     = "raham"
}

# ───────────────────────────────
# Bastion / Admin EC2 instance vars
# ───────────────────────────────
variable "bastion_ami_id" {
  description = "Ubuntu 22.04 LTS AMI ID for the bastion/admin host (region-specific, update if changing region)"
  type        = string
  default     = "ami-0e35ddab05955cf57" # Ubuntu 22.04 LTS - ap-south-1 (Mumbai)
}

variable "bastion_instance_type" {
  description = "EC2 instance type for the bastion host"
  type        = string
  default     = "m7i-flex.large"
}

variable "bastion_root_volume_size" {
  description = "Root EBS volume size in GB for the bastion host"
  type        = number
  default     = 30
}

variable "key_pair_name" {
  description = "Existing EC2 key pair name for SSH access to the bastion host"
  type        = string
  default     = "eksss"
}

variable "ssh_allowed_cidr" {
  description = "CIDR block allowed to SSH into the bastion host — restrict this to your IP in production"
  type        = string
  default     = "0.0.0.0/0"
}

# ───────────────────────────────
# VPC vars
# ───────────────────────────────
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "azs" {
  description = "Availability zones to spread the EKS cluster and subnets across"
  type        = list(string)
  default     = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets (one per AZ)"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets (one per AZ) — EKS worker nodes live here"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

# ───────────────────────────────
# EKS Cluster vars
# ───────────────────────────────
variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "raham-cluster"
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS control plane"
  type        = string
  default     = "1.32"
}

# ───────────────────────────────
# EKS Managed Nodegroup vars
# ───────────────────────────────
variable "nodegroup_name" {
  description = "Name of the EKS managed nodegroup"
  type        = string
  default     = "raham-cluster-ng-1"
}

variable "node_instance_types" {
  description = "EC2 instance types for EKS worker nodes (t3.micro is too small for production EKS — using t3.medium)"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_volume_size" {
  description = "EBS root volume size in GB for each EKS worker node"
  type        = number
  default     = 20
}

variable "node_desired_size" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 2
}

variable "node_min_size" {
  description = "Minimum number of worker nodes for autoscaling"
  type        = number
  default     = 2
}

variable "node_max_size" {
  description = "Maximum number of worker nodes for autoscaling"
  type        = number
  default     = 6
}
