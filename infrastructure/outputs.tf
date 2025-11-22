# useful outputs to be picked later 

output "bastion_key_name" {
	description = "Key pair name used for bastion SSH"
	value       = var.bastion_key_name
}

output "instances_key_name" {
	description = "Key pair name used for app instances (SSH from bastion)"
	value       = var.instances_key_name
}