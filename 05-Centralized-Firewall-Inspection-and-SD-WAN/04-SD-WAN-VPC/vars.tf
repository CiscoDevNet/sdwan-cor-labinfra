# SD-WAN VPC - consists of two SD-WAN routers connected to SD-WAN Fabric and to AWS TGW

variable "bucket_prefix" {            # use this a prefix in descriptions of ressources, which will be prepended to the name of all ressources. Example "Demo Branch1 Subnet-1 Mgmt"
    default = "SEC"
}

variable "ssh_allow_cidr" {           # allow ssh only from Cisco San Jose VPN Cluster
    default = "128.107.0.0/16"
}

variable "aws_sdwan_region" {    
    default = "us-west-2"
}

variable "aws_sdwan_az1" {    
    default = "us-west-2c"
}

variable "aws_sdwan_az2" {    
    default = "us-west-2b"
}

variable "aws_ami_id_sdwan_router" {
  default = "ami-087c4c3dcd724a5fd"   # Cisco Cat8000v 17.6.1. Marketplace AMI for this region. Please change the AMI if you want to use a different region!
}

variable "aws_ami_type_sdwan_router" {
  default = "c5n.xlarge"               # please keep in mind, that your AWS instance type needs to support at least 3 NICs. Going with 4 NICs here.  
}

variable "aws_sdwan_vpc_cidr" {    
    default = "10.71.0.0/16"
}

variable "aws_sdwan_vpc_az1_subnet-1_cidr" {
    default = "10.71.1.0/24"
}

variable "aws_sdwan_vpc_az1_subnet-2_cidr" {
    default = "10.71.2.0/24"
}

variable "aws_sdwan_vpc_az1_subnet-3_cidr" {
    default = "10.71.3.0/24"
}

variable "aws_sdwan_vpc_az2_subnet-1_cidr" {
    default = "10.71.11.0/24"
}

variable "aws_sdwan_vpc_az2_subnet-2_cidr" {
    default = "10.71.12.0/24"
}

variable "aws_sdwan_vpc_az2_subnet-3_cidr" {
    default = "10.71.13.0/24"
}

variable "aws_sdwan_r1_nic1_private_ip" {  
    default = "10.71.1.11"
}

variable "aws_sdwan_r1_nic2_private_ip" {  
    default = "10.71.2.11"
}

variable "aws_sdwan_r1_nic3_private_ip" {  
    default = "10.71.3.11"
}

variable "aws_sdwan_r2_nic1_private_ip" {  
    default = "10.71.11.11"
}

variable "aws_sdwan_r2_nic2_private_ip" {  
    default = "10.71.12.11"
}

variable "aws_sdwan_r2_nic3_private_ip" {  
    default = "10.71.13.11"
}

variable "tgw_amazon_side_asn" {  
    default = "64522"    # please make sure, that this is unique, we will use it as filter
}


# SSH Key File:
variable "aws_key_pair_name" {       # Please change to your AWS pem ssh key file! It will NOT work with the default value "aws-key-20-3-setup"
  default = "aws-key-20-3-setup"
}