terraform {
  required_version = ">= 1.3.0"
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "~> 0.8.3"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}

resource "libvirt_volume" "ubuntu_disk" {
  name   = "hello-noble.qcow2"
  pool   = "default"
  source = "${path.module}/images/noble-server-cloudimg-amd64.img"
  format = "qcow2"
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
    runcmd:
      - systemctl enable --now qemu-guest-agent
  EOT

    # NetworkConfig v2 with MAC match so it applies regardless of interface name
  network_config = <<-EONET
    version: 2
    ethernets:
      nic0:
        match:
          macaddress: 52:54:00:0a:24:18
        set-name: ens3
        dhcp4: false
        addresses: [192.168.1.164/24]
        gateway4: 192.168.1.1
        nameservers:
          addresses: [1.1.1.1,8.8.8.8]
  EONET

  meta_data = <<-EOT
    instance-id: hello-noble-static1
    local-hostname: hello-noble
  EOT
}

resource "libvirt_domain" "hello" {
  name   = "hello-noble"
  memory = var.vm_memory_mb
  vcpu   = var.vm_vcpu

  # Let libvirt expose the virtio-serial channel for qemu-guest-agent
  qemu_agent = true

  cloudinit = libvirt_cloudinit_disk.hello_ci.id

  network_interface {
    bridge         = "br0"
    mac            = "52:54:00:0a:24:18"
    wait_for_lease = false
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

