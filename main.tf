
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

  // ingress {
  //   description = var.sg_app_ingress_desc
  //   from_port   = var.sg_app_ingress_p1
  //   to_port     = var.sg_app_ingress_p1
  //   protocol    = var.protocol
  //   cidr_blocks      = [var.sg_app_cidr]
  //   ipv6_cidr_blocks = [var.sg_app_cidr_ip6]
  // }

  // ingress {
  //   description      = var.sg_app_ingress_desc
  //   from_port        = var.sg_app_ingress_p2
  //   to_port          = var.sg_app_ingress_p2
  //   protocol         = var.protocol
  //   cidr_blocks      = [var.sg_app_cidr]
  //   ipv6_cidr_blocks = [var.sg_app_cidr_ip6]
  // }

  // ingress {
  //   description      = var.sg_app_ingress_desc
  //   from_port        = var.sg_app_ingress_p3
  //   to_port          = var.sg_app_ingress_p3
  //   protocol         = var.protocol
  //   cidr_blocks      = [var.sg_app_cidr]
  //   ipv6_cidr_blocks = [var.sg_app_cidr_ip6]
  // }
  ingress {
    description = var.sg_app_ingress_desc
    from_port   = var.sg_app_ingress_p4
    to_port     = var.sg_app_ingress_p4
    protocol    = var.protocol
    // cidr_blocks      = [var.sg_app_cidr]
    // ipv6_cidr_blocks = [var.sg_app_cidr_ip6]
    security_groups = ["${aws_security_group.lb_sg.id}"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = [var.sg_app_cidr]
    ipv6_cidr_blocks = [var.sg_app_cidr_ip6]
  }

  tags = {
    Name = "application security group"
  }
}

resource "aws_security_group" "database" {
  depends_on = [aws_vpc.vpc_infra]
  name       = var.sg_db_name
  vpc_id     = aws_vpc.vpc_infra.id

  ingress {
    description = var.sg_app_ingress_desc
    from_port   = var.sg_db_ingress_p1
    to_port     = var.sg_db_ingress_p1
    protocol    = var.protocol
    // cidr_blocks      = aws_vpc.vpc_infra.cidr_block
    ipv6_cidr_blocks = [var.sg_app_cidr_ip6]
    security_groups  = [aws_security_group.application.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.sg_app_cidr]
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
  special   = var.val_f
  number    = var.val_f
  lower     = var.val_t
  min_upper = 0
  min_lower = 5
}

resource "aws_kms_key" "aws_key" {
  description             = "Used to encrypt bucket objects"
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
    enabled = true
    transition {
      days          = 30
      storage_class = var.s3_storage_rule_class
    }
  }

  tags = {
    Name        = "csye6225 bucket"
    Environment = "s3-env"
  }
}

resource "aws_s3_bucket_public_access_block" "bucket_access" {
  bucket                  = aws_s3_bucket.bucket.id
  block_public_acls       = var.val_t
  block_public_policy     = var.val_t
  ignore_public_acls      = var.val_t
  restrict_public_buckets = var.val_t
}



// IAM *******************************************************************


resource "aws_iam_policy" "WebAppS3" {
  name = "webApps3"
  // role = aws_iam_role.EC2-CSYE6225.id

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
          "${aws_s3_bucket.bucket.arn}",
          "${aws_s3_bucket.bucket.arn}/*"
        ]
      },
    ]
  })
}

resource "aws_iam_user_policy_attachment" "policy_attacht_s3" {
  user       = var.app_user_name
  policy_arn = aws_iam_policy.WebAppS3.arn
}

resource "aws_iam_role" "EC2-CSYE6225" {
  name = "ec2-csye6225"

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

data "aws_ami" "ami" {
  most_recent = true
  owners      = [var.ami_owners]
}


resource "aws_iam_instance_profile" "iam_profile" {
  name = "iam-prof"
  role = var.ec2_deploy_role_name
}


resource "aws_key_pair" "ubuntu" {
  key_name   = var.ec2_key_name
  public_key = file("key.pub")
}


// resource "aws_instance" "csye_instance" {
//   depends_on             = [aws_db_instance.rds]
//   ami                    = data.aws_ami.ami.id
//   instance_type          = var.ec2_instance_type
//   subnet_id              = values(aws_subnet.subnet_infra)[0].id
//   vpc_security_group_ids = [aws_security_group.application.id]
//   user_data              = <<-EOF
//     #!/bin/bash
//     sudo apt-get update
//     curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
//     sudo apt-get install -y nodejs
//     sudo apt install npm

//     echo export DB_HOST=${aws_db_instance.rds.address} >> /etc/profile
//     echo export PORT=${var.app_port} >> /etc/profile
//     echo export DB_NAME=${var.db_name} >> /etc/profile
//     echo export DB_HOST=${aws_db_instance.rds.address} >> /etc/profile
//     echo export DB_USER=${var.db_user} >> /etc/profile
//     echo export DB_PASS=${var.db_pass} >> /etc/profile
//     echo export DB_PORT=${var.sg_db_ingress_p1} >> /etc/profile
//     echo export BUCKET_NAME=${aws_s3_bucket.bucket.id} >> /etc/profile
//     // echo export ACCESS_KEY=${var.access_key} >> /etc/profile
//     // echo export SECRET_KEY=${var.secret_key} >> /etc/profile
//   EOF

//   disable_api_termination = false
//   root_block_device {
//     delete_on_termination = true
//     volume_size           = 20
//     volume_type           = "gp2"
//   }
//   connection {
//     type        = "ssh"
//     user        = var.ec2_conn_user
//     private_key = file("key")
//     host        = self.public_ip
//   }
//   key_name             = aws_key_pair.ubuntu.key_name
//   iam_instance_profile = aws_iam_instance_profile.iam_profile.name

//   tags = {
//     Name = "csye6225_ec2"
//   }

// }

data "aws_route53_zone" "zone" {
  name         = var.domain_name
  private_zone = false
}

resource "aws_route53_record" "www" {
  // depends_on = [aws_instance.csye_instance]
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = data.aws_route53_zone.zone.name
  type    = "A"
  // ttl        = "300"
  alias {
    name                   = aws_lb.aws_lb_app.dns_name
    zone_id                = aws_lb.aws_lb_app.zone_id
    evaluate_target_health = false
  }
}
