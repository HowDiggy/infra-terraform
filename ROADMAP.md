# Stage 1 — Terraform + libvirt (Local First)

## Goal
Provision/destroy local VMs via `libvirt` using Terraform to learn the `init → plan → apply → destroy` loop, variables, outputs, and state — fully offline and cost-free.

## Environment
- Ubuntu Server 24.04, KVM/libvirt, bridge `br0`
- Terraform v1.13.x, libvirt provider v0.8.3
- Storage pool: default → /var/lib/libvirt/images

## Exercises

### A — Prereqs (Done)
Installed KVM/libvirt, Terraform; verified `/dev/kvm`, `virsh` connectivity; set up bridge `br0`.

### B — Workspace (Done)
Repo at `envs/local-libvirt/` with `images/`; downloaded stable Noble cloud image.

### C — Minimal Config (Done)
Provider, full-clone qcow2 disk (no backing), cloud-init (ssh key + qemu-guest-agent), domain on `br0`.

### D — Hello VM (Lifecycle)
- `terraform init && terraform plan && terraform apply`
- SSH to `ubuntu@<output hello_vm_ip>`
- `terraform destroy` (verify domain & qcow2 removed), re-`apply` once to validate clean rebuild.

### E — Networking & Variables
- Parameters: `vm_memory_mb`, `vm_vcpu`
- Bridge: `br0`
- Output: `hello_vm_ip` (from guest agent)

## Runbook
- Apply: `terraform -chdir=envs/local-libvirt apply -auto-approve`
- IP (agent): `virsh -c qemu:///system domifaddr hello-noble --source agent`
- Destroy: `terraform -chdir=envs/local-libvirt destroy -auto-approve`

## Notes
- Dev mode: libvirt `security_driver="none"` to bypass AppArmor while learning.
- Later: re-enable confinement; either allowlist `/var/lib/libvirt/images/**` or keep full-clone disks.
