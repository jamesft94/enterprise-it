# Enterprise IT Engineering Portfolio

A small reference repository for identity lifecycle, access policy, Linux endpoint compliance, and infrastructure-as-code practices. It is a portfolio/lab, not a production deployment or an implementation for Sensio. Organization names and tenant-specific values are examples; replace them with approved values before use.

## Design principles

- Automate how IT is run with infrastructure as code, Git, peer review, and reproducible changes.
- Simplify and prioritize: understand why things are the way they are, then make them simpler.
- Build security into how things work without unnecessary bureaucracy; monitor first and enforce later.
- Establish clear ownership for reliable operations and continuous improvement.

## Repository map

| Path | Purpose |
| --- | --- |
| `Terraform/` | One Terraform root for Entra groups, Conditional Access, break-glass exclusions, and a FreeIPA OIDC application. |
| `Ansible/` | Linux compliance checks, endpoint baseline, and Entra-to-FreeIPA group synchronization. |
| `docs/architecture.md` | Scope, operating assumptions, rollout boundaries, and validation guidance. |
| `.github/workflows/validate.yml` | Credential-free syntax and formatting checks. |

## Start here

1. Review [the architecture and safety notes](docs/architecture.md).
2. Install Terraform 1.9 or later and Ansible with the `community.general` and `freeipa.ansible_freeipa` collections.
3. Configure the AzureAD provider using its documented environment-based authentication. Supply at least two real break-glass UPNs through a local `Terraform/terraform.tfvars` file; local variable files are ignored by Git.
4. Run `terraform -chdir=Terraform fmt -check -recursive`, `terraform -chdir=Terraform init -backend=false`, and `terraform -chdir=Terraform validate` before considering a plan. Review the plan against a non-production tenant first.
5. Run Ansible in check mode against an explicitly scoped inventory before setting any enforcement variable. The FreeIPA synchronization playbook reports proposed group removals by default; applying them requires an explicit variable.

The Intune Terraform file currently produces illustrative payload data only. It does not create or assign Intune policies. The Linux playbooks also depend on a prepared inventory, supported distributions, configured package repositories, and credentials supplied outside the repository.

## Safety and scope

The repository is intentionally conservative: Conditional Access defaults to report-only, endpoint changes default to audit mode, and FreeIPA group removals are opt-in. These are sample guardrails, not a substitute for tenant-specific design, testing, operational approval, or incident procedures. See [the architecture notes](docs/architecture.md) for limitations and next steps.