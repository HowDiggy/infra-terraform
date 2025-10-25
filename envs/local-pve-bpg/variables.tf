variable "proxmox_api_token" {
  description = "The full API token string (user@realm!token=secret)."
  type        = string
  sensitive   = true
}

variable "vm_hostname" {
  description = "The desired hostname for the new VM."
  type        = string
  default     = "hello-module-vm" # New default name
}

variable "proxmox_node" {
  description = "The Proxmox node to deploy the VM on."
  type        = string
  default     = "pve"
}

variable "ssh_public_key_path" {
  description = "Path to your public SSH key."
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}