# GENERAL VARIABLES (REQUIRED)

variable "project_name" {
  description = "Name of the project for resource naming and tagging"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
}


# NETWORKING VARIABLES (REQUIRED)
variable "vpc_id" {
  description = "ID of the VPC where resources will be created"
  type        = string
}

variable "private_app_subnet_ids" {
  description = "List of private application subnet IDs for ASG placement"
  type        = list(string)
}


# SECURITY VARIABLES (REQUIRED - no defaults)
variable "app_sg_id" {
  description = "ID of the application security group for EC2 instances"
  type        = string
}


# COMPUTE VARIABLES (required)


variable "instance_type" {
  description = "EC2 instance type for application servers"
  type        = string
}

variable "key_name" {
  description = "Name of an existing EC2 key pair for SSH access (optional)"
  type        = string
}

variable "web_app_port" {
  description = "Port on which the web application runs"
  type        = number
}


# AUTO SCALING VARIABLES (REQUIRED)
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

# Alias variables for backward compatibility (REQUIRED)
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


# LOAD BALANCER VARIABLES (REQUIRED)

variable "alb_target_group_arn" {
  description = "ARN of the ALB target group for ASG registration"
  type        = string
}


# DATABASE VARIABLES (REQUIRED)


variable "db_endpoint" {
  description = "Endpoint (hostname) of the RDS database"
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "Name of the application database"
  type        = string
}

variable "db_username" {
  description = "Username for database authentication"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Password for database authentication"
  type        = string
  sensitive   = true
}


# AUTO SCALING POLICY VARIABLES
variable "enable_autoscaling_policies" {
  description = "Whether to enable CloudWatch alarms and scaling policies"
  type        = bool
}

variable "cpu_high_threshold" {
  description = "CPU utilization percentage threshold for scaling up"
  type        = number
}

variable "cpu_low_threshold" {
  description = "CPU utilization percentage threshold for scaling down"
  type        = number
}

variable "health_check_grace_period" {
  description = "Time (in seconds) after instance comes into service before checking health"
  type        = number
  default     = 300  
}

variable "health_check_type" {
  description = "Type of health check to perform on instances (EC2 or ELB)"
  type        = string
}