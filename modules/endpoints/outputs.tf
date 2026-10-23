output "endpoint_ids" {
  value = { for k, v in aws_vpc_endpoint.this : k => v.id }
}

output "security_group_id" {
  value = aws_security_group.endpoints.id
}