variable "alert_email" {
  type        = string
  description = "Email address that receives budget alerts."
  sensitive   = true
}

variable "monthly_budget_usd" {
  type        = string
  description = "Monthly cost budget in USD."
  default     = "10"
}