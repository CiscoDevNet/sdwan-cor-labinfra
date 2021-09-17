# SD-WAN Branch 1 - consists of SD-WAN router, one WAN emulator (linux VM) and one linux host as app simulation:

variable "aws_branch1_region" {    
    default = "us-west-2"             # if you change the default region, please also change AMI IDs below
}

variable "bucket_prefix" {            # use this a prefix in descriptions of ressources, which will be prepended to the name of all ressources. Example "Demo Branch1 Subnet-1 Mgmt"
    default = "Demo"
}

variable "ssh_allow_cidr" {           # allow ssh only from Cisco San Jose VPN Cluster
    default = "128.107.0.0/16"
}

variable "aws_branch1_az" {    
    default = "us-west-2b"
}

variable "aws_ami_id_branch1_r1" {
  default = "ami-0c1961e24860d740c"   # Cisco-CSR-SDWAN-17.3.2 Marketplace AMI for this region. Please change the AMI if you want to use a different region!
}

variable "aws_ami_type_branch1_r1" {
  default = "c5.xlarge"               # please keep in mind, that your AWS instance type needs to support at least 3 NICs.  
}

variable "aws_branch1_vpc_cidr" {    
    default = "10.111.0.0/16"
}

variable "aws_branch1_vpc_subnet1_cidr" {
    default = "10.111.1.0/24"
}

variable "aws_branch1_r1_nic1_private_ip" {  
    default = "10.111.1.11"
}

variable "aws_branch1_vpc_subnet2_cidr" {
    default = "10.111.2.0/24"
}

variable "aws_branch1_r1_nic2_private_ip" {  
    default = "10.111.2.11"
}

variable "aws_branch1_vpc_subnet3_cidr" {
    default = "10.111.3.0/24"
}

variable "aws_branch1_r1_nic3_private_ip" {  
    default = "10.111.3.11"
}

variable "aws_branch1_vpc_subnet4_cidr" {  # WAN Emulator CIDR out to public internet
    default = "10.111.4.0/24"
}

variable "aws_ami_id_host1" {
  default = "ami-00f9f4069d04c0c6e"      # Amazon Linux 2 AMI (HVM), SSD Volume Type (64-bit x86). Please change the AMI if you want to use a different region!
}

variable "aws_ami_type_host1" {
  default = "t2.medium"
}

variable "aws_host1-subnet1_private_ip" {  
    default = "10.111.1.101"
}

variable "aws_host1-subnet3_private_ip" {  
    default = "10.111.3.101"
}


variable "aws_branch1_wanem_nic1_private_ip" {  
    default = "10.111.1.10"
}

variable "aws_branch1_wanem_nic2_private_ip" {  
    default = "10.111.2.10"
}

variable "aws_branch1_wanem_nic3_private_ip" {  
    default = "10.111.4.10"
}


# SSH Key File:
variable "aws_key_pair_name" {
  default = "aws-key-20-3-setup"   # Please change to your AWS pem ssh key file! It will NOT work with the default value "aws-key-20-3-setup"
}