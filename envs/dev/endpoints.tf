module "endpoints" {
  source = "../../modules/endpoints"

  name                  = "platform-dev"
  vpc_id                = module.network.vpc_id
  subnet_ids            = module.network.private_subnet_ids
  app_security_group_id = aws_security_group.app.id
}