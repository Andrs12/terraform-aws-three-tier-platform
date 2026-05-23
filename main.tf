# ── Networking ───────────────────────────────────────────────────────────────

module "networking" {
  source = "./modules/networking"

  project_name = var.project_name
  vpc_cidr     = var.vpc_cidr
  azs          = var.azs
}

# ── Security ────────────────────────────────────────────────────────────────

module "security" {
  source = "./modules/security"

  aws_region   = var.aws_region
  project_name = var.project_name
  owner        = var.owner
  vpc_id       = module.networking.vpc_id
  app_port     = var.app_port
}

# ── Database ─────────────────────────────────────────────────────────────────

module "database" {
  source = "./modules/database"

  aws_region            = var.aws_region
  project_name          = var.project_name
  owner                 = var.owner
  database_subnet_ids   = module.networking.database_subnet_ids
  rds_security_group_id = module.security.rds_security_group_id
  instance_class        = var.instance_class
  db_name               = var.db_name
  db_username           = var.db_username
  db_password           = var.db_password
  deletion_protection   = var.deletion_protection
}

# ── ALB ──────────────────────────────────────────────────────────────────────

module "alb" {
  source = "./modules/alb"

  project_name          = var.project_name
  vpc_id                = module.networking.vpc_id
  public_subnet_ids     = module.networking.public_subnet_ids
  alb_security_group_id = module.security.alb_security_group_id
}

# ── Compute ──────────────────────────────────────────────────────────────────

module "compute" {
  source = "./modules/compute"

  aws_region            = var.aws_region
  project_name          = var.project_name
  vpc_id                = module.networking.vpc_id
  private_subnet_ids    = module.networking.private_subnet_ids
  ecs_security_group_id = module.security.ecs_security_group_id
  db_endpoint           = module.database.db_endpoint
  db_name               = var.db_name
  db_username           = var.db_username
  db_password           = var.db_password
  target_group_arn      = module.alb.target_group_arn
}
