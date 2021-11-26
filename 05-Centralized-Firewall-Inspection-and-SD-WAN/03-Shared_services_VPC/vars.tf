# Shared Services for SD-WAN Security demo - consists of two FTDv Firewall VMs running in a different AZ with GWLB
# Please note, that FMCv controller should be deployed in a different VPC, ideally next to SD-WAN Controllers.
# FMCv deployment is NOT part of this script.

variable "bucket_prefix" {            # use this a prefix in descriptions of ressources, which will be prepended to the name of all ressources. Example "FW-VPC1"
    default = "SEC"
}

variable "ssh_allow_cidr" {           # allow ssh only from Cisco San Jose VPN Cluster, adjust as needed!
    default = "128.107.0.0/16"
}

variable "aws_shared-services_region" {    
    default = "us-west-2"         # if you change the default region, please also change AMI IDs below
}

variable "aws_shared-services_az1" {    
    default = "us-west-2c"
}

variable "aws_shared-services_az2" {    
    default = "us-west-2b"
}

variable "aws_shared-services_vpc_cidr" {    
    default = "10.70.0.0/16"
}

variable "aws_shared-services_vpc_az1_subnet-1_cidr" {
    default = "10.70.1.0/24"
}

variable "aws_shared-services_vpc_az1_subnet-2_cidr" {
    default = "10.70.2.0/24"
}

variable "aws_shared-services_vpc_az1_subnet-3_cidr" {
    default = "10.70.3.0/24"
}

variable "aws_shared-services_vpc_az2_subnet-1_cidr" {
    default = "10.70.11.0/24"
}

variable "aws_shared-services_vpc_az2_subnet-2_cidr" {
    default = "10.70.12.0/24"
}

variable "aws_shared-services_vpc_az2_subnet-3_cidr" {
    default = "10.70.13.0/24"
}

variable "aws_shared-services_vpc_az1_cidr_route_back_to_tgw" {
    default = "0.0.0.0/0" # tweak this if you want to route back to TGW only SD-WAN networks
}

variable "aws_shared-services_vpc_az2_cidr_route_back_to_tgw" {
    default = "0.0.0.0/0" # tweak this if you want to route back to TGW only SD-WAN networks
}

variable "aws_ami_id_fw" {
  default = "ami-0bb9a899312d2bade"   # FTDv Cisco-internal IFT version 7.1.0-61. Please change the AMI if you want to use a different region!
}

variable "aws_ami_type_fw" {
  default = "c5.xlarge"
}

variable "aws_fw1_subnet-1_private_ip" {  
    default = "10.70.1.101"
}

variable "aws_fw1_subnet-2_private_ip" {  
    default = "10.70.2.101"
}

variable "aws_fw1_subnet-3_private_ip" {  
    default = "10.70.3.101"
}

variable "aws_fw2_subnet-1_private_ip" {  
    default = "10.70.11.101"
}

variable "aws_fw2_subnet-2_private_ip" {  
    default = "10.70.12.101"
}

variable "aws_fw2_subnet-3_private_ip" {  
    default = "10.70.13.101"
}

variable "tgw_amazon_side_asn" {  
    default = "64522"    # please make sure, that this is unique, we will use it as filter
}

# SSH Key File:
variable "aws_key_pair_name" {
  default = "aws-key-20-3-setup"      # Please change to your AWS pem ssh key file! It will NOT work with the default value "aws-key-20-3-setup"
}