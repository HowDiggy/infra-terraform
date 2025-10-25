# 1. Terraform Configuration Block
terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.85"
    }
  }
}

# 2. Provider Configuration Block
provider "proxmox" {
  endpoint  = "https://192.168.1.6:8006/"
  insecure  = true
  api_token = var.proxmox_api_token
}

# 3. Call our VM Module (using for_each)
# We'll rename the module from "hello_vm" to "vms"
# to reflect that it's creating multiple.
module "vms" {
  # This is the core of Phase 3:
  # Iterate over the map we defined in variables.tf
  for_each = var.virtual_machines

  # This tells Terraform where to find the module code
  source = "../../modules/vm/pve-bpg"

  # --- Per-VM settings (from the loop) ---
  # 'each.value' refers to the object for "web-01", "web-02", etc.
  vm_hostname  = each.value.hostname
  vm_cpu_cores = each.value.cpu_cores
  vm_memory_mb = each.value.memory_mb
  disk_size_gb = each.value.disk_size

  # --- Environment-wide settings (same for all VMs) ---
  proxmox_node      = var.proxmox_node
  template_vm_id  = 9000 # Your golden image ID
  storage_pool      = "vms"  # Your LVM-Thin pool
  ci_ssh_public_key = file(var.ssh_public_key_path)
}