# SD-WAN Controllers:

variable "aws_controllers_region" {    
    default = "us-west-2"
}

variable "aws_controllers_az" {    
    default = "us-west-2a"
}

variable "bucket_prefix" {            # use this a prefix in descriptions of ressources, which will be prepended to the name of all ressources. Example "Demo Branch1 Subnet-1 Mgmt"
    default = "Test5"
}

variable "aws_ami_id_vmanage" {
  default = "ami-038a84f798016c28d"   # 20.12 eng. image, available only in us-west-2. Must be shared by Cisco as private AMI.
}

variable "aws_ami_type_vmanage" {
  default = "c7i.4xlarge"
}

variable "aws_ami_id_vsmart" {
  default = "ami-0d3a38565cad7e9a8"   # 20.12 eng. image, available only in us-west-2. Must be shared by Cisco as private AMI.
}

variable "aws_ami_type_vsmart" {
  default = "t3.medium"               # Changed from t2 to t3 in order to have console access via AWS UI
}

variable "aws_ami_id_vbond" {
  default = "ami-03bdae9b1edc67cce"   # 20.12 eng. image, available only in us-west-2. Must be shared by Cisco as private AMI.
}

variable "aws_ami_type_vbond" {
  default = "t3.medium"               # Changed from t2 to t3 in order to have console access via AWS UI
}

variable "ssh_allow_cidr" {           # allow ssh only from Cisco San Jose VPN Cluster, adjust as needed!
    default = "128.107.0.0/16"
}

variable "https_allow_cidr" {           # allow https only from Cisco San Jose VPN Cluster, adjust as needed!
    default = "128.107.0.0/16"
}


variable "aws_controllers_vpc_cidr" {    
    default = "10.201.0.0/16"
}

variable "aws_controllers_subnet-1_cidr" {    // vpn512
    default = "10.201.1.0/24"
}

variable "aws_controllers_subnet-2_cidr" {    // vpn0
    default = "10.201.2.0/24"
}

variable "aws_vmanage-subnet-1_private_ip" {    // vpn512
    default = "10.201.1.11"
}

variable "aws_vbond-subnet-1_private_ip" {    // vpn512
    default = "10.201.1.12"
}

variable "aws_vsmart-subnet-1_private_ip" {    // vpn512
    default = "10.201.1.13"
}

variable "aws_vsmart2-subnet-1_private_ip" {    // vpn512
    default = "10.201.1.15"
}

variable "aws_vmanage-subnet-2_private_ip" {    // vpn0
    default = "10.201.2.11"
}

variable "aws_vbond-subnet-2_private_ip" {    // vpn0
    default = "10.201.2.12"
}

variable "aws_vsmart-subnet-2_private_ip" {    // vpn0
    default = "10.201.2.13"
}

variable "aws_vsmart2-subnet-2_private_ip" {    // vpn0
    default = "10.201.2.15"
}


# SSH Key File. Please note, that this key file is NOT included into the repo, you will need to use your own key pair!
variable "aws_key_pair_name" {
  default = "aws-key-20-3-setup"
}