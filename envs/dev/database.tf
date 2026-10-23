# Placeholder app-tier security group. The service module will use it,
# so the database already trusts only the app and nothing else.
resource "aws_security_group" "app" {
  name        = "platform-dev-app"
  description = "Application tasks"
  vpc_id      = module.network.vpc_id

  tags = { Name = "platform-dev-app" }
}

module "database" {
  source = "../../modules/database"

  name                  = "platform-dev"
  vpc_id                = module.network.vpc_id
  subnet_ids            = module.network.database_subnet_ids
  app_security_group_id = aws_security_group.app.id
}

output "db_endpoint" {
  value = module.database.endpoint
}