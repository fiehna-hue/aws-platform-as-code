variable "name" {
  type = string
}

variable "alert_email" {
  description = "Where alarm notifications are sent"
  type        = string
  sensitive   = true
}

variable "alb_arn_suffix" {
  type = string
}

variable "target_group_arn_suffix" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "service_name" {
  type = string
}

variable "db_identifier" {
  type = string
}
