variable "proxmox_api_token" {
  description = "The full API token string (user@realm!token=secret)."
  type        = string
  sensitive   = true
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

# NEW VARIABLE: This is our fleet definition
variable "virtual_machines" {
  description = "A map of virtual machines to create."
  type = map(object({
    hostname   = string
    cpu_cores  = optional(number, 2)    # Default to 2 cores
    memory_mb  = optional(number, 2048) # Default to 2048MB
    disk_size  = optional(number, 32)   # Default to 32GB
  }))

  # This is the 'default' value for our map.
  # We define two VMs: "web-01" and "web-02".
  default = {
    "web-01" = {
      hostname = "web-01"
    }
    "web-02" = {
      hostname  = "web-02"
      cpu_cores = 4          # Override: This VM gets 4 cores
      memory_mb = 4096       # Override: This VM gets 4GB
    }
  }
}