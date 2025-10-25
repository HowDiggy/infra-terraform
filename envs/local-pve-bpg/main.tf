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

# 3. Call our new VM Module
module "hello_vm" {
  # This tells Terraform where to find the module code
  source = "../../modules/vm/pve-bpg"

  # These are the inputs we defined in the module's variables.tf
  vm_hostname       = var.vm_hostname
  proxmox_node      = var.proxmox_node
  template_vm_id  = 9000 # Your golden image ID
  storage_pool      = "vms"  # Your LVM-Thin pool

  # We'll read the SSH key content using the file() function
  ci_ssh_public_key = file(var.ssh_public_key_path)

  # You can override other defaults here if needed:
  # vm_cpu_cores = 4
  # vm_memory_mb = 4096
  # disk_size_gb = 50
}