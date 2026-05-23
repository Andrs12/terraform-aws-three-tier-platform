#!/bin/bash
set -e

echo "========================================"
echo "  Destroying Three-Tier Platform"
echo "========================================"
echo ""

REGIONS=("alb" "compute" "database" "security" "networking")

for dir in "${REGIONS[@]}"; do
    echo "----------------------------------------"
    echo "Destroying $dir..."
    echo "----------------------------------------"
    cd "$dir"
    terraform destroy -auto-approve
    cd ..
    echo ""
done

echo "========================================"
echo "  All resources destroyed successfully!"
echo "========================================"
echo ""
echo "Note: Bootstrap resources (S3, DynamoDB, OIDC, IAM) are preserved."
echo "To destroy bootstrap resources, run manually:"
echo "  cd bootstrap && terraform destroy -auto-approve"
