# ───────────────────────────────────────────────
# terraform.tfvars
# Edit these values before running `terraform apply`.
# Defaults below match your original eksctl script as closely as possible.
# ───────────────────────────────────────────────

aws_region   = "ap-south-1"
project_name = "raham"

# Bastion / Admin host — Ubuntu, m7i-flex.large, 30 GB EBS (as requested)
bastion_ami_id           = "ami-0e35ddab05955cf57" # Ubuntu 22.04 LTS - ap-south-1
bastion_instance_type    = "m7i-flex.large"
bastion_root_volume_size = 30
key_pair_name            = "eksss"          # must already exist in your AWS account
ssh_allowed_cidr         = "0.0.0.0/0"      # restrict to your IP in production, e.g. "203.0.113.10/32"

# Networking
vpc_cidr              = "10.0.0.0/16"
azs                   = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]
public_subnet_cidrs   = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
private_subnet_cidrs  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

# EKS Cluster
cluster_name    = "raham-cluster"
cluster_version = "1.32"

# EKS Managed Nodegroup
nodegroup_name       = "raham-cluster-ng-1"
node_instance_types  = ["t3.medium"] # t3.micro is too small for EKS worker nodes
node_volume_size     = 20
node_desired_size    = 2
node_min_size        = 2
node_max_size        = 6
