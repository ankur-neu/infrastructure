// resource "aws_dynamodb_table" "dynamo" {
//   name           = "dynamo"
//   billing_mode   = "PROVISIONED"
//   read_capacity  = 20
//   write_capacity = 20
//   hash_key       = "email"

//   attribute {
//     name = "email"
//     type = "S"
//   }

//   attribute {
//     name = "token"
//     type = "S"
//   }

//   tags = {
//   	Name = "dynamodb_table"
//   }
// }