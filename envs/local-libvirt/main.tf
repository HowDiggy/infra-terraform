terraform {
  required_version = ">= 1.6.0"
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "~> 0.7"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}

# Example pool reference (uses the default libvirt pool by name)
data "libvirt_pool" "default" {
  name = "default"
}

# Base cloud image (place file under ./images/)
variable "base_image_path" {
  type        = string
  description = "Path to Ubuntu cloud image (e.g., images/jammy-server-cloudimg-amd64.img)"
  default     = "images/jammy-server-cloudimg-amd64.img"
}

resource "libvirt_volume" "base" {
  name   = "jammy-base.qcow2"
  pool   = data.libvirt_pool.default.name
  source = var.base_image_path
  format = "qcow2"
}

variable "vm_name"   { type = string, default = "demo-1" }
variable "vm_memory" { type = number, default = 2048 } # MB
variable "vm_vcpus"  { type = number, default = 2 }

resource "libvirt_volume" "disk" {
  name           = "${var.vm_name}.qcow2"
  pool           = data.libvirt_pool.default.name
  base_volume_id = libvirt_volume.base.id
  size           = 20 * 1024 * 1024 * 1024
}

# Simple cloud-init user-data (inject your SSH key below)
locals {
  user_data = <<-EOT
  #cloud-config
  hostname: ${var.vm_name}
  users:
    - name: ubuntu
      sudo: ALL=(ALL) NOPASSWD:ALL
      shell: /bin/bash
      ssh_authorized_keys:
        - ssh-ed25519 AAAA...replace_with_your_public_key...
  packages:
    - qemu-guest-agent
  runcmd:
    - systemctl enable --now qemu-guest-agent
  EOT
}

resource "libvirt_cloudinit_disk" "seed" {
  name      = "${var.vm_name}-seed.iso"
  pool      = data.libvirt_pool.default.name
  user_data = local.user_data
}

resource "libvirt_domain" "vm" {
  name   = var.vm_name
  memory = var.vm_memory
  vcpu   = var.vm_vcpus

  disk { volume_id = libvirt_volume.disk.id }
  cloudinit = libvirt_cloudinit_disk.seed.id

  # Default NAT network; switch to `bridge = "br0"` later if you have a bridge.
  network_interface {
    network_name = "default"
  }

  graphics {
    type       = "vnc"
    listen_type = "address"
    autoport   = true
  }
}

output "vm_name" {
  value = libvirt_domain.vm.name
}
