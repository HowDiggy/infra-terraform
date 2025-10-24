variable "proxmox_api_token" {
  description = "The full API token string (user@realm!token=secret)."
  type        = string
  # 'sensitive = true' prevents Terraform from printing
  # this value in 'plan' or 'apply' logs.
  sensitive   = true
}

variable "vm_hostname" {
  description = "The desired hostname for the new VM."
  type        = string
  default     = "hello-bpg-vm"
}

variable "proxmox_node" {
  description = "The Proxmox node to deploy the VM on."
  type        = string
  default     = "pve" # Matches your previous setup
}