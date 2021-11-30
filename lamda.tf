resource "aws_lambda_function" "user_add_lamda" {
  s3_bucket     = var.bucket_name
  s3_key        = "userAddLamda.zip"
  function_name = "userAddLamda"
  role          = aws_iam_role.serverless_lambda_user_role.arn
  handler       = "index.userAddLamda"
  timeout       = 20
  runtime       = "nodejs14.x"

  environment {
    variables = {
      DOMAIN_NAME = "${var.domain_name}",
      TTL         = "${var.TTL}"
    }
  }
}

resource "aws_lambda_permission" "lambda_to_sns" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.user_add_lamda.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.user_add.arn
}

resource "aws_iam_role" "serverless_lambda_user_role" {
  name = "serverless_lambda_user_role"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "sts:AssumeRole",
        "Principal" : {
          "Service" : "lambda.amazonaws.com"
        },
        "Effect" : "Allow",
        "Sid" : ""
      }
    ]
  })
}


resource "aws_iam_policy" "lamda_update_policy" {
  name        = "LamdaUpdatePolicy"
  description = "Update Lamda from GH"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : "lambda:UpdateFunctionCode",
        "Resource" : [
          "arn:aws:lambda:***:***:function:userAddLamda"
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "lamda_ses_policy" {
  name        = "LamdaSendEmailPolicy"
  description = "Send Mail through Lamda"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "ses:SendEmail"
        ],
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "lamda_ses_attach" {
  name       = "lamdaSESPolicy"
  roles      = ["${aws_iam_role.serverless_lambda_user_role.name}"]
  policy_arn = aws_iam_policy.lamda_ses_policy.arn
}

resource "aws_iam_user_policy_attachment" "lamda_user_attach" {
  user       = var.app_user_name
  policy_arn = aws_iam_policy.lamda_update_policy.arn
}

//  ************* lamda dynamo role attachment
resource "aws_iam_policy_attachment" "lamda_user_dynamo_attach" {
  name       = "lamdaDynamoPolicy"
  roles      = ["${aws_iam_role.serverless_lambda_user_role.name}"]
  policy_arn = aws_iam_policy.dynamo_policy.arn
}