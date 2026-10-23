module "network" {
  source = "../../modules/network"

  name = "platform-dev"
}

output "vpc_id" {
  value = module.network.vpc_id
}