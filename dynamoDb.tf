resource "aws_dynamodb_table" "dynamo" {
  name           = "dynamo"
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "username"

  attribute {
    name = "username"
    type = "S"
  }
  ttl {
    attribute_name = "ttl"
    enabled        = true
  }
  tags = {
    Name = "dynamodb_table"
  }
}

resource "aws_iam_policy" "dynamo_policy" {
  name        = "Dynamo-Lambda"
  description = "Lambda function update data to Dynamo"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "ListAndDescribe",
        "Effect" : "Allow",
        "Action" : [
          "dynamodb:List*",
          "dynamodb:DescribeReservedCapacity*",
          "dynamodb:DescribeLimits",
          "dynamodb:DescribeTimeToLive",
          "dynamodb:Get*",
          "dynamodb:PutItem*"
        ],
        "Resource" : "*"
      },
      {
        "Sid" : "SpecificTable",
        "Effect" : "Allow",
        "Action" : [
          "dynamodb:BatchGet*",
          "dynamodb:DescribeStream",
          "dynamodb:DescribeTable",
          "dynamodb:Get*",
          "dynamodb:Query",
          "dynamodb:Scan",
          "dynamodb:BatchWrite*",
          "dynamodb:CreateTable",
          "dynamodb:Delete*",
          "dynamodb:Update*",
          "dynamodb:PutItem*"
        ],
        "Resource" : "arn:aws:dynamodb:*:*:table/dynamo"
      }
    ]
  })
}


//  ************* ec2 dynamo role attachment
resource "aws_iam_policy_attachment" "ec2_dynamo_attach" {
  name       = "ec2DynamoPolicy"
  roles      = ["${aws_iam_role.ec2_service_role.name}"]
  policy_arn = aws_iam_policy.dynamo_policy.arn
}

