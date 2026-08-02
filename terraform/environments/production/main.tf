locals {
  name_prefix  = "${var.project_name}-${var.environment}"
  cluster_name = "${local.name_prefix}-eks"

  default_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
    Owner       = var.owner
    Purpose     = "rentacar-api-platform"
    Repository  = var.repository
  }
}

module "networking" {
  source                   = "../../modules/networking"
  name_prefix              = local.name_prefix
  vpc_cidr                 = var.vpc_cidr
  availability_zones       = var.availability_zones
  public_subnet_cidrs      = var.public_subnet_cidrs
  private_app_subnet_cidrs = var.private_app_subnet_cidrs
  private_db_subnet_cidrs  = var.private_db_subnet_cidrs
  nat_gateway_mode         = var.nat_gateway_mode
  cluster_name             = local.cluster_name
  tags                     = local.default_tags
}

module "ecr" {
  source          = "../../modules/ecr"
  repository_name = "${local.name_prefix}-api"
  tags            = local.default_tags
}

module "eks" {
  source                           = "../../modules/eks"
  cluster_name                     = local.cluster_name
  aws_region                       = var.aws_region
  kubernetes_version               = var.kubernetes_version
  vpc_id                           = module.networking.vpc_id
  private_subnet_ids               = module.networking.private_app_subnet_ids
  endpoint_private_access          = var.endpoint_private_access
  endpoint_public_access           = var.endpoint_public_access
  public_access_cidrs              = var.public_access_cidrs
  node_instance_types              = var.node_instance_types
  node_capacity_type               = var.node_capacity_type
  node_min_size                    = var.node_min_size
  node_desired_size                = var.node_desired_size
  node_max_size                    = var.node_max_size
  node_disk_size                   = var.node_disk_size
  control_plane_log_retention_days = 30
  node_labels                      = { workload = "api" }
  tags                             = local.default_tags
}

module "rds" {
  source                       = "../../modules/rds"
  identifier                   = "${local.name_prefix}-postgres"
  vpc_id                       = module.networking.vpc_id
  private_db_subnet_ids        = module.networking.private_db_subnet_ids
  allowed_security_group_ids   = [module.eks.node_security_group_id]
  database_name                = "rentacardb"
  instance_class               = var.rds_instance_class
  allocated_storage            = var.rds_allocated_storage
  max_allocated_storage        = var.rds_max_allocated_storage
  multi_az                     = var.rds_multi_az
  backup_retention_period      = var.rds_backup_retention_period
  deletion_protection          = var.rds_deletion_protection
  skip_final_snapshot          = var.rds_skip_final_snapshot
  final_snapshot_identifier    = var.rds_final_snapshot_identifier
  performance_insights_enabled = true
  tags                         = local.default_tags
}

module "github_oidc" {
  source             = "../../modules/github-oidc"
  name_prefix        = local.name_prefix
  allowed_subjects   = var.github_allowed_subjects
  ecr_repository_arn = module.ecr.repository_arn
  tags               = local.default_tags
}

module "budget" {
  source             = "../../modules/budget"
  enabled            = var.budget_enabled
  name               = "${local.name_prefix}-monthly-budget"
  monthly_limit_usd  = var.budget_monthly_limit_usd
  notification_email = var.budget_notification_email
  project_name       = var.project_name
  environment        = var.environment
  tags               = local.default_tags
}
