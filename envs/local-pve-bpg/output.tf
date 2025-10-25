output "vm_id" {
  description = "The unique VMID of the created machine."
  # Get the 'vm_id' output FROM the 'hello_vm' module
  value = module.hello_vm.vm_id
}

output "vm_ipv4_address" {
  description = "The primary IPv4 address (from guest agent)."
  # Get the 'ipv4_address' output FROM the 'hello_vm' module
  value = module.hello_vm.ipv4_address
}

output "vm_ipv6_address" {
  description = "The primary IPv6 address (from guest agent)."
  value = module.hello_vm.ipv6_address
}