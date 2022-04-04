variable "name" {
  type        = string
  description = "The name to be interpolated, defaults to bastion-ssm-iam"
  default     = "bastion-ssm-iam"
}

variable "instance_type" {
  type        = string
  description = "The instance type of the bastion"
  default     = "t3.nano"
}

variable "image_id" {
  type        = string
  description = "AMI to be used. If blank, latest amazon linux 2 will be used"
  default     = ""
}

variable "log_retention" {
  type        = number
  description = "The amount of days the logs need to be kept"
  default     = 30
}

variable "vpc_id" {
  type        = string
  description = "The VPC-ID"
}

variable "subnet_ids" {
  type        = list(string)
  description = "The subnets where the Bastion can reside in, they can be private"
}

variable "create_new_ssm_document" {
  type        = bool
  description = "This module can create a new SSM document for the SSH Terminal"
  default     = false
}

variable "create_security_group" {
  type        = bool
  description = "This module can create a security group for the bastion instance by default"
  default     = true
}

variable "security_group_ids" {
  type        = list(string)
  description = "The security group ids which can be given to the bastion instance, defaults to empty"
  default     = []
}

variable "tags" {
  type = list(object({
    key                 = string
    value               = string
    propagate_at_launch = bool
  }))
  description = "Tags to be added to the launch configuration for the bastion host, additionally to name tag"
  default = []
}
