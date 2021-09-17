# Cloud App for SD-WAN demo - consists of one Linux host running a web server:

variable "bucket_prefix" {            # use this a prefix in descriptions of ressources, which will be prepended to the name of all ressources. Example "Demo Branch1 Subnet-1 Mgmt"
    default = "Demo"
}

variable "ssh_allow_cidr" {           # allow ssh only from Cisco San Jose VPN Cluster
    default = "128.107.0.0/16"
}

variable "aws_cloud-site_region" {    
    default = "ap-southeast-2"         # if you change the default region, please also change AMI IDs below
}

variable "aws_cloud-site_az" {    
    default = "ap-southeast-2b"
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
  default = "ami-04f77aa5970939148"   # Amazon Linux 2 AMI (HVM), SSD Volume Type (64-bit x86). Please change the AMI if you want to use a different region!
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
  default = "aws-key-20-3-setup"      # Please change to your AWS pem ssh key file! It will NOT work with the default value "aws-key-20-3-setup"
}