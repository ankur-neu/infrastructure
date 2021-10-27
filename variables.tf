
// for provider

variable "provider_region" {
  description = "Region for Provider"
  type        = string
}

variable "provider_profile" {
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
  description = "Ingress port for application"
  type        = number
}


variable "protocol" {
  description = "Ingress port for application"
  type        = string
}

variable "db_param_family" {
  description = "Ingress port for application"
  type        = string
}


variable "db_engine" {
  description = "Ingress port for application"
  type        = string
}

variable "db_engine_version" {
  description = "Ingress port for application"
  type        = string
}

variable "db_instance_class" {
  description = "Ingress port for application"
  type        = string
}

variable "db_multi_az" {
  description = "Ingress port for application"
  type        = bool
}

variable "db_identifier" {
  description = "Ingress port for application"
  type        = string
}

variable "db_pass" {
  description = "Ingress port for application"
  type        = string
}

variable "db_public_access" {
  description = "Ingress port for application"
  type        = bool
}

variable "db_snapshot" {
  description = "Ingress port for application"
  type        = bool
}



















variable "domain_name" {
  description = "Name of domain"
  type        = string
}

variable "region" {
  description = "Current AWS Region"
  type        = string
}

variable "AmiLinux" {
  description = "AMI Used"
  type        = string
}







