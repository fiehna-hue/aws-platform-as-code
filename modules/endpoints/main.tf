data "aws_region" "current" {}

resource "aws_security_group" "endpoints" {
  name        = "${var.name}-endpoints"
  description = "HTTPS to interface endpoints from the app tier only"
  vpc_id      = var.vpc_id

  tags = { Name = "${var.name}-endpoints" }
}

resource "aws_vpc_security_group_ingress_rule" "https_from_app" {
  security_group_id            = aws_security_group.endpoints.id
  referenced_security_group_id = var.app_security_group_id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
  description                  = "HTTPS from the app tier"
}

resource "aws_vpc_endpoint" "this" {
  for_each = toset(var.services)

  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.${each.value}"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.subnet_ids
  security_group_ids  = [aws_security_group.endpoints.id]
  private_dns_enabled = true

  tags = { Name = "${var.name}-${each.value}" }
}