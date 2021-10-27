
resource "aws_vpc" "vpc_infra" {
  cidr_block                       = var.vpc_cidr_block
  enable_dns_hostnames             = var.vpc_enable_dns_hostnames
  enable_dns_support               = var.vpc_enable_dns_support
  enable_classiclink_dns_support   = var.vpc_enable_classiclink_dns_support
  assign_generated_ipv6_cidr_block = var.vpc_assign_generated_ipv6_cidr_block

  tags = {
    Name        = "vpc_infra"
    description = "vpc for infrastructue"
  }
}


resource "aws_subnet" "subnet_infra" {
  depends_on = [aws_vpc.vpc_infra]

  for_each = var.subnets

  cidr_block              = each.value.cidr
  vpc_id                  = aws_vpc.vpc_infra.id
  availability_zone       = each.value.az
  map_public_ip_on_launch = var.aws_subnet_map_public_ip_on_launch
  tags = {
    Name        = "subnet_infra.${each.value.count}"
    description = "subnet for infrastructue"
  }
}


resource "aws_internet_gateway" "infra_gw" {
  depends_on = [aws_vpc.vpc_infra]
  vpc_id     = aws_vpc.vpc_infra.id

  tags = {
    Name        = "vpc_gw_infra"
    description = "gateway for infrastructue"
  }
}

resource "aws_route_table" "infra_route" {
  depends_on = [aws_internet_gateway.infra_gw]
  vpc_id     = aws_vpc.vpc_infra.id

  route {
    cidr_block = var.route_table_cidr
    gateway_id = aws_internet_gateway.infra_gw.id
  }

  tags = {
    Name        = "route_table_infra"
    description = "route table for infrastructue"
  }
}

resource "aws_route_table_association" "route_table_asso" {
  depends_on     = [aws_route_table.infra_route, aws_subnet.subnet_infra]
  for_each       = aws_subnet.subnet_infra
  subnet_id      = each.value.id
  route_table_id = aws_route_table.infra_route.id
}



resource "aws_db_subnet_group" "subnet_group" {
  depends_on = [aws_route_table.infra_route, aws_subnet.subnet_infra]
  name       = "subnet_group"
  subnet_ids = values(aws_subnet.subnet_infra)[*].id

  tags = {
    Name = "My DB subnet group"
  }
}




resource "aws_security_group" "application" {
  depends_on  = [aws_vpc.vpc_infra]
  name        = "application"
  description = "Allow application inbound traffic"
  vpc_id      = aws_vpc.vpc_infra.id

  ingress {
    description      = "TLS from VPC"
    from_port        = var.sg_app_ingress_p1
    to_port          = var.sg_app_ingress_p1
    protocol         = var.protocol
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "TLS from VPC"
    from_port        = var.sg_app_ingress_p2
    to_port          = var.sg_app_ingress_p2
    protocol         = var.protocol
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "TLS from VPC"
    from_port        = var.sg_app_ingress_p3
    to_port          = var.sg_app_ingress_p3
    protocol         = var.protocol
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  ingress {
    description      = "TLS from VPC"
    from_port        = var.sg_app_ingress_p4
    to_port          = var.sg_app_ingress_p4
    protocol         = var.protocol
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "application security group"
  }
}

resource "aws_security_group" "database" {
  depends_on = [aws_vpc.vpc_infra]
  name       = "database"
  vpc_id     = aws_vpc.vpc_infra.id

  ingress {
    description = "For postgres db"
    from_port   = var.sg_db_ingress_p1
    to_port     = var.sg_db_ingress_p1
    protocol    = var.protocol
    // cidr_blocks      = aws_vpc.vpc_infra.cidr_block
    ipv6_cidr_blocks = ["::/0"]
    security_groups = [aws_security_group.application.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "database security group"
  }
}

// RDS *******************************************************************

resource "aws_db_parameter_group" "db_parameter_group" {
  depends_on  = [aws_security_group.database, aws_db_subnet_group.subnet_group]
  name        = "rds-pg"
  family      = var.db_param_family
  description = "Postgres parameter group"
}


resource "aws_db_instance" "rds" {
  depends_on             = [aws_security_group.database, aws_db_parameter_group.db_parameter_group, aws_db_subnet_group.subnet_group]
  allocated_storage      = 20
  engine                 = var.db_engine
  engine_version         = var.db_engine_version
  instance_class         = var.db_instance_class
  multi_az               = var.db_multi_az
  identifier             = var.db_identifier
  name                   = var.db_identifier
  username               = var.db_identifier
  password               = var.db_pass
  db_subnet_group_name   = aws_db_subnet_group.subnet_group.name
  parameter_group_name   = aws_db_parameter_group.db_parameter_group.name
  publicly_accessible    = var.db_public_access
  skip_final_snapshot    = var.db_snapshot
  vpc_security_group_ids = [aws_security_group.database.id]
}



// S3 *******************************************************************

resource "random_string" "s3_name" {
  length    = 5
  special   = false
  number    = false
  lower     = true
  min_upper = 0
  min_lower = 5
}

resource "aws_kms_key" "aws_key" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
}



resource "aws_s3_bucket" "bucket" {
  depends_on    = [random_string.s3_name, aws_kms_key.aws_key]
  bucket        = "${random_string.s3_name.id}.${var.domain_name}"
  acl           = "private"
  force_destroy = true

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.aws_key.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }

  lifecycle_rule {
    // id      = "archive"
    enabled = true
    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
  }

  tags = {
    Name        = "csye6225 bucket"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_public_access_block" "bucket_access" {
  bucket                  = aws_s3_bucket.bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}



// IAM *******************************************************************





resource "aws_iam_role_policy" "WebAppS3" {
  name = "WebAppS3"
  role = aws_iam_role.EC2-CSYE6225.id

  policy = jsonencode({

    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:GetObject",
          "s3:PutObject"
        ],
        "Resource" : [
          "${aws_s3_bucket.bucket.arn}/*"
        ]
      },
    ]
  })
}

resource "aws_iam_role" "EC2-CSYE6225" {
  name = "EC2-CSYE6225"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}




// EC2 *******************************************************************


resource "aws_iam_instance_profile" "iam_profile" {
  name = "iam_profile"
  role = aws_iam_role.EC2-CSYE6225.name
}

resource "aws_key_pair" "ubuntu" {
  key_name   = "ubuntu"
  public_key = file("key.pub")
}


resource "aws_instance" "csye_instance" {
  depends_on              = [aws_db_instance.rds]
  ami                     = "ami-09e67e426f25ce0d7"
  instance_type           = "t2.micro"
  subnet_id               = values(aws_subnet.subnet_infra)[0].id
  vpc_security_group_ids  = [aws_security_group.application.id]
  disable_api_termination = false

  root_block_device {
    delete_on_termination = true
    volume_size           = 20
    volume_type           = "gp2"
  }
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("key")
    host        = self.public_ip
  }
  key_name             = aws_key_pair.ubuntu.key_name
  iam_instance_profile = aws_iam_instance_profile.iam_profile.name

}