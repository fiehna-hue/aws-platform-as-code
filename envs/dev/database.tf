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