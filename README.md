# AWS Bastion SSM IAM

[![Lint Status](https://github.com/Flaconi/terraform-aws-bastion-ssm-iam/actions/workflows/linting.yml/badge.svg?branch=master)](https://github.com/Flaconi/terraform-aws-bastion-ssm-iam/actions/workflows/linting.yml)
[![Docs Status](https://github.com/Flaconi/terraform-aws-bastion-ssm-iam/actions/workflows/terraform-docs.yml/badge.svg?branch=master)](https://github.com/Flaconi/terraform-aws-bastion-ssm-iam/actions/workflows/terraform-docs.yml)
[![Tag](https://img.shields.io/github/tag/Flaconi/terraform-aws-bastion-ssm-iam.svg)](https://github.com/Flaconi/terraform-aws-bastion-ssm-iam/releases)
[![license](http://img.shields.io/badge/license-MIT-brightgreen.svg)](http://opensource.org/licenses/MIT)

Terraform module which provides a Bastion for AWS utilizing
* Autoscaling group of min/max 1 for resiliency
* AWS SSM Session Manager, this allows users to start a Terminal Session or Tunnel to an instance without the need of public internet access
* ec2-instance-connect, for the creation of temporary ssh keys on the instance

__NOTE__ Important, this module managed the SSM Document SSM-SessionManagerRunShell, in some cases it already exists. To make sure Terraform is used to maintain this Document please execute: `aws ssm delete-document --name SSM-SessionManagerRunShell`. In case you do not want to overwrite SSM-SessionManagerRunShell, you can use the module directive `create_new_ssm_document` to create a different document name. This document needs to be refered to as follows: `SSM_DOCUMENT_NAME="SSM-SessionManagerRunShell-JKURx" ./ssh_terminal`

__NOTE__ For this to work you need to install the session manager plugin for the AWSCLI, click (here)[https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html] for more information.

## Examples

Check the [examples](examples) directory for installation.


## Client
### SSH Terminal
The bash script `client/ssh_terminal` provides a simplified way to ssh to the IAM Bastion, it uses a recent `awscli`-client with ssm terminal support.


### SSH Tunnel
The bash script `client/ssh_tunnel` creates an SSH tunnel using the BASTION, it uses a recent `awscli`-client with ssm terminal support and ec2-instance-connect for uploading the SSH Public key to AWS. Make sure the
BASTION has access to the resources it needs access to by modifying the Security Group of the resouce.

By default the public key file `$HOME/.ssh/id_rsa.pub` will be used for temporary access. The ENVIRONMENT variable `SSH_PUB_KEY_FILE` can be used to set a different public key, as of now AWS does not support ed25519 public keys.
By default the ENVIRONMENT variable AWS_REGION will be used for the `awscli`-tool, if you are using awscli profiles, please provide the correct region by setting the `AWS_REGION`-variable.
If `DEV_LOCAL_PORT` is specified, the ssh tunnel will be created with `DEV_LOCAL_PORT` as local port to connect to, if not a RANDOM port will be used.

Example:
```bash
./ssh_tunnel private_subnet.isdfjsdf.eu-central-1.rds.amazonaws.com:3306
```



<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.12.26 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 3.68.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.1.0 |
| <a name="provider_template"></a> [template](#provider\_template) | 2.2.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_autoscaling_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group) | resource |
| [aws_cloudwatch_log_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_iam_instance_profile.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.kms](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_kms_key.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_launch_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_configuration) | resource |
| [aws_security_group.allow_egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_ssm_document.session_manager_prefs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_document) | resource |
| [random_string.this](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [aws_ami.amazon_linux_2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.kms_key_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.kms_key_policy_iam_profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.trust_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [template_file.init](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | The subnets where the Bastion can reside in, they can be private | `list(string)` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The VPC-ID | `string` | n/a | yes |
| <a name="input_create_new_ssm_document"></a> [create\_new\_ssm\_document](#input\_create\_new\_ssm\_document) | This module can create a new SSM document for the SSH Terminal | `bool` | `false` | no |
| <a name="input_create_security_group"></a> [create\_security\_group](#input\_create\_security\_group) | This module can create a security group for the bastion instance by default | `bool` | `true` | no |
| <a name="input_image_id"></a> [image\_id](#input\_image\_id) | AMI to be used. If blank, latest amazon linux 2 will be used | `string` | `""` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | The instance type of the bastion | `string` | `"t3.nano"` | no |
| <a name="input_log_retention"></a> [log\_retention](#input\_log\_retention) | The amount of days the logs need to be kept | `number` | `30` | no |
| <a name="input_name"></a> [name](#input\_name) | The name to be interpolated, defaults to bastion-ssm-iam | `string` | `"bastion-ssm-iam"` | no |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | The security group ids which can be given to the bastion instance, defaults to empty | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to be added to the launch configuration for the bastion host, additionally to name tag | `list(map(any))` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_instance_profile_name"></a> [instance\_profile\_name](#output\_instance\_profile\_name) | The instance profile name of SSM |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | The security group id of the bastion server |
| <a name="output_ssm_document_name"></a> [ssm\_document\_name](#output\_ssm\_document\_name) | The document name of SSM |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## License

[MIT](LICENSE)

Copyright (c) 2021 [Flaconi GmbH](https://github.com/Flaconi)
