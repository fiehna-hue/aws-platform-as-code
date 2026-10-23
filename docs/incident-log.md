# Incident log

Problems hit while building this platform, how each was found, and what changed. Dated 2026-10-22 and 2026-10-23.

## 1. Plan failed on a missing permission (budgets)

- **Symptom:** the first pull request check failed during `terraform plan` with `AccessDeniedException` on `budgets:ListTagsForResource`.
- **Diagnosis:** the pipeline posts the plan output as a pull request comment, and the error named the exact action and the assumed role.
- **Cause:** the read-only plan role was scoped by hand, and `budgets:ViewBudget` does not cover tag reads, which the Terraform provider performs on refresh.
- **Fix:** added `budgets:ListTagsForResource` to the role's inline policy and reran the check.
- **Lesson:** build least-privilege roles iteratively from real errors, and make failures visible on the pull request.

## 2. Network module blocked at plan (EC2 read access)

- **Symptom:** the pull request for the network module failed its plan, and the merge was blocked by the required check.
- **Diagnosis:** the plan comment ended with `UnauthorizedOperation` for `ec2:DescribeAvailabilityZones` from the plan role.
- **Cause:** the policy granting EC2 read access had been written but never attached to the role.
- **Fix:** attached the policy, verified with `list-role-policies`, reran the check, then merged.
- **Lesson:** verify that a permission change took effect before relying on it. The branch rule stopped an unverified change from reaching `main`.

## 3. Branch protection did not block direct pushes

- **Symptom:** a deliberate test push straight to `main` succeeded.
- **Diagnosis:** a rejected push prints `GH013: Repository rule violations found`, and that message was absent. A rules query showed the ruleset was not enforcing.
- **Cause:** the ruleset was not set to Active.
- **Fix:** activated it and retested. The push was then rejected with `Required status check "plan" is expected`.
- **Lesson:** test a control rather than assuming it works.

## 4. Required check could deadlock documentation changes

- **Symptom:** none yet. Found during design review before enabling the rule.
- **Diagnosis:** the plan workflow only ran for Terraform paths. A required check that never runs leaves a pull request waiting forever.
- **Cause:** a path filter on the workflow combined with a required status check.
- **Fix:** removed the path filter so the plan runs on every pull request. The apply workflow keeps its path filter, since nothing requires it.
- **Lesson:** a required check must always report.

## 5. Alert address set to a placeholder

- **Symptom:** the plan showed the budget alert email as `your-email@example.com`.
- **Diagnosis:** read the plan before applying.
- **Cause:** a documentation example value was exported as a real variable.
- **Fix:** set the correct address and applied. The variable is now marked sensitive and stored as a CI secret, so it never appears in plan comments.
- **Lesson:** read the plan, and treat addresses and secrets as inputs, not code.


## 6. Database apply failed on a missing Secrets Manager permission

- **Symptom:** the pull request plan passed and was merged, then the apply failed after 30 seconds with `The user isn't authorized to create a secret in AWS Secrets Manager`.
- **Diagnosis:** `gh run view --log-failed` showed the security groups, subnet group and ingress rule had been created, and only the database instance failed.
- **Cause:** with `manage_master_user_password`, RDS creates the password secret using the caller's permissions, and the apply role had none for Secrets Manager. The read-only plan role cannot catch missing write permissions, so the pull request check was green.
- **Fix:** added secret create, tag and delete permissions scoped to secrets named `rds!db-*`, plus KMS access limited to calls made through RDS and Secrets Manager, then reran only the failed job. Terraform resumed from saved state and created the one missing resource.
- **Lesson:** a read-only plan role cannot predict missing write permissions, so the first apply of a new service type may need one round of widening. The partial failure left nothing half-built, because state records each resource as it completes.
## 7. Apply failed on missing variables that the plan had

- **Symptom:** after merging the service module, the apply failed in 19 seconds with `No value for required variable` for `allowed_cidr` and `image_tag`. The pull request plan had passed.
- **Diagnosis:** `gh run view --log-failed` named the two variables. The failure came before any resource was created, so nothing needed cleaning up.
- **Cause:** the two new variables were wired into the plan workflow but not the apply workflow. The two workflows carry their own copy of the environment.
- **Fix:** added both `TF_VAR_` lines to the apply step through a pull request, then merged. The apply built the service.
- **Lesson:** a new required input must be wired into every workflow that runs Terraform. A shared reusable workflow would remove the duplication.

## 8. A hand edit corrupted a workflow file and silently stopped the checks

- **Symptom:** a pull request showed "no checks reported", so the required `plan` check never started and the merge was blocked.
- **Diagnosis:** the commit summary said 17 insertions and 36 deletions for what should have been a 2-line change. `git diff origin/main --stat` showed the plan workflow had been rewritten, although I had not meant to touch it.
- **Cause:** a rich-text editor saved the YAML file with changed formatting, which broke the workflow.
- **Fix:** restored the file from `main` with `git checkout origin/main -- <file>`, made the 2-line change with `sed`, and confirmed the net diff was `2 insertions(+)` before pushing.
- **Lesson:** compare the diff stat with the change you intended before pushing. Edit YAML with plain-text tools. A required check that never starts usually means the workflow file itself is broken.
