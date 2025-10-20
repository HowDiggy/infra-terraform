output "hello_vm_ip" {
  description = "IP address of the hello-noble VM"
  value       = try(libvirt_domain.hello.network_interface[0].addresses[0], null)
}
output "hello_vm_mac" {
  value = try(libvirt_domain.hello.network_interface[0].mac, null)
}