#!/bin/bash
cd terraform

echo "Destroying Terraform resources..."

# From your Terraform directory
terraform destroy -auto-approve

echo "Cleaning up local Terraform files..."
rm -f terraform.tfstate
rm -f terraform.tfstate.backup
rm -rf .terraform/
rm -f .terraform.lock.hcl
cd ..

rm -f ~/.kube/config

echo "Cleanup complete!"
echo "Run 'az group list' to verify all resources are deleted"

