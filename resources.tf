resource "aws_sns_topic" "user_add" {
  name = "user-add-topic"
}

resource "aws_sns_topic_subscription" "lambda_serverless_topic_subscription" {
  topic_arn = aws_sns_topic.user_add.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.user_add_lamda.arn
}

resource "aws_iam_policy" "sns_ec2_policy" {
  name        = "SNS-EC2-Polcy"
  description = "EC2 to create and publish sns topics"
  depends_on  = [aws_iam_role.ec2_service_role]
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : [
          "sns:*",
        ],
        "Effect" : "Allow",
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "ec2_sns_attach" {
  name       = "ec2SnsAttach"
  roles      = ["${aws_iam_role.ec2_service_role.name}"]
  policy_arn = aws_iam_policy.sns_ec2_policy.arn
}