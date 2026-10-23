provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Project     = "aws-platform-as-code"
      Environment = "dev"
      ManagedBy   = "terraform"
    }
  }
}

data "aws_caller_identity" "current" {}

resource "aws_budgets_budget" "monthly" {
  name         = "platform-monthly-budget"
  budget_type  = "COST"
  limit_amount = var.monthly_budget_usd
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 80
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = [var.alert_email]
  }
}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}