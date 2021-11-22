
data "aws_caller_identity" "current" {}

locals {
  aws_user_account_id = data.aws_caller_identity.current.account_id
}

resource "aws_iam_policy" "code_deploy_ec2_s3" {
  name        = "CodeDeploy-EC2-S3"
  description = "Instances read data from S3 buckets"
  depends_on  = [aws_iam_role.codedeploy_service_role]
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : [
          "s3:Get*",
          "s3:List*",
          "s3:PutObject",
        ],
        "Effect" : "Allow",
        "Resource" : [
          "arn:aws:s3:::${var.bucket_name}",
          "arn:aws:s3:::${var.bucket_name}/*"
        ]
      }
    ]
  })

}

resource "aws_iam_policy" "gh_upload_s3_policy" {
  name        = "GH-Upload-To-S3"
  description = "GH-Upload-To-S3"
  depends_on  = [aws_iam_role.codedeploy_service_role]
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:PutObject",
          "s3:Get*",
          "s3:List*"
        ],
        "Resource" : [
          "arn:aws:s3:::${var.bucket_name}/*"
        ]
      }
    ]
  })

}

resource "aws_iam_policy" "code_deploy_policy" {
  name        = "GH-Code-Deploy"
  description = "Instances read data from S3 buckets"
  // depends_on  = [aws_iam_role.codedeploy_service_role]
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "codedeploy:RegisterApplicationRevision",
          "codedeploy:GetApplicationRevision"
        ],
        "Resource" : [
          "arn:aws:codedeploy:${var.provider_region}:${local.aws_user_account_id}:application:${aws_codedeploy_app.codedeploy_app.name}"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "codedeploy:CreateDeployment",
          "codedeploy:GetDeployment"
        ],
        "Resource" : [
          "*"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "codedeploy:GetDeploymentConfig"
        ],
        "Resource" : [
          "arn:aws:codedeploy:${var.provider_region}:${local.aws_user_account_id}:deploymentconfig:CodeDeployDefault.AllAtOnce"
        ]
      }
    ]
  })

}


resource "aws_iam_user_policy_attachment" "test-attach1" {
  user       = var.app_user_name
  policy_arn = aws_iam_policy.code_deploy_ec2_s3.arn
}

resource "aws_iam_user_policy_attachment" "test-attach2" {
  user       = var.app_user_name
  policy_arn = aws_iam_policy.gh_upload_s3_policy.arn
}

resource "aws_iam_user_policy_attachment" "test-attach3" {
  user       = var.app_user_name
  policy_arn = aws_iam_policy.code_deploy_policy.arn
}

//  ************* ec2  service role 

resource "aws_iam_role" "ec2_service_role" {
  name = "CodeDeployEC2ServiceRole"
  // depends_on = [aws_iam_role.codedeploy_service_role]
  assume_role_policy = jsonencode({

    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : [
            "ec2.amazonaws.com"
          ]
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })

}

//  ************* ec2 service role attachment
resource "aws_iam_policy_attachment" "ec2_attach1" {
  name       = "ec2attach1"
  users      = [var.app_user_name]
  roles      = ["${aws_iam_role.ec2_service_role.name}"]
  policy_arn = aws_iam_policy.code_deploy_ec2_s3.arn
}


//  ************* code deploy  service role 

resource "aws_iam_role" "codedeploy_service_role" {
  name = "CodeDeployServiceRole"
  assume_role_policy = jsonencode({

    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : [
            "ec2.amazonaws.com",
            "codedeploy.amazonaws.com"
          ]
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

//  ************* code deploy service role attachment

resource "aws_iam_policy_attachment" "codedeploy_service2" {
  name       = "cdroleattach"
  users      = [var.app_user_name]
  roles      = ["${aws_iam_role.codedeploy_service_role.name}"]
  policy_arn = aws_iam_policy.code_deploy_policy.arn
}

resource "aws_iam_policy_attachment" "codedeploy_service21" {
  name       = "cdroleattach1"
  users      = [var.app_user_name]
  roles      = ["${aws_iam_role.codedeploy_service_role.name}"]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
}





resource "aws_codedeploy_app" "codedeploy_app" {
  compute_platform = "Server"
  name             = "webapp"
}

resource "aws_codedeploy_deployment_group" "codedeploy_deployment_group" {
  depends_on             = [aws_codedeploy_app.codedeploy_app, aws_iam_role.codedeploy_service_role]
  app_name               = aws_codedeploy_app.codedeploy_app.name
  deployment_group_name  = "csye6225-webapp-deployment"
  deployment_config_name = "CodeDeployDefault.AllAtOnce"
  service_role_arn       = aws_iam_role.codedeploy_service_role.arn

  ec2_tag_set {
    ec2_tag_filter {
      key   = "Name"
      type  = "KEY_AND_VALUE"
      value = "csye6225_ec2"
    }
  }
  deployment_style {
    deployment_option = "WITHOUT_TRAFFIC_CONTROL"
    deployment_type   = "IN_PLACE"
  }

  auto_rollback_configuration {
    enabled = false
    events  = ["DEPLOYMENT_FAILURE"]
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = ["${aws_lb_listener.a_lb_listener.arn}"]
      }

      target_group {
        name = aws_lb_target_group.lb_targetgroup.name
      }

    }
  }

  autoscaling_groups = ["${aws_autoscaling_group.asg.name}"]

}

