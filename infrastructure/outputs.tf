###################################################################
# Centralized Outputs
# Grouped for quick verification after apply
# - Keys & Access
# - Networking & Entry Points
# - Compute / Scaling
# - Data Layer
# - Security (WAF, Secret)
# - Container / Image
###################################################################

############################
# Keys & Access
############################

output "bastion_key_name" {
	description = "Key pair name used for bastion SSH"
	value       = var.bastion_key_name
}

output "instances_key_name" {
	description = "Key pair name used for app instances (SSH from bastion)"
	value       = var.instances_key_name
}

output "bastion_public_ip" {
	description = "Public IP of bastion host"
	value       = aws_instance.bastion.public_ip
}

############################
# Networking & Entry Points
############################
output "alb_dns_name" {
	description = "Public DNS name of the ALB"
	value       = aws_lb.app.dns_name
}

output "target_group_arn" {
	description = "App target group ARN"
	value       = aws_lb_target_group.app.arn
}

############################
# Compute / Scaling
############################
output "autoscaling_group_name" {
	description = "Name of the application ASG"
	value       = aws_autoscaling_group.app.name
}

############################
# Data Layer
############################
output "rds_endpoint" {
	description = "RDS instance endpoint"
	value       = aws_db_instance.app.address
}

output "db_secret_arn" {
	description = "Secrets Manager ARN for DB credentials"
	value       = aws_secretsmanager_secret.db.arn
}

############################
# Security (WAF)
############################
output "web_acl_arn" {
	description = "WAF Web ACL ARN"
	value       = aws_wafv2_web_acl.app.arn
}

############################
# Container / Image
############################
output "ecr_repo_url" {
	description = "ECR repository URL"
	value       = aws_ecr_repository.app.repository_url
}