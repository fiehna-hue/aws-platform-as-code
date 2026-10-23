# Design decisions

Short records of the choices behind this platform and the trade-offs I accepted.

## Remote state in S3 with native locking
Terraform state lives in a versioned, encrypted S3 bucket and uses the S3 lock file (`use_lockfile`, Terraform 1.10+), so no DynamoDB table is needed. Fewer moving parts, and the pipeline and my laptop share one source of truth.

## GitHub Actions authenticates with OIDC, not access keys
No AWS keys are stored anywhere. Each run assumes a role with short-lived credentials, and the trust policy limits it to this repository. When the trust policy rejected a run, I diagnosed the cause in CloudTrail (incident log).

## Two roles: one reads, one writes
Pull requests assume `platform-github-plan`, which is read-only. Only merged code on `main` assumes `platform-github-apply`. A pull request can never change infrastructure. Trade-off: a read-only role cannot predict missing write permissions, so a first apply of a new resource type can fail once (incident 6).

## The apply role cannot edit itself
IAM changes are limited to roles named `platform-app-*`, which excludes the pipeline's own `platform-github-*` roles. Attaching managed policies is limited to one named policy, and `PassRole` only to ECS tasks. Known gap: inline policies on `platform-app-*` roles are not content-limited. A permissions boundary would close it.

## Interface endpoints instead of a NAT gateway
Tasks run in private subnets with no route to the internet. They reach ECR, CloudWatch Logs and Secrets Manager through interface endpoints, and S3 through a gateway endpoint. The cost is similar to NAT for a small setup. The benefit is that no internet egress path exists at all.

## RDS manages its own password
`manage_master_user_password` stores the password in Secrets Manager. It never appears in code, state variables, plan output or my terminal. The task execution role can read that one secret and nothing else.

## Secrets and personal values stay out of the public repository
The alert email and my allowed IP are sensitive Terraform variables fed from GitHub secrets, so they never show up in plan comments on a public repo.

## Destroy by pull request
Costly layers are removed by deleting their files in a pull request. The plan shows exactly what will go, the same gate approves it, and the destroy is auditable.
