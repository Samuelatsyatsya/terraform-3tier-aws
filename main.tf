# main.tf - Root Module Configuration
# This file orchestrates all modules to create the 3-tier architecture

# Local variables for common values
locals {
  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    Owner       = var.owner
  }

  # Derive availability zones if not provided
  azs = length(var.availability_zones) > 0 ? var.availability_zones : slice(data.aws_availability_zones.available.names, 0, var.az_count)
}

# Get available availability zones
data "aws_availability_zones" "available" {
  state = "available"
}



# NETWORKING MODULE
# Creates VPC, subnets, IGW, NAT gateways, and route tables
module "networking" {
  source = "./modules/networking"

  vpc_cidr              = var.vpc_cidr
  project_name          = var.project_name
  public_subnet_cidrs   = var.public_subnet_cidrs
  private_subnet_cidrs  = var.private_subnet_cidrs
  database_subnet_cidrs = var.database_subnet_cidrs
  availability_zones    = local.azs
  enable_nat_gateway    = var.enable_nat_gateway
  single_nat_gateway    = var.single_nat_gateway
  enable_dns_hostnames  = var.enable_dns_hostnames
  enable_dns_support    = var.enable_dns_support

  tags = local.common_tags
}



# SECURITY MODULE
# Creates security groups for ALB, application, and database tiers
module "security" {
  source = "./modules/security"

  vpc_id       = module.networking.vpc_id
  vpc_cidr     = var.vpc_cidr
  web_app_port = var.web_app_port
  db_port      = var.db_port
  environment  = var.environment
  project_name = var.project_name
  tags         = local.common_tags

  depends_on = [module.networking]
}



# APPLICATION LOAD BALANCER MODULE
# Creates ALB, target group, and listeners
module "alb" {
  source = "./modules/alb"

  project_name      = var.project_name
  environment       = var.environment
  vpc_id            = module.networking.vpc_id
  public_subnet_ids = module.networking.public_subnet_ids
  web_sg_id         = module.security.web_sg_id
  web_app_port      = var.web_app_port # Pass application_port as web_app_port
  health_check_path = var.health_check_path
  certificate_arn   = var.certificate_arn
  tags              = local.common_tags

  depends_on = [module.networking, module.security]
}



# DATABASE MODULE
# Creates RDS instance with subnet group and parameter group
module "database" {
  source = "./modules/database"

  project_name            = var.project_name
  subnet_ids              = module.networking.database_subnet_ids
  security_group_id       = module.security.database_security_group_id
  db_engine               = var.db_engine
  db_engine_version       = var.db_engine_version
  parameter_group_family  = var.db_parameter_group_family
  db_instance_class       = var.db_instance_class
  allocated_storage       = var.db_allocated_storage
  max_allocated_storage   = var.db_max_allocated_storage
  storage_type            = var.db_storage_type
  storage_encrypted       = var.db_storage_encrypted
  db_name                 = var.db_name
  username                = var.db_username
  password                = var.db_password
  port                    = var.db_port
  multi_az                = var.db_multi_az
  backup_retention_period = var.db_backup_retention_period
  skip_final_snapshot     = var.db_skip_final_snapshot
  deletion_protection     = var.db_deletion_protection

  tags = local.common_tags

  depends_on = [module.networking, module.security]
}



# COMPUTE MODULE (Auto Scaling Group)
# Creates launch template, ASG, and scaling policies
module "compute" {
  source = "./modules/compute"

  # General Configuration
  project_name = var.project_name
  environment  = var.environment

  # Compute Configuration
  instance_type = var.instance_type
  key_name      = var.key_name

  # Networking Configuration 
  vpc_id                 = module.networking.vpc_id
  private_app_subnet_ids = module.networking.private_subnet_ids
  app_sg_id              = module.security.application_security_group_id

  # Load Balancer Configuration
  alb_target_group_arn = module.alb.target_group_arn

  # Database Connection
  db_endpoint  = module.database.db_instance_endpoint
  db_name      = var.db_name
  db_username  = var.db_username
  db_password  = var.db_password
  web_app_port = var.web_app_port

  # Auto Scaling Configuration
  # Using both naming conventions for compatibility
  asg_min_size         = var.asg_min_size
  asg_max_size         = var.asg_max_size
  asg_desired_capacity = var.asg_desired_capacity

  # For backward compatibility with compute module
  min_size         = var.asg_min_size
  max_size         = var.asg_max_size
  desired_capacity = var.asg_desired_capacity

  # Auto Scaling Policies
  health_check_type           = var.asg_health_check_type
  health_check_grace_period   = var.asg_health_check_grace_period
  enable_autoscaling_policies = var.enable_autoscaling_policies
  cpu_high_threshold          = var.cpu_high_threshold
  cpu_low_threshold           = var.cpu_low_threshold

  # Tags
  tags = local.common_tags

  depends_on = [module.networking, module.security, module.alb, module.database]
}