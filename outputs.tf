# outputs.tf - Root Module Outputs
# Exposes important information from the deployed infrastructure

# NETWORKING OUTPUTS
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.networking.vpc_id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = module.networking.vpc_cidr
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = module.networking.public_subnet_ids
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = module.networking.private_subnet_ids
}

output "database_subnet_ids" {
  description = "List of database subnet IDs"
  value       = module.networking.database_subnet_ids
}

output "nat_gateway_ids" {
  description = "List of NAT Gateway IDs"
  value       = module.networking.nat_gateway_ids
}



# SECURITY OUTPUTS
output "alb_security_group_id" {
  description = "ID of the ALB security group"
  value       = module.security.alb_security_group_id
}

output "application_security_group_id" {
  description = "ID of the application security group"
  value       = module.security.application_security_group_id
}

output "database_security_group_id" {
  description = "ID of the database security group"
  value       = module.security.database_security_group_id
}




# ALB OUTPUTS
output "alb_id" {
  description = "ID of the Application Load Balancer"
  value       = module.alb.alb_id
}

output "alb_dns_name" {
  description = "DNS name of the ALB"
  value       = module.alb.alb_dns_name
}

output "alb_zone_id" {
  description = "Zone ID of the ALB"
  value       = module.alb.alb_zone_id
}

output "alb_target_group_arn" {
  description = "ARN of the ALB target group"
  value       = module.alb.target_group_arn
}



# COMPUTE OUTPUTS
output "asg_id" {
  description = "ID of the Auto Scaling Group"
  value       = module.compute.asg_id
}

output "asg_name" {
  description = "Name of the Auto Scaling Group"
  value       = module.compute.asg_name
}

output "asg_arn" {
  description = "ARN of the Auto Scaling Group"
  value       = module.compute.asg_arn
}

output "launch_template_id" {
  description = "ID of the launch template"
  value       = module.compute.launch_template_id
}

output "launch_template_latest_version" {
  description = "Latest version of the launch template"
  value       = module.compute.launch_template_latest_version
}




# DATABASE OUTPUTS
output "rds_instance_id" {
  description = "ID of the RDS instance"
  value       = module.database.db_instance_id
}

output "rds_endpoint" {
  description = "Connection endpoint for the RDS instance"
  value       = module.database.db_instance_endpoint
}

output "rds_address" {
  description = "Address of the RDS instance"
  value       = module.database.db_instance_address
}

output "rds_port" {
  description = "Port of the RDS instance"
  value       = module.database.db_instance_port
}

output "rds_database_name" {
  description = "Name of the database"
  value       = module.database.db_instance_name
}

output "rds_username" {
  description = "Master username for the database"
  value       = module.database.db_instance_username
  sensitive   = true
}



# APPLICATION ACCESS
output "application_url" {
  description = "URL to access the application"
  value       = "http://${module.alb.alb_dns_name}"
}


# GENERAL INFORMATION

output "project_name" {
  description = "Project name"
  value       = var.project_name
}

output "environment" {
  description = "Environment name"
  value       = var.environment
}

output "region" {
  description = "AWS region"
  value       = var.aws_region
}