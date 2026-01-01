# Add these aliases to existing outputs
output "alb_security_group_id" {
  description = "Alias for web_sg_id (for ALB module compatibility)"
  value       = aws_security_group.web.id
}

output "application_security_group_id" {
  description = "Alias for app_sg_id (for compute module compatibility)"
  value       = aws_security_group.app.id
}

output "database_security_group_id" {
  description = "Alias for db_sg_id (for database module compatibility)"
  value       = aws_security_group.db.id
}

# Keep your existing outputs
output "web_sg_id" {
  description = "ID of the web security group"
  value       = aws_security_group.web.id
}

output "app_sg_id" {
  description = "ID of the application security group"
  value       = aws_security_group.app.id
}

output "db_sg_id" {
  description = "ID of the database security group"
  value       = aws_security_group.db.id
}