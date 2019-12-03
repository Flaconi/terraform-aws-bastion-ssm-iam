output "this_security_group_id" {
  description = "The security group id of the bastion server"
  value       = concat(aws_security_group.allow_egress.*.id, [""])[0]
}

output "ssm_document_name" {
  description = "The document name of SSM"
  value       = local.ssm_document_name
}
