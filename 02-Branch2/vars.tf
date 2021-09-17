# SD-WAN Branch 2 - consists of SD-WAN router and one host:

variable "bucket_prefix" {            # use this a prefix in descriptions of ressources, which will be prepended to the name of all ressources. Example "Demo Branch1 Subnet-1 Mgmt"
    default = "Demo"
}

variable "ssh_allow_cidr" {           # allow ssh only from Cisco San Jose VPN Cluster
    default = "128.107.0.0/16"
}

variable "aws_branch2_region" {    
    default = "ap-southeast-2"
}

variable "aws_branch2_az" {    
    default = "ap-southeast-2b"
}

variable "aws_ami_id_branch2_r1" {
  default = "ami-032d343a587b0b958"   # Cisco-CSR-SDWAN-17.3.2 Marketplace AMI for this region. Please change the AMI if you want to use a different region!
}

variable "aws_ami_type_branch2_r1" {
  default = "c5.xlarge"               # please keep in mind, that your AWS instance type needs to support at least 3 NICs.  
}

variable "aws_branch2_vpc_cidr" {    
    default = "10.112.0.0/16"
}

variable "aws_branch2_vpc_subnet-1_cidr" {
    default = "10.112.1.0/24"
}

variable "aws_branch2_r1_nic1_private_ip" {  
    default = "10.112.1.11"
}

variable "aws_branch2_vpc_subnet-2_cidr" {
    default = "10.112.2.0/24"
}

variable "aws_branch2_r1_nic2_private_ip" {  
    default = "10.112.2.11"
}

variable "aws_branch2_vpc_subnet-3_cidr" {
    default = "10.112.3.0/24"
}

variable "aws_branch2_r1_nic3_private_ip" {  
    default = "10.112.3.11"
}


variable "aws_ami_id_host1" {
  default = "ami-04f77aa5970939148"   # Amazon Linux 2 AMI (HVM), SSD Volume Type (64-bit x86). Please change the AMI if you want to use a different region! 
}

variable "aws_ami_type_host1" {
  default = "t2.medium"
}

variable "aws_host1-subnet-1_private_ip" {  
    default = "10.112.1.101"
}

variable "aws_host1-subnet-3_private_ip" {  
    default = "10.112.3.101"
}


# SSH Key File:
variable "aws_key_pair_name" {       # Please change to your AWS pem ssh key file! It will NOT work with the default value "aws-key-20-3-setup"
  default = "aws-key-20-3-setup"
}