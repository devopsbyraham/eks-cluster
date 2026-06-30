#!/bin/bash
# ───────────────────────────────────────────────
# Bastion Bootstrap Script
# Automates everything from the original manual STEP-1 and STEP-2:
#   - apt update + unzip
#   - AWS CLI v2 installation
#   - kubectl installation (v1.35.0 to match your original script)
#   - eksctl installation
# Runs automatically on first boot via EC2 user_data — no manual SSH needed.
# ───────────────────────────────────────────────
set -euo pipefail

LOGFILE="/var/log/bastion-bootstrap.log"
exec > >(tee -a "$LOGFILE") 2>&1

echo "==== Bastion bootstrap started at $(date) ===="

# STEP 1: System update
apt-get update -y
apt-get install -y unzip curl wget tar git jq

# STEP 2a: AWS CLI v2 installation
cd /tmp
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -o awscliv2.zip
./aws/install
aws --version

# STEP 2b: kubectl installation (matching your specified v1.35.0)
curl -LO "https://dl.k8s.io/release/v1.35.0/bin/linux/amd64/kubectl"
chmod +x kubectl
mv kubectl /usr/local/bin/kubectl
kubectl version --client

# STEP 2c: eksctl installation
curl -L "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_Linux_amd64.tar.gz" -o eksctl.tar.gz
tar -xzvf eksctl.tar.gz -C /tmp
mv /tmp/eksctl /usr/local/bin/eksctl
eksctl version

# STEP 2d: helm installation (useful for installing add-ons post-cluster-creation)
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Configure kubectl to talk to the cluster created by Terraform automatically
# (Terraform already created the cluster — this just wires up local kubeconfig)
echo "export AWS_REGION=${aws_region}" >> /home/ubuntu/.bashrc
echo "aws eks update-kubeconfig --region ${aws_region} --name ${cluster_name}" >> /home/ubuntu/.bashrc

echo "==== Bastion bootstrap completed at $(date) ===="
echo "Run: aws eks update-kubeconfig --region ${aws_region} --name ${cluster_name}"
echo "Then: kubectl get nodes"
