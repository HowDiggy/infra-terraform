# 1. Terraform Configuration Block
# This tells Terraform which providers we need and where to get them.
terraform {
  required_providers {
    # The provider's "nickname" is "proxmox"
    # The "source" is its official address on the Terraform Registry.
    proxmox = {
      source  = "telmate/proxmox"
      # Use the 3.x series for Proxmox 9 compatibility
      version = "3.0.2-rc05"
    }
  }
}

# 2. Provider Configuration Block
# This configures the "proxmox" provider itself.
provider "proxmox" {
  # This is the URL to your Proxmox API.
  # Set this to your Proxmox server's IP or hostname.
  # Setting 'insecure = true' as we're on a local homelab
  # using a self-signed certificate.
  pm_api_url = "https://192.168.1.6:8006/api2/json"
  pm_tls_insecure = true

  # No credentials here! The provider automatically
  # reads them from your environment variables:
  # PM_API_TOKEN_ID
  # PM_API_TOKEN_SECRET
}

# 3. The "Hello, VM" Resource
# This is the actual "blueprint" for our virtual machine.
resource "proxmox_vm_qemu" "hello_vm" {
  # --- Basic Settings ---
  # We use our variables here
  name        = var.vm_hostname
  target_node = var.proxmox_node

  # --- Cloning ---
  # Tell it which template to clone
  clone = var.template_name

  # 'full = true' creates a full, independent copy of the disk.
  # 'full = false' (default) creates a linked clone, which is faster
  # but depends on the template. For production, full is safer.
  full_clone = true

  # --- Hardware ---
  # Enable the QEMU Guest Agent we set up in the template
  agent   = 1
  cpu { cores = 2}
  memory  = 2048
  scsihw  = "virtio-scsi-pci"

  # --- Network ---
  # This block defines one network card (net0)
  network {
    id      = 0 # REQUIRED in v3.x (for net0)
    model   = "virtio"
    bridge  = "vmbr0" # Assumes vmbr0 is your main bridge
    firewall = false
  }

  # --- Storage ---
  # This block defines our primary disk (scsi0)
  disk {
    slot    = "scsi0" # REQUIRED in v3.x (for scsi0)
    type    = "disk"
    storage = "vms"   # Must match your storage pool name
    size    = "32G"   # Resize the disk to 32GB
  }

  # --- Cloud-Init ---
  # 'ipconfig0' sets the first network card (net0) to use DHCP.
  ipconfig0 = "ip=dhcp"
  # >>> These three lines stop Terraform from "losing" CI/console
  boot  = "order=scsi0;net0"
  
  vga {
    type = "serial0"
  }
  
  serial {
    id   = 0
    type = "socket"
  }
  onboot = true

  cicustom = "user=local:snippets/keep-ci.yaml"



  # This is the most important part. We inject your
  # public SSH key so you can log in as the default user.
  # !! REPLACE THIS WITH YOUR ACTUAL PUBLIC SSH KEY !!
  sshkeys = <<EOF
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDKzjdqzlAVvmdddju9iTmqmu7kRTndYlVN1H1LTXFThWuC+CAXoJDVdktHb/0X9Lalag/Pc1wX1ebbaZFXJi9XlecUxXTXEhw9jkw3tZNzxFvAQZm+yINPiGWrpjFrkjrUIheFUqK1eFXAbt4xBx5sEHs2UCiXmE6mSpoLlRAKpjn1kuL2rqWEJuAe4r8rFuhNUm+nvpdKTRPwEewq4jeHz7IcE9z3NK/EV6zGxDKHeviuJ+n2/DFWB9Zah5crzgxCSQm2C18uu5dGL728zVUEkj0yNVcmt/guqk71ge2m5b4/dKLEKXrDoB/3dnoRNlIhmy9+x8gD5a/MrtrZsMy8XKjonQVbYoGfEYZzFWRK0YN4Po7T5TyK5IfBzKl4M0hvGJH6NoOTeZp+YmLfgN4hWf+EBEFXyV1B3AqZpUDowqEXNHoBXFpLTnzACqegSDyzNndkg7NkFh9ZIQRBdiX93rVZmgRahe0UKIIdprpoeEwQ4Y+ztcA/toMzNNtlplh8kYc2gFQ5AMoMbsVhn8FJM2aJImWtThtDEg8P86yjaQH/3IgcGKOVQGyydRUN71fx7skk9RvqRVWR9+fFLrFi42E2vSb0EQQsglWTXuZuzYN+kyEtAWXdq+zhP9OXyrgmJ+ADXiU4a5GU5yuG0xwepcl4Z91zLqk0Z0rUeTMbrw== jauregui.paulo@gmail.com
EOF
}
