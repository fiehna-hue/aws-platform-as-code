output "endpoint_ids" {
  value = { for k, v in aws_vpc_endpoint.this : k => v.id }
}