resource "aws_security_group" "db" {
  name        = "${var.name}-db"
  description = "Postgres access from the app tier only"
  vpc_id      = var.vpc_id

  tags = { Name = "${var.name}-db" }
}

resource "aws_vpc_security_group_ingress_rule" "from_app" {
  security_group_id            = aws_security_group.db.id
  referenced_security_group_id = var.app_security_group_id
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
  description                  = "Postgres from the app tier"
}

resource "aws_db_subnet_group" "this" {
  name       = "${var.name}-db"
  subnet_ids = var.subnet_ids

  tags = { Name = "${var.name}-db" }
}

resource "aws_db_instance" "this" {
  identifier     = "${var.name}-postgres"
  engine         = "postgres"
  engine_version = "16"
  instance_class = var.instance_class

  allocated_storage = 20
  storage_type      = "gp3"
  storage_encrypted = true

  db_name  = "inventory"
  username = "appadmin"

  # RDS creates and rotates the password in Secrets Manager.
  # It never appears in code, state variables or the plan output.
  manage_master_user_password = true

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.db.id]
  publicly_accessible    = false
  multi_az               = false

  # Lab trade-offs so teardown is fast. Production: Multi-AZ,
  # backups, final snapshot and deletion protection.
  backup_retention_period = 0
  skip_final_snapshot     = true
  deletion_protection     = false
}