output "this_security_group_id" {
  description = "The security group id of the bastion server"
  value       = concat(aws_security_group.allow_egress.*.id, [""])[0]
}
