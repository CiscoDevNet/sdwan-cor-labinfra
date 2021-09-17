# Cloud App for SD-WAN demo - consists of one host:

variable "bucket_prefix" {    # use this a prefix in descriptions of ressources
    default = "GCP"
}

variable "aws_cloud-site_region" {    
    default = "us-west-2"
}

variable "aws_cloud-site_az" {    
    default = "us-west-2b"
}


variable "aws_cloud-site_vpc_cidr" {    
    default = "10.53.0.0/16"
}

variable "aws_cloud-site_vpc_subnet-1_cidr" {
    default = "10.53.1.0/24"
}

variable "aws_cloud-site_vpc_subnet-2_cidr" {
    default = "10.53.2.0/24"
}


variable "aws_ami_id_host1" {
  default = "ami-04f77aa5970939148"   # Amazon Linux 2 AMI (HVM), SSD Volume Type (64-bit x86) 
}

variable "aws_ami_type_host1" {
  default = "t2.medium"
}

variable "aws_host1-subnet-1_private_ip" {  
    default = "10.53.1.101"
}

variable "aws_host1-subnet-2_private_ip" {  
    default = "10.53.2.101"
}


# SSH Key File:
variable "aws_key_pair_name" {
  default = "aws-key-20-3-setup"
}