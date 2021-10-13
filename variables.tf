variable "vpc_cidr_block" {
  description = "CIDR for vpc infra"
  type        = string
}

// variable "subnet_cidr_block" {
//   description = "CIDR for subnet"
//   type        = string
//   // default = "10.1.0.0/24"
// }

variable "subnets" {
  default = {
    "1" = {
      count = 1
      az    = "us-east-1a"
      cidr  = "10.0.1.0/24"
    },
    "2" = {
      count = 2
      az    = "us-east-1b"
      cidr  = "10.0.2.0/24"
    },
    "3" = {
      count = 3
      az    = "us-east-1c"
      cidr  = "10.0.3.0/24"
    }
  }
}

