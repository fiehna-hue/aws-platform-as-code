variable "name" {
  type = string
}

variable "role_prefix" {
  description = "IAM role name prefix. Must start with platform-app- (the apply role's scope)."
  type        = string
}

variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "app_security_group_id" {
  type = string
}

variable "db_security_group_id" {
  type = string
}

variable "endpoints_security_group_id" {
  type = string
}

variable "allowed_cidr" {
  description = "The only source allowed to reach the load balancer"
  type        = string
  sensitive   = true
}

variable "image" {
  description = "Full image URI including tag"
  type        = string
}

variable "container_port" {
  type    = number
  default = 8000
}

variable "db_host" {
  type = string
}

variable "db_name" {
  type = string
}

variable "db_user" {
  type = string
}

variable "db_secret_arn" {
  type = string
}

variable "desired_count" {
  type    = number
  default = 2
}