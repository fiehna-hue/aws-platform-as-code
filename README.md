# aws-platform-as-code

A secure, observable AWS platform for a containerized application, defined entirely in Terraform and deployed through a reviewed CI/CD pipeline.

This repo is being built in phases. The status below shows what is done and what is planned.

## Status

| Phase | Scope | Status |
|---|---|---|
| 1. Foundation | Remote state in S3 with native locking, cost budget as code | Done |
| 1. Foundation | Plan-on-pull-request pipeline with keyless AWS auth (OIDC) | Done |
| 2. Platform | Private-subnet network, VPC endpoints, ECS Fargate service, RDS, as reusable modules | Planned |
| 3. Operations | CloudWatch dashboard, alarms, SNS alerts, incident log | Planned |
| 4. Polish | Architecture diagram, decision records, runbook, cost and teardown notes | Planned |

## Repository layout

```
envs/
  dev/              root module for the dev environment
modules/            reusable modules (planned)
.github/workflows/  CI/CD (planned)
```

## Remote state

Terraform state is stored in a private, versioned, encrypted S3 bucket with public access blocked. Locking uses Terraform's native S3 lock file (`use_lockfile`), so no DynamoDB table is needed. The bucket is the one resource created by hand, because Terraform cannot store state in a bucket that does not exist yet.

## Run it

Requires Terraform 1.10 or newer and AWS credentials.

```bash
cd envs/dev
export TF_VAR_alert_email="you@example.com"
terraform init
terraform plan
terraform apply
```

The alert email is a variable with no default, so no personal address is committed to the repo.

## Cost

The foundation costs essentially nothing. A monthly budget with an alert at 80% of $10 is created as code. Later phases that use VPC endpoints and Fargate are deployed, tested, and destroyed within a session.

## Security notes

- No long-lived AWS keys in the repo or CI. The pipeline will authenticate with GitHub OIDC.
- IAM roles created by this project are prefixed `platform-`, and the deploying user is limited to that prefix.
- State and `.tfvars` files are git-ignored.- Pull requests run terraform plan with a read-only role, and the result is posted as a comment

- The plan role is read-only, so the pull request check cannot detect missing write permissions. A first apply of a new resource type may fail once and need a policy widened. Reviewers get the plan, not a guarantee of apply success.
