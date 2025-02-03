locals {
  name               = "${var.name}-${random_string.this.result}"
  cloudwatch_prepend = "/aws/ec2/"
  # We use basename of the id to ensure dependency-order
  cloudwatch_loggroup_name = "${local.cloudwatch_prepend}${basename(aws_cloudwatch_log_group.this.id)}"
  ssm_document_name        = var.create_new_ssm_document ? "SSM-SessionManagerRunShell-${random_string.this.result}" : "SSM-SessionManagerRunShell"
}

# Creating a random string for name interpolation
resource "random_string" "this" {
  length  = 5
  special = false
}


resource "aws_cloudwatch_log_group" "this" {
  name              = "${local.cloudwatch_prepend}${local.name}"
  retention_in_days = var.log_retention
  kms_key_id        = aws_kms_key.this.arn
}

resource "aws_ssm_document" "session_manager_prefs" {
  name            = local.ssm_document_name
  document_type   = "Session"
  document_format = "JSON"

  content = <<DOC
{
  "schemaVersion": "1.0",
  "description": "Document to hold regional settings for Session Manager",
  "sessionType": "Standard_Stream",
  "inputs": {
    "s3BucketName": "",
    "s3KeyPrefix": "",
    "s3EncryptionEnabled": true,
    "cloudWatchLogGroupName": "${local.cloudwatch_loggroup_name}",
    "cloudWatchEncryptionEnabled": true,
    "kmsKeyId": "${aws_kms_key.this.key_id}",
    "runAsEnabled": false,
    "runAsDefaultUser": ""
  }
}
DOC
}

resource "aws_security_group" "allow_egress" {
  count       = var.create_security_group ? 1 : 0
  name        = local.name
  description = "Allow egress traffic for ${local.name}"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_launch_template" "this" {
  name_prefix            = var.name
  image_id               = var.image_id != "" ? var.image_id : data.aws_ami.amazon_linux_2.id
  instance_type          = var.instance_type
  vpc_security_group_ids = concat(aws_security_group.allow_egress.*.id, var.security_group_ids)

  user_data = filebase64("${path.module}/cloud_init.init")

  iam_instance_profile {
    arn = aws_iam_instance_profile.this.arn
  }

  network_interfaces {
    associate_public_ip_address = false
  }

  metadata_options {
    http_tokens = "required"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "this" {
  min_size                  = 1
  max_size                  = 1
  health_check_type         = "EC2"
  health_check_grace_period = 30
  vpc_zone_identifier       = var.subnet_ids

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = var.name
    propagate_at_launch = true
  }

  dynamic "tag" {
    for_each = var.tags
    content {
      key                 = tag.value["key"]
      propagate_at_launch = tag.value["propagate_at_launch"]
      value               = tag.value["value"]
    }
  }
}
