variable "namespace" {
  description = "VM Operator (Supervisor) namespace to deploy into. Equivalent to NS in deploy.sh."
  type        = string
}

variable "org_name" {
  description = "VCFA Organization name"
  type        = string
}

variable "region_name" {
  description = "The region this deployment will be placed in"
  type        = string
}

variable "vcfa_url" {
  description = "VCFA URL"
  type        = string
}

variable "vm_count" {
  description = "Number of frontend VMs to create. Named frontend-01, frontend-02, etc."
  type        = number
  default     = 1
}
