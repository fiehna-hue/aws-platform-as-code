variable "allowed_cidr" {
  description = "Source allowed to reach the load balancer (GitHub secret)"
  type        = string
  sensitive   = true
}

variable "image_tag" {
  description = "Tag of the inventory-api image in ECR (GitHub variable)"
  type        = string
}

data "aws_ecr_repository" "api" {
  name = "inventory-api"
}

module "service" {
  source = "../../modules/service"

  name        = "platform-dev"
  role_prefix = "platform-app-dev"

  vpc_id             = module.network.vpc_id
  public_subnet_ids  = module.network.public_subnet_ids
  private_subnet_ids = module.network.private_subnet_ids

  app_security_group_id       = aws_security_group.app.id
  db_security_group_id        = module.database.security_group_id
  endpoints_security_group_id = module.endpoints.security_group_id

  allowed_cidr = var.allowed_cidr
  image        = "${data.aws_ecr_repository.api.repository_url}:${var.image_tag}"

  db_host       = module.database.endpoint
  db_name       = "inventory"
  db_user       = module.database.username
  db_secret_arn = module.database.secret_arn
}

output "alb_dns_name" {
  value = module.service.alb_dns_name
}