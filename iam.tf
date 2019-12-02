data "aws_iam_policy_document" "trust_policy" {
  statement {
    effect = "Allow"

    principals {
      type = "Service"

      identifiers = [
        "ec2.amazonaws.com",
        "ssm.amazonaws.com",
      ]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "this" {
  name               = local.name
  assume_role_policy = data.aws_iam_policy_document.trust_policy.json
}

resource "aws_iam_role_policy_attachment" "this" {
  for_each   = toset(["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore", "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"])
  role       = aws_iam_role.this.name
  policy_arn = each.key
}

data "aws_iam_policy_document" "kms_key_policy_iam_profile" {
  statement {
    effect = "Allow"

    actions = [
      "kms:Decrypt"
    ]
    resources = [aws_kms_key.this.arn]
  }
}

resource "aws_iam_role_policy" "kms" {
  role   = aws_iam_role.this.name
  name   = "inline-policy-kms-access"
  policy = data.aws_iam_policy_document.kms_key_policy_iam_profile.json
}

resource "aws_iam_instance_profile" "this" {
  name = local.name
  role = aws_iam_role.this.name
}
