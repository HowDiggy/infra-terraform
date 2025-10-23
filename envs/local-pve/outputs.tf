# 4. Output the VM's IP Address
# This will query the Proxmox API (via the guest agent)
# for the VM's IP and print it to your terminal after 'apply'.
output "vm_ip_address" {
  description = "The primary IPv4 address of the new VM."
  value       = proxmox_vm_qemu.hello_vm.default_ipv4_address
}