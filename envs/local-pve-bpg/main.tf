# 1. Terraform Configuration Block
# We declare the required 'bpg/proxmox' provider.
terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      # Using a recent version with PVE 9 support
      version = "~> 0.85"
    }
  }
}

# 2. Provider Configuration Block
# We configure the provider with our server details.
provider "proxmox" {
  # Your Proxmox API endpoint
  endpoint = "https://192.168.1.6:8006/"
  
  # We're on a homelab with a self-signed cert
  insecure = true

  # The API token is passed in as a sensitive variable
  # This is the full string: "user@realm!token-name=secret-uuid"
  api_token = var.proxmox_api_token
}

# 3. The "Hello, VM" Resource
# This is our "blueprint" using the bpg provider.
resource "proxmox_virtual_environment_vm" "hello" {
  name     = var.vm_hostname # e.g., "hello-vm"
  node_name = var.proxmox_node # e.g., "pve"

  # --- Cloning ---
  # Tell it which template to clone (your template ID)
  clone {
    vm_id = 9000
  }

  # --- Hardware ---
  # Enable the QEMU Guest Agent
  agent {
    enabled = true
  }

  # --- Network ---
  # Define one network card on your bridge
  network_device {
    bridge = "vmbr0"
  }

  # --- Storage ---
  # Define the primary disk and resize it
  disk {
    interface   = "scsi0"
    datastore_id = "vms" # LVM-Thin storage pool
    size        = 32    # Size in GB
  }

  # --- Console ---
  # Required for a clean boot/CI process
  serial_device {
    device = "socket"
  }

  # --- Cloud-Init ---
  # This is the modern 'bpg' way to handle cloud-init.
  # No more 'ide2' or boot order hacks.
  initialization {
    # Where to store the cloud-init drive
    datastore_id = "vms"

    # Define the default user and inject your SSH key
    user_account {
      username = "ubuntu" # The default user in your cloud image
      # This reads your local public key file
      keys = [file("~/.ssh/id_ed25519.pub")]
    }

    # Configure the network for DHCP
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
  }
}