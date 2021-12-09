
resource "aws_ebs_default_kms_key" "example" {
  key_arn = aws_kms_key.kms_key_ebs.arn
}

data "aws_acm_certificate" "issued_cert" {
  domain   = var.domain_name
  statuses = ["ISSUED"]
}

//  ************* ebs kms key
resource "aws_kms_key" "kms_key_ebs" {
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [{
      "Sid" : "Enable IAM User Permissions for ebs volume",
      "Effect" : "Allow",
      "Principal" : {
        "AWS" : "arn:aws:iam::${var.account_id}:root"
      },
      "Action" : "kms:*",
      "Resource" : "*"
      },
      {
        "Sid" : "Add service role",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::${var.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
        },
        "Action" : "kms:*",
        "Resource" : "*"
      }
    ]
  })
}


//  ************* rds kms key
resource "aws_kms_key" "kms_key_rds" {
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [{
      "Sid" : "Enable IAM User Permissions for RDS instance",
      "Effect" : "Allow",
      "Principal" : {
        "AWS" : "arn:aws:iam::${var.account_id}:root"
      },
      "Action" : "kms:*",
      "Resource" : "*"
      },
      {
        "Sid" : "Add service role",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::${var.account_id}:role/aws-service-role/rds.amazonaws.com/AWSServiceRoleForRDS"
        },
        "Action" : "kms:*",
        "Resource" : "*"
      }
    ]
  })
}


//  ************* ebs iam  role 

resource "aws_iam_role" "ebs_iam_role" {
  name = "ebs-am-role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "sts:AssumeRole",
        "Principal" : {
          "Service" : "ebs.amazonaws.com"
        },
        "Effect" : "Allow"
      }
    ]
  })
}

//  ************* rds iam  role 

resource "aws_iam_role" "rds_iam_role" {
  name = "rds-iam-role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "sts:AssumeRole",
        "Principal" : {
          "Service" : "rds.amazonaws.com"
        },
        "Effect" : "Allow"
      }
    ]
  })
}

resource "aws_kms_grant" "ebs_key_attachment" {
  depends_on        = [aws_kms_key.kms_key_ebs, aws_iam_role.ebs_iam_role]
  name              = "ebs-key-attachment"
  key_id            = aws_kms_key.kms_key_ebs.key_id
  grantee_principal = aws_iam_role.ebs_iam_role.arn
  operations        = ["Encrypt", "Decrypt", "GenerateDataKey"]

}


resource "aws_kms_grant" "rds_key_attachment" {
  depends_on        = [aws_kms_key.kms_key_rds, aws_iam_role.rds_iam_role]
  name              = "rds-key-attachment"
  key_id            = aws_kms_key.kms_key_rds.key_id
  grantee_principal = aws_iam_role.rds_iam_role.arn
  operations        = ["Encrypt", "Decrypt", "GenerateDataKey"]
}
