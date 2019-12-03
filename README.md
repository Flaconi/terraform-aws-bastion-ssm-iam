# AWS Bastion SSM IAM

[![Build Status](https://travis-ci.com/Flaconi/terraform-aws-bastion-ssm-iam.svg?branch=master)](https://travis-ci.com/Flaconi/terraform-aws-bastion-ssm-iam)
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
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| subnet\_ids | The subnets where the Bastion can reside in, they can be private | list | n/a | yes |
| vpc\_id | The VPC-ID | string | n/a | yes |
| create\_new\_ssm\_document | This module can create a new SSM document for the SSH Terminal | bool | `"false"` | no |
| create\_security\_group | This module can create a security group for the bastion instance by default | bool | `"true"` | no |
| instance\_type | The instance type of the bastion | string | `"t3.nano"` | no |
| log\_retention | The amount of days the logs need to be kept | number | `"30"` | no |
| name | The name to be interpolated, defaults to bastion-ssm-iam | string | `"bastion-ssm-iam"` | no |
| security\_group\_ids | The security group ids which can be given to the bastion instance, defaults to empty | list | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| ssm\_document\_name | The document name of SSM |
| this\_security\_group\_id | The security group id of the bastion server |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## License

[MIT](LICENSE)

Copyright (c) 2019 [Flaconi GmbH](https://github.com/Flaconi)
