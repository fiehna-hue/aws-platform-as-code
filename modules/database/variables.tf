variable "name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  description = "Isolated database subnets (at least two AZs)"
  type        = list(string)
}

variable "app_security_group_id" {
  description = "The only security group allowed to reach Postgres"
  type        = string
}

variable "instance_class" {
  type    = string
  default = "db.t4g.micro"
}