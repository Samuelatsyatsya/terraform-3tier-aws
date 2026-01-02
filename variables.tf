# variables.tf
# Variable definitions for 3-tier architecture Terraform configuration

# ===================================================================
# BASIC PROJECT VARIABLES
# ===================================================================

variable "project_name" {
  description = "Name of the project (used for resource naming and tagging)"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
}

variable "owner" {
  description = "Owner/team responsible for the infrastructure"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

# ===================================================================
# NETWORKING VARIABLES
# ===================================================================

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for public subnets"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for private subnets (application tier)"
  type        = list(string)
}

variable "database_subnet_cidrs" {
  description = "List of CIDR blocks for database subnets"
  type        = list(string)
}

variable "availability_zones" {
  description = "List of availability zones to use (if empty, will use available zones)"
  type        = list(string)
}

variable "az_count" {
  description = "Number of availability zones to use if availability_zones is not specified"
  type        = number
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnets"
  type        = bool
}

variable "single_nat_gateway" {
  description = "Use a single NAT Gateway for all private subnets (cost optimization)"
  type        = bool
}

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames in the VPC"
  type        = bool
}

variable "enable_dns_support" {
  description = "Enable DNS support in the VPC"
  type        = bool
}

# ===================================================================
# SECURITY VARIABLES
# ===================================================================

variable "web_app_port" {
  description = "Port for the application (used by ALB and security groups)"
  type        = number
}

variable "db_port" {
  description = "Port for the database (MySQL default)"
  type        = number
}

variable "enable_ssh_access" {
  description = "Enable SSH access to instances"
  type        = bool
}

variable "ssh_cidr_blocks" {
  description = "CIDR blocks allowed for SSH access"
  type        = list(string)
}

# ===================================================================
# LOAD BALANCER VARIABLES
# ===================================================================

variable "alb_internal" {
  description = "Whether the ALB should be internal (private) or internet-facing"
  type        = bool
}

variable "alb_enable_deletion_protection" {
  description = "Enable deletion protection for the ALB"
  type        = bool
}

variable "health_check_path" {
  description = "Path for ALB health checks"
  type        = string
}

variable "health_check_interval" {
  description = "Interval in seconds between health checks"
  type        = number
}

variable "health_check_timeout" {
  description = "Timeout in seconds for health checks"
  type        = number
}

variable "enable_https" {
  description = "Enable HTTPS listener on the ALB"
  type        = bool
}

variable "certificate_arn" {
  description = "ARN of the SSL certificate for HTTPS (required if enable_https is true)"
  type        = string
}

# ===================================================================
# DATABASE VARIABLES
# ===================================================================

variable "db_engine" {
  description = "Database engine (e.g., mysql, postgres)"
  type        = string
}

variable "db_engine_version" {
  description = "Database engine version"
  type        = string
}

variable "db_parameter_group_family" {
  description = "Parameter group family for the database"
  type        = string
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
}

variable "db_allocated_storage" {
  description = "Initial allocated storage in GB"
  type        = number
}

variable "db_max_allocated_storage" {
  description = "Maximum allocated storage in GB for autoscaling"
  type        = number
}

variable "db_storage_type" {
  description = "Storage type (e.g., gp2, gp3, io1)"
  type        = string
}

variable "db_storage_encrypted" {
  description = "Enable storage encryption"
  type        = bool
}

variable "db_name" {
  description = "Name of the database to create"
  type        = string
}

variable "db_username" {
  description = "Database administrator username"
  type        = string
}

variable "db_password" {
  description = "Database administrator password"
  type        = string
  sensitive   = true
}

variable "db_multi_az" {
  description = "Enable Multi-AZ deployment for high availability"
  type        = bool
}

variable "db_backup_retention_period" {
  description = "Number of days to retain automated backups"
  type        = number
}

variable "db_skip_final_snapshot" {
  description = "Skip final snapshot when destroying the database"
  type        = bool
}

variable "db_deletion_protection" {
  description = "Enable deletion protection for the database"
  type        = bool
}

# ===================================================================
# COMPUTE VARIABLES
# ===================================================================

variable "instance_type" {
  description = "EC2 instance type for the application servers"
  type        = string
}

variable "key_name" {
  description = "Name of the EC2 key pair for SSH access"
  type        = string
}

# ===================================================================
# AUTO SCALING VARIABLES
# ===================================================================

variable "asg_min_size" {
  description = "Minimum number of instances in the Auto Scaling Group"
  type        = number
}

variable "asg_max_size" {
  description = "Maximum number of instances in the Auto Scaling Group"
  type        = number
}

variable "asg_desired_capacity" {
  description = "Desired number of instances in the Auto Scaling Group"
  type        = number
}

variable "asg_health_check_type" {
  description = "Health check type for Auto Scaling Group (EC2 or ELB)"
  type        = string
}

variable "asg_health_check_grace_period" {
  description = "Grace period in seconds for instance health checks"
  type        = number
}

variable "enable_autoscaling_policies" {
  description = "Enable CPU-based auto scaling policies"
  type        = bool
}

variable "cpu_high_threshold" {
  description = "CPU utilization threshold for scaling out (percentage)"
  type        = number
}

variable "cpu_low_threshold" {
  description = "CPU utilization threshold for scaling in (percentage)"
  type        = number
}

# ===================================================================
# COMPATIBILITY VARIABLES (for backward compatibility)
# ===================================================================

variable "min_size" {
  description = "Alias for asg_min_size (for backward compatibility)"
  type        = number
}

variable "max_size" {
  description = "Alias for asg_max_size (for backward compatibility)"
  type        = number
}

variable "desired_capacity" {
  description = "Alias for asg_desired_capacity (for backward compatibility)"
  type        = number
}