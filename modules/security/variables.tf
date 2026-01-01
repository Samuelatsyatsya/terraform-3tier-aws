variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "web_app_port" {
  description = "Web application port"
  type        = number
  default     = 8080
}

variable "db_port" {
  description = "Database port"
  type        = number
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}