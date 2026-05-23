# ── DB Subnet Group ─────────────────────────────────────────────────────────

resource "aws_db_subnet_group" "database" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = var.database_subnet_ids

  tags = {
    Name = "${var.project_name}-db-subnet-group"
  }
}

# ── DB Parameter Group ──────────────────────────────────────────────────────

resource "aws_db_parameter_group" "database" {
  name   = "${var.project_name}-pg-params"
  family = "postgres15"

  parameter {
    name  = "log_statement"
    value = "all"
  }

  parameter {
    name  = "log_min_duration_statement"
    value = "5000"
  }

  tags = {
    Name = "${var.project_name}-pg-params"
  }
}

# ── PostgreSQL RDS Instance ─────────────────────────────────────────────────

resource "aws_db_instance" "database" {
  identifier     = "${var.project_name}-db"
  engine         = "postgres"
  engine_version = "15.10"
  instance_class = var.instance_class

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  allocated_storage     = 20
  max_allocated_storage = 100
  storage_type          = "gp2"
  storage_encrypted     = true

  db_subnet_group_name   = aws_db_subnet_group.database.name
  vpc_security_group_ids = [var.rds_security_group_id]
  parameter_group_name   = aws_db_parameter_group.database.name

  publicly_accessible = false

  backup_retention_period = 1
  skip_final_snapshot     = true

  deletion_protection = var.deletion_protection

  tags = {
    Name = "${var.project_name}-db"
  }
}
