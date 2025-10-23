variable "proxmox_node" {
  description = "The Proxmox node to deploy the VM on."
  type        = string
  default     = "pve"
}

variable "template_name" {
  description = "The name of the VM template to clone."
  type        = string
  default     = "ubuntu-2404-cloud-template"
}

variable "vm_hostname" {
  description = "The desired hostname for the new VM."
  type        = string
  default     = "hello-vm"
}