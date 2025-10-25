output "vm_ids" {
  description = "A map of the VM names to their new VMIDs."
  
  # This loops over our 'module.vms' map.
  # 'k' is the key (e.g., "web-01")
  # 'v' is the value (the module object)
  # It builds a new map like: { "web-01" = 104, "web-02" = 105 }
  value = { for k, v in module.vms : k => v.vm_id }
}

output "vm_ipv4_addresses" {
  description = "A map of the VM names to their IPv4 addresses."
  
  # We do the same thing for the IP address
  value = { for k, v in module.vms : k => v.ipv4_address }
}

output "vm_ipv6_addresses" {
  description = "A map of the VM names to their IPv6 addresses."
  value = { for k, v in module.vms : k => v.ipv6_address }
}