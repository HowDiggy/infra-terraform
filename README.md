# infra-terraform
Terraform practice & real stacks, kept separate from my GitOps repo.  
This repo is structured for clean learning → cloud readiness → team workflows.

## Contents
- `envs/` — entrypoints per environment (local-libvirt now; dev/staging/prod later)
- `modules/` — reusable modules (vm, network, …)
- `global/state-backend/` — remote state bucket + lock table (Stage 2)
- `scripts/` — helper scripts for plan/apply, CI wrappers

---

## Learning Roadmap (Stages)

**Stage 0 — Mindset & Foundations**  
Understand declarative IaC, providers/resources/state, plan/apply/destroy.

**Stage 1 — Local First: Ubuntu + KVM/libvirt**  
- Hello VM via `libvirt` provider and cloud-init.  
- Variables, outputs, dependency graph.  
- Clean `destroy`.

**Stage 2 — State Like a Pro**  
- Remote state backend (S3/MinIO + locking).  
- Env isolation (dirs or workspaces).  
- Secrets hygiene.

**Stage 3 — Modularity & Reuse**  
- Module design, inputs/outputs, locals.  
- Examples + versioning.

**Stage 4 — Cloud Bootstrapping (Cost-aware)**  
- Minimal VPC + tiny compute (or managed k8s).  
- Ephemeral environments, TTL tags, budgets.

**Stage 5 — Teams & CI/CD**  
- Plan on PR, gated apply, policy-as-code, tests.

**Stage 6 — Images & Config**  
- Packer golden images; Ansible or cloud-init.

**Stage 7 — GitOps & Crossplane (Optional)**  
- Terraform for foundations, Crossplane CRDs via Argo CD.

**Stage 8 — Advanced Patterns**  
- Terragrunt (optional), multi-account, drift detection, finops.

---

## Quickstart (Stage 1)
1. `cd envs/local-libvirt`
2. Place an Ubuntu cloud image in `images/` (e.g., jammy cloudimg).
3. `terraform init && terraform plan && terraform apply`
4. SSH to the VM (key via cloud-init), then `terraform destroy`.

> State is **local** in Stage 1; move to remote state in Stage 2.

---

## Conventions
- Folder names: kebab-case; variables: snake_case.  
- Tag everything: `owner=paulo`, `env=local|dev|...`, `ttl`, `system`.  
- Never commit secrets or `*.tfstate`. Commit `.terraform.lock.hcl`.

