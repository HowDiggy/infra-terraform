terraform {
  required_version = ">= 1.3.0"
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

resource "libvirt_volume" "ubuntu_base" {
  name   = "ubuntu-noble-base.qcow2"
  pool   = "default"
  source = "${path.module}/images/noble-server-cloudimg-amd64.img"
  format = "qcow2"
}

resource "libvirt_volume" "ubuntu_disk" {
  name           = "hello-noble.qcow2"
  pool           = "default"
  base_volume_id = libvirt_volume.ubuntu_base.id
  size           = 20 * 1024 * 1024 * 1024
}

locals {
  ssh_pubkey = chomp(file("~/.ssh/id_ed25519.pub"))
}

resource "libvirt_cloudinit_disk" "hello_ci" {
  name = "hello-noble-seed.iso"

  user_data = <<-EOT
    #cloud-config
    users:
      - name: ubuntu
        sudo: ALL=(ALL) NOPASSWD:ALL
        groups: users, admin
        shell: /bin/bash
        ssh_authorized_keys:
          - ${local.ssh_pubkey}
    ssh_pwauth: false
    package_update: true
    packages:
      - qemu-guest-agent
  EOT

  meta_data = <<-EOT
    instance-id: hello-noble
    local-hostname: hello-noble
  EOT
}

resource "libvirt_domain" "hello" {
  name   = "hello-noble"
  memory = var.vm_memory_mb
  vcpu   = var.vm_vcpu

  cloudinit = libvirt_cloudinit_disk.hello_ci.id

  network_interface {
    bridge          = "br0"
    wait_for_lease  = true
  }

  disk {
    volume_id = libvirt_volume.ubuntu_disk.id
  }

  graphics {
    type        = "spice"
    listen_type = "none"
    autoport    = true
  }

  console {
    type        = "pty"
    target_type = "serial"
    target_port = "0"
  }
}
