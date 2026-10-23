# Incident log

Problems hit while building this platform, how each was found, and what changed. All dated 2026-10-22.

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