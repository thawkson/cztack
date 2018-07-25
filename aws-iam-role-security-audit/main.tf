resource "aws_iam_role" "security-audit" {
  name = "security-audit"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": {
    "Effect": "Allow",
    "Principal": {
      "AWS": "arn:aws:iam::${var.source_account}:root"
    },
    "Action": "sts:AssumeRole"
  }
}
EOF
}

resource "aws_iam_role_policy_attachment" "security-audit" {
  role       = "${aws_iam_role.security-audit.name}"
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}
