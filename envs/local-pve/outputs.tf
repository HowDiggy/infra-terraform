# 4. Output the VM's IP Address
# Primary IPv4 (from guest agent via provider)
output "vm_ip_address" {
  description = "Primary IPv4 of the new VM (from guest agent)."
  value       = try(proxmox_vm_qemu.hello_vm.default_ipv4_address, null)
}

# Optional: IPv6 if the provider exposes it in your build
output "vm_ipv6_address" {
  value = try(proxmox_vm_qemu.hello_vm.default_ipv6_address, null)
}
