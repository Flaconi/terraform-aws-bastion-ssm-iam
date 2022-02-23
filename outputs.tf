output "security_group_id" {
  description = "The security group id of the bastion server"
  value       = concat(aws_security_group.allow_egress.*.id, [""])[0]
}

output "ssm_document_name" {
  description = "The document name of SSM"
  value       = local.ssm_document_name
}

output "instance_profile_name" {
  description = "The instance profile name of SSM"
  value       = aws_iam_instance_profile.this.name
}
