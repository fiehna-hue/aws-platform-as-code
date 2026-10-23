# App-tier security group, shared by the database, the endpoints and
# (next) the service. It lives in its own file so removing one
# consumer never removes this.
resource "aws_security_group" "app" {
  name        = "platform-dev-app"
  description = "Application tasks"
  vpc_id      = module.network.vpc_id

  tags = { Name = "platform-dev-app" }
}