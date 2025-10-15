variable "vm_memory_mb" {
  description = "RAM for the VM in MiB"
  type        = number
  default     = 2048
}

variable "vm_vcpu" {
  description = "vCPU count for the VM"
  type        = number
  default     = 4
}
