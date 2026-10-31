# Architecture and Operating Notes

## Scope

This repository demonstrates a compact Enterprise IT automation portfolio. Terraform is a single root because its Entra group, Conditional Access, break-glass, and FreeIPA application resources reference one another directly. Ansible remains separate because it performs host and identity operations rather than provisioning those Entra resources.

All organization names, addresses, identifiers, redirect URIs, and sample data are illustrative. This repository is not affiliated with any corporation and is not ready to apply to a real tenant or fleet without replacing those values and completing the controls below.

## Change flow

1. Make a small change on a branch and open a pull request.
2. Run Terraform formatting, initialization, validation, and plan review without production credentials in CI.
3. Run Ansible syntax checks and check-mode review against a test inventory.
4. Deploy identity or access changes to a pilot group, inspect sign-in and endpoint results, and record an owner-approved rollback path.
5. Promote enforcement only after the agreed observation period and operational review.

The actual observation period is an organizational decision. Report-only policy state is configured in Terraform; the repository does not implement a timer or automatically promote policies.

## Important implementation boundaries

- `Terraform/` is one state boundary. Configure provider authentication and real break-glass identities locally; never commit state, plans, credentials, or tenant-specific variable files.
- Conditional Access policies default to `enabledForReportingButNotEnforced`. Enforcement is an explicit variable change and requires review in the target tenant.
- `Terraform/intune-payloads.tf` constructs sample payloads only. Platform schemas, rule names, remediation timing, policy creation, and assignments still need a separately reviewed Microsoft Graph integration.
- The FreeIPA playbook follows Microsoft Graph pagination and requires a non-empty membership snapshot before reconciliation. It can add active users to the synchronized group. Group removals are reported but not applied unless `apply_deprovisioning=true`; the candidate threshold must also be reviewed. It removes membership, not the underlying FreeIPA account.
- FreeIPA and Linux playbooks require a prepared inventory, appropriate collections, target-host prerequisites, and credentials from a secret manager or environment variables. Do not use the example inventory or values as production defaults.
- The LUKS check inspects the root device's backing chain. Treat its output as a signal to investigate, not as a complete certification of disk encryption.

## Before production use

- Add environment-specific variable files outside version control and validate resource ownership, permissions, exclusions, API permissions, and provider compatibility in a test tenant.
- Add automated tests for membership edge cases, Graph throttling/retries, empty or partial snapshots, group ownership, and rollback procedures.
- Define named operational owners, approval requirements, alerting, an observation window, and emergency access monitoring.
- Confirm local legal, privacy, and ISO 27001 control mappings; the labels in code are references, not audit evidence.
