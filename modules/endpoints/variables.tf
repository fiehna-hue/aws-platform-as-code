variable "name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  description = "Private subnets that get an endpoint interface (one per AZ)"
  type        = list(string)
}

variable "app_security_group_id" {
  description = "The only security group allowed to reach the endpoints"
  type        = string
}

variable "services" {
  type    = list(string)
  default = ["ecr.api", "ecr.dkr", "logs", "secretsmanager"]
}