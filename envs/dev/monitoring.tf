module "monitoring" {
  source = "../../modules/monitoring"

  name        = "platform-dev"
  alert_email = var.alert_email

  alb_arn_suffix          = module.service.alb_arn_suffix
  target_group_arn_suffix = module.service.target_group_arn_suffix
  cluster_name            = module.service.cluster_name
  service_name            = module.service.service_name
  db_identifier           = module.database.identifier
}

output "dashboard_name" {
  value = module.monitoring.dashboard_name
}
