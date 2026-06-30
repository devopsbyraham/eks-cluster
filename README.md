# EKS + Bastion Terraform Setup

This Terraform project converts your manual `eksctl` + bash script into fully automated, repeatable Infrastructure as Code.

## What this creates

| Resource                     | Equivalent to your original script step                                      |
|-------------------------------|--------------------------------------------------------------------------------|
| VPC + 3 public + 3 private subnets | Required networking (your script relied on default VPC implicitly via eksctl) |
| Bastion EC2 (Ubuntu, `m7i-flex.large`, 30 GB EBS) | Manual host where you ran Step 1 & Step 2 commands |
| `user_data` bootstrap script  | STEP-1 (apt update, unzip) + STEP-2 (AWS CLI, kubectl, eksctl install) — now automatic |
| EKS Cluster (`raham-cluster`, v1.32) | `eksctl create cluster --name=raham-cluster --version 1.32 ...` |
| IAM OIDC Provider             | `eksctl utils associate-iam-oidc-provider --approve` |
| EKS Managed Nodegroup         | `eksctl create nodegroup --cluster=raham-cluster ...` |

## Key fixes applied vs. your original script

1. **Removed the second cluster/nodegroup in `us-east-1`** — your script had `raham-cluster2` as the cluster name in the second `eksctl create nodegroup` command, but the `--cluster` flag still pointed to a cluster that doesn't exist there. EKS clusters are also region-bound — a nodegroup cannot span two regions under one cluster. If you genuinely need multi-region, that requires two separate cluster definitions (see "Going multi-region" below).
2. **`t3.micro` → `t3.medium`** for worker nodes. `t3.micro` (1 vCPU, 1 GB RAM) is below the practical minimum for EKS worker nodes — kubelet, kube-proxy, and the CNI plugin alone consume a large share of that memory, leaving little for actual pods.
3. **Nodes placed in private subnets** — production best practice. Only the bastion host gets a public IP.
4. **All IAM policies your eksctl flags implied** (`--asg-access`, `--external-dns-access`, `--full-ecr-access`, `--appmesh-access`, `--alb-ingress-access`) are attached as explicit IAM policies on the node IAM role.

## File structure

```
eks-terraform/
├── providers.tf          # AWS + Kubernetes provider config
├── variables.tf          # All configurable inputs
├── vpc.tf                # VPC, public/private subnets
├── bastion.tf            # Bastion EC2 host + security group
├── eks.tf                # EKS cluster + managed nodegroup
├── outputs.tf            # Cluster endpoint, kubeconfig command, etc.
├── terraform.tfvars      # Your actual values — edit this file
└── scripts/
    └── bastion_bootstrap.sh.tpl   # Runs AWS CLI/kubectl/eksctl install on first boot
```

## Prerequisites

1. Terraform >= 1.5.0 installed locally
2. AWS credentials configured (`aws configure` or environment variables) with permissions to create VPC, EC2, EKS, and IAM resources
3. An existing EC2 key pair named `eksss` in `ap-south-1` (or update `key_pair_name` in `terraform.tfvars`)

## One-shot deployment

```bash
# 1. Initialize Terraform (downloads providers + modules)
terraform init

# 2. Review the plan
terraform plan

# 3. Apply — creates VPC, bastion host, EKS cluster, and nodegroup in one command
terraform apply -auto-approve
```

This single `terraform apply` will:
- Create the VPC and subnets
- Launch the bastion host and auto-install AWS CLI, kubectl, eksctl, and helm via `user_data`
- Provision the EKS cluster control plane
- Associate the IAM OIDC provider (enables IRSA for future add-ons like cluster-autoscaler, ALB ingress controller)
- Create the managed nodegroup with 2 nodes (autoscaling between 2 and 6)

Typical apply time: **15–20 minutes** (EKS control plane provisioning is the slowest part — usually 10-12 minutes alone).

## After apply — connect to your cluster

```bash
# Get all outputs including bastion IP and kubeconfig command
terraform output

# SSH into the bastion host
ssh -i eksss.pem ubuntu@$(terraform output -raw bastion_public_ip)

# On the bastion host, configure kubectl (also auto-added to .bashrc)
aws eks update-kubeconfig --region ap-south-1 --name raham-cluster

# Verify nodes are up
kubectl get nodes
kubectl cluster-info
```

## Going multi-region (if you actually need the second cluster)

If you do want a second cluster in `us-east-1` as your original script attempted, duplicate this entire project into a second directory (e.g. `eks-terraform-us-east-1/`) with its own `terraform.tfvars` pointing `aws_region = "us-east-1"` and a distinct `cluster_name`. EKS has no native cross-region cluster support — each region needs its own independent Terraform state and apply.

## Destroying everything

```bash
terraform destroy -auto-approve
```

This tears down the nodegroup, cluster, bastion host, and VPC in the correct dependency order — no manual cleanup needed.
