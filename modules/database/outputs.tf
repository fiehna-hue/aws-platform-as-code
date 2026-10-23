output "endpoint" {
  value = aws_db_instance.this.address
}

output "secret_arn" {
  description = "Secrets Manager secret holding the master password"
  value       = aws_db_instance.this.master_user_secret[0].secret_arn
}

output "security_group_id" {
  value = aws_security_group.db.id
}