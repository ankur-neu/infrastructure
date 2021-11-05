
// for provider

variable "provider_region" {
  description = "Region for Provider"
  type        = string
}

variable "provider_profile" {
  description = "Profile for Provider"
  type        = string
}

variable "app_port" {
  description = "Profile for Provider"
  type        = string
}

// vpc configurations

variable "vpc_enable_dns_hostnames" {
  description = "Enable DNS Hostname for vpc"
  type        = bool
}

variable "vpc_enable_dns_support" {
  description = "Enable DNS Support for vpc"
  type        = bool
}

variable "vpc_enable_classiclink_dns_support" {
  description = "Enable Classic Link Dns Support for vpc"
  type        = bool
}

variable "vpc_assign_generated_ipv6_cidr_block" {
  description = "Assign Generated IPv6 Cidr block"
  type        = bool
}

variable "vpc_cidr_block" {
  description = "CIDR for vpc infra"
  type        = string
}

//  subnet details object
variable "subnets" {
  type = map(object({
    count = number
    az    = string
    cidr  = string
  }))
}

variable "aws_subnet_map_public_ip_on_launch" {
  description = "Map Public Ip on launch"
  type        = bool
}

// cidr details of route table
variable "route_table_cidr" {
  description = "CIDR for vpc route table"
  type        = string
}

variable "sg_app_ingress_p1" {
  description = "Ingress port for application"
  type        = number
}

variable "sg_app_ingress_p2" {
  description = "Ingress port for application"
  type        = number
}

variable "sg_app_ingress_p3" {
  description = "Ingress port for application"
  type        = number
}

variable "sg_app_ingress_p4" {
  description = "Ingress port for application"
  type        = number
}


variable "sg_db_ingress_p1" {
  description = "Ingress port for database"
  type        = number
}


variable "protocol" {
  description = "Ingress port for database"
  type        = string
}

variable "db_param_family" {
  description = "DB Family"
  type        = string
}


variable "db_engine" {
  description = "DB Engine"
  type        = string
}

variable "db_engine_version" {
  description = "DB Engine Version"
  type        = string
}

variable "db_instance_class" {
  description = "DB Instance Class"
  type        = string
}

variable "db_multi_az" {
  description = "Availabilty of DB"
  type        = bool
}

variable "db_identifier" {
  description = "DB Identifier"
  type        = string
}

variable "db_pass" {
  description = "DB Password"
  type        = string
}

variable "db_name" {
  description = "DB Name"
  type        = string
}


variable "db_user" {
  description = "DB User"
  type        = string
}

variable "db_public_access" {
  description = "DB accessible publically"
  type        = bool
}

variable "db_snapshot" {
  description = "Need DB Sanpshot"
  type        = bool
}


variable "sg_app_cidr" {
  description = "CIDR for app security group"
  type        = string
}


variable "sg_app_cidr_ip6" {
  description = "CIDR for app security group IPv6"
  type        = string
}

variable "sg_app_ingress_desc" {
  description = "Ingress description for app security group IPv6"
  type        = string
}

variable "sg_db_ingress_desc" {
  description = "Ingress description for db security group IPv6"
  type        = string
}

variable "sg_db_name" {
  description = "Database security group name"
  type        = string
}

variable "s3_storage_rule_class" {
  description = "S3 rule for storage class"
  type        = string
}

variable "ec2_key_name" {
  description = "EC2 key name"
  type        = string
}

variable "ec2_instance_type" {
  description = "EC2 Instance Type"
  type        = string
}

variable "ec2_conn_user" {
  description = "EC2 Connection user"
  type        = string
}













variable "val_f" {
  description = "False Value"
  type        = string
}
variable "val_t" {
  description = "True Value"
  type        = string
}



variable "domain_name" {
  description = "Name of domain"
  type        = string
}

variable "region" {
  description = "Current AWS Region"
  type        = string
}

variable "ami" {
  description = "AMI Used"
  type        = string
}

variable "access_key" {
  description = "Access Key"
  type        = string
}

variable "secret_key" {
  description = "Secret Key"
  type        = string
}

variable "ami_owners" {
  description = "Ami owner Id"
  type        = string
}


variable "ec2_deploy_role_name" {
  description = "EC2 service code deploy role name"
  type        = string
}





