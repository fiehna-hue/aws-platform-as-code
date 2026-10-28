variable "name" {
  type        = string
  description = "Name prefix for network resources."
}

variable "cidr" {
  type        = string
  description = "CIDR block for the VPC."
  default     = "10.40.0.0/16"
}

variable "az_count" {
  type        = number
  description = "Number of availability zones to span."
  default     = 2
}

variable "map_public_ip_on_launch" {
  type        = bool
  description = "Give instances launched in public subnets a public IP automatically. Needed for EKS nodes in public subnets."
  default     = false
}
