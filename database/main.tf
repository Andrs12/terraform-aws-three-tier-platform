terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project   = var.project_name
      ManagedBy = "terraform"
      Owner     = var.owner
    }
  }
}

# ── DB Subnet Group ─────────────────────────────────────────────────────────

resource "aws_db_subnet_group" "database" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = var.database_subnet_ids

  tags = {
    Name = "${var.project_name}-db-subnet-group"
  }
}

# ── DB Cluster Parameter Group ──────────────────────────────────────────────

resource "aws_rds_cluster_parameter_group" "database" {
  name   = "${var.project_name}-aurora-pg-params"
  family = "aurora-postgresql15"

  parameter {
    name  = "log_statement"
    value = "all"
  }

  parameter {
    name  = "log_min_duration_statement"
    value = "5000"
  }

  tags = {
    Name = "${var.project_name}-aurora-pg-params"
  }
}

# ── Aurora PostgreSQL Cluster ───────────────────────────────────────────────

resource "aws_rds_cluster" "database" {
  cluster_identifier     = "${var.project_name}-aurora-cluster"
  engine                 = "aurora-postgresql"
  engine_version         = "15.4"
  database_name          = var.db_name
  master_username        = var.db_username
  master_password        = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.database.name
  vpc_security_group_ids = [var.rds_security_group_id]

  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.database.name

  storage_encrypted   = true
  deletion_protection = var.deletion_protection

  skip_final_snapshot       = !var.deletion_protection
  final_snapshot_identifier = var.deletion_protection ? "${var.project_name}-final-snapshot" : null

  backup_retention_period = 7
  preferred_backup_window = "03:00-04:00"

  tags = {
    Name = "${var.project_name}-aurora-cluster"
  }
}

# ── Aurora PostgreSQL Cluster Instance ──────────────────────────────────────

resource "aws_rds_cluster_instance" "database" {
  count = var.instance_count

  identifier         = "${var.project_name}-aurora-instance-${count.index}"
  cluster_identifier = aws_rds_cluster.database.id
  instance_class     = var.instance_class
  engine             = aws_rds_cluster.database.engine
  engine_version     = aws_rds_cluster.database.engine_version

  db_subnet_group_name    = aws_db_subnet_group.database.name
  db_parameter_group_name = aws_rds_cluster_parameter_group.database.name

  publicly_accessible = false

  tags = {
    Name = "${var.project_name}-aurora-instance-${count.index}"
  }
}
