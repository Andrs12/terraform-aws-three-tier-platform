#!/bin/bash
set -e

echo "========================================"
echo "  Destroying Three-Tier Platform"
echo "========================================"
echo ""

echo "Running terraform destroy from root..."
terraform destroy -auto-approve

echo ""
echo "========================================"
echo "  All resources destroyed successfully!"
echo "========================================"
echo ""
echo "Note: Bootstrap resources (S3, DynamoDB, OIDC, IAM) are preserved."
echo "To destroy bootstrap resources, run manually:"
echo "  cd bootstrap && terraform destroy -auto-approve"
