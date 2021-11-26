# Cloud App1 for SD-WAN Security demo - consists of one Linux host running a web client

variable "bucket_prefix" {            # use this a prefix in descriptions of ressources, which will be prepended to the name of all ressources. Example "FW-VPC1"
    default = "SEC"
}

variable "ssh_allow_cidr" {           # allow ssh only from Cisco San Jose VPN Cluster, adjust as needed!
    default = "128.107.0.0/16"
}

variable "aws_cloud-site_region" {    
    default = "us-west-2"         # if you change the default region, please also change AMI IDs below
}                                 # set the region like this because terraform does not pickup the region from .aws/configure: export AWS_DEFAULT_REGION=$(aws configure get region --profile default)


variable "aws_cloud-site_az" {    
    default = "us-west-2c"
}


variable "aws_cloud-site_vpc_cidr" {    
    default = "10.72.0.0/16"
}

variable "aws_cloud-site_vpc_subnet-1_cidr" {
    default = "10.72.1.0/24"
}

variable "aws_cloud-site_vpc_subnet-2_cidr" {
    default = "10.72.2.0/24"
}


variable "aws_ami_id_host1" {
  default = "ami-0e5b6b6a9f3db6db8"   # Amazon Linux 2 AMI (HVM), SSD Volume Type (64-bit x86). Please change the AMI if you want to use a different region!
}

variable "aws_ami_type_host1" {
  default = "t2.micro"
}

variable "aws_host1-subnet-1_private_ip" {  
    default = "10.72.1.101"
}

variable "aws_host1-subnet-2_private_ip" {  
    default = "10.72.2.101"
}

variable "tgw_amazon_side_asn" {  
    default = "64522"   # please make sure, that this is unique, we will use it as filter
}

# SSH Key File:
variable "aws_key_pair_name" {
  default = "aws-key-20-3-setup"      # Please change to your AWS pem ssh key file! It will NOT work with the default value "aws-key-20-3-setup"
}