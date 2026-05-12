# Bootstrap

One-time setup of the Terraform remote state backend.

This module creates:

- An S3 bucket for storing Terraform state files (versioned, encrypted, TLS-only).
- A DynamoDB table for state locking.

It is intentionally kept separate from the rest of the codebase because it
must exist before any other Terraform code can run (chicken-and-egg).

## When to run

Once per AWS account. After the first successful apply, you almost never
touch this module again.

## State location

This module's own state is **not stored remotely** — it would be circular.
It is kept in `terraform.tfstate` locally and **not committed** to git
(see `.gitignore`).

If you lose the local state, the resources can be re-imported:

\`\`\`bash
terraform import aws_s3_bucket.tf_state notes-api-tfstate-<account-id>
terraform import aws_dynamodb_table.tf_lock notes-api-tflock
\`\`\`

## Usage

\`\`\`bash
cd bootstrap/
terraform init
terraform apply -var="aws_account_id=123456789012"
\`\`\`

After apply, copy the `backend_config_snippet` output into the
`backend.tf` of each environment (replacing `<env>` with the
environment name, e.g. `dev`).

## Destroy

The state bucket has `prevent_destroy = true` to prevent accidental
deletion. To tear down:

1. Empty the bucket manually (or via AWS CLI), including all object versions.
2. Remove `prevent_destroy = true` from `main.tf` in a separate commit.
3. `terraform apply` to register the change.
4. `terraform destroy`.