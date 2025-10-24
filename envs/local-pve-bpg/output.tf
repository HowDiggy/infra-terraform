output "vm_id" {
  description = "The unique VMID of the created machine."
  value       = proxmox_virtual_environment_vm.hello.id
}

output "vm_ipv4_address" {
  description = "The primary IPv4 address (from guest agent)."
  # The 'try' function gracefully handles 'null' if the
  # guest agent hasn't reported an IP yet.
  value = try(proxmox_virtual_environment_vm.hello.ipv4_addresses[0], "ip-pending")
}

output "vm_ipv6_address" {
  description = "The primary IPv6 address (from guest agent)."
  value       = try(proxmox_virtual_environment_vm.hello.ipv6_addresses[0], "ip-pending")
}