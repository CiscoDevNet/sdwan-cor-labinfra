# SD-WAN MRF Core Vars

# use this a prefix in descriptions of resources, which will be prepended to the name.
# Do not use special chars like _ (underscore)
variable "bucket_prefix" {
    default = "tst"
}


# GCP variables

# Define variables for GCP Core 1b:
variable "core_1b_gcp" {
    type = map
    default = {
      "gcp_core_1b" 		= "us-west1"
      "gcp_core_1b_zone" 	= "us-west1-b"
    }
}

# Define variable with Networking Details. Make sure, that your naming matches the following "^(?:[a-z](?:[-a-z0-9]{0,61}[a-z0-9])?)$"
variable "core_1b_networking" {
    type = map
    default = {
        "gce_core_1b_sdwan_vpc_name_vpn512"  		= "core-1b-sd-wan-vpc-vpn512"
        "gce_core_1b_sdwan_vpc_name_vpn0"  			= "core-1b-sd-wan-vpc-vpn0"
        "gce_core_1b_sdwan_vpc_name_vpn10"  		= "core-1b-sd-wan-vpc-vpn10"
        "gce_core_1b_sdwan_r1_subnet_vpn512" 		= "core-1b-r1-subnet-vpn512"
        "gce_core_1b_sdwan_r1_subnet_vpn0" 			= "core-1b-r1-subnet-vpn0"
        "gce_core_1b_sdwan_r1_subnet_vpn10" 		= "core-1b-r1-subnet-vpn10"
        "gce_core_1b_sdwan_vpc_net_cidr_vpn512" 	= "10.103.1.0/24"
        "gce_core_1b_sdwan_vpc_net_cidr_vpn0" 		= "10.103.2.0/24"
        "gce_core_1b_sdwan_vpc_net_cidr_vpn10" 		= "10.103.3.0/24"
        "gce_core_1b_sdwan_r1_ext_ip_name_vpn512" 	= "core-1b-r1-external-ip-vpn512"
        "gce_core_1b_sdwan_r1_ext_ip_name_vpn0" 	= "core-1b-r1-external-ip-vpn0"
    }
}

variable "core_1b_security" {
    type = map
    default = {
      "gce_core_1b_firewall_rule_vpn512" 	= "core-1b-sdwan-r1-firewall-rule-vpn512"
      "gce_core_1b_firewall_rule_vpn0" 		= "core-1b-sdwan-r1-firewall-rule-vpn0"
      "gce_core_1b_firewall_rule_vpn10" 	= "core-1b-sdwan-r1-firewall-rule-vpn10"
    }
}

# Define variable with Router Details:
variable "core_1b_sdwan_router_instance" {
    type = map
    default = {
      "gce_instance_name" 							= "core-1b-sdwan-r1"
# You need 4 vCPU in oder to use 3 and more NICs:
      "gce_router_vm_flavor" 						= "n1-standard-4"
# c8kv GCP images: ({"17.04": "cisco-c8k-17-04-02", "17.05": "cisco-c8k-17-05-01b", "17.06": "cisco-c8k-17-06-04", "17.07": "cisco-c8k-17-07-01b", "17.08": "cisco-c8k-17-08-01b", "17.09": "cisco-c8k-17-09-01b"}) %}
# csr1k image:    "gce_csr_image" 			= "cisco-public/csr1000v1721r-byol"
      "gce_router_image" 							= "cisco-public/cisco-c8k-17-09-01a"
      "gce_ssh_pub_key_file" 						= "gcp-key-20-3-setup.pub"
      "gce_ssh_user" 								= "admin"
      "gce_day0_sdwan_router_core_1b_config_file" 	= "gcp-core-1b-sdwan-r1-cloud-init.user_data"
    }
}



# Define variables for GCP Core 2b:
variable "core_2b_gcp" {
    type = map
    default = {
      "gcp_core_2b" 		= "us-east1"
      "gcp_core_2b_zone" 	= "us-east1-b"
    }
}

# Define variable with Networking Details. Make sure, that your naming matches the following "^(?:[a-z](?:[-a-z0-9]{0,61}[a-z0-9])?)$"
variable "core_2b_networking" {
    type = map
    default = {
        "gce_core_2b_sdwan_vpc_name_vpn512"  		= "core-2b-sd-wan-vpc-vpn512"
        "gce_core_2b_sdwan_vpc_name_vpn0"  			= "core-2b-sd-wan-vpc-vpn0"
        "gce_core_2b_sdwan_vpc_name_vpn10"  		= "core-2b-sd-wan-vpc-vpn10"
        "gce_core_2b_sdwan_r1_subnet_vpn512" 		= "core-2b-r1-subnet-vpn512"
        "gce_core_2b_sdwan_r1_subnet_vpn0" 			= "core-2b-r1-subnet-vpn0"
        "gce_core_2b_sdwan_r1_subnet_vpn10" 		= "core-2b-r1-subnet-vpn10"
        "gce_core_2b_sdwan_vpc_net_cidr_vpn512" 	= "10.104.1.0/24"
        "gce_core_2b_sdwan_vpc_net_cidr_vpn0" 		= "10.104.2.0/24"
        "gce_core_2b_sdwan_vpc_net_cidr_vpn10" 		= "10.104.3.0/24"
        "gce_core_2b_sdwan_r1_ext_ip_name_vpn512" 	= "core-2b-r1-external-ip-vpn512"
        "gce_core_2b_sdwan_r1_ext_ip_name_vpn0" 	= "core-2b-r1-external-ip-vpn0"
    }
}

variable "core_2b_security" {
    type = map
    default = {
      "gce_core_2b_firewall_rule_vpn512" 	= "core-2b-sdwan-r1-firewall-rule-vpn512"
      "gce_core_2b_firewall_rule_vpn0" 		= "core-2b-sdwan-r1-firewall-rule-vpn0"
      "gce_core_2b_firewall_rule_vpn10" 	= "core-2b-sdwan-r1-firewall-rule-vpn10"
    }
}

# Define variable with Router Details:
variable "core_2b_sdwan_router_instance" {
    type = map
    default = {
      "gce_instance_name" 							= "core-2b-sdwan-r1"
# You need 4 vCPU in oder to use 3 and more NICs:
      "gce_router_vm_flavor" 						= "n1-standard-4"
# c8kv GCP images: ({"17.04": "cisco-c8k-17-04-02", "17.05": "cisco-c8k-17-05-02b", "17.06": "cisco-c8k-17-06-04", "17.07": "cisco-c8k-17-07-02b", "17.08": "cisco-c8k-17-08-02b", "17.09": "cisco-c8k-17-09-02b"}) %}
# csr1k image:    "gce_csr_image" 			= "cisco-public/csr1000v1721r-byol"
      "gce_router_image" 							= "cisco-public/cisco-c8k-17-09-01a"
      "gce_ssh_pub_key_file" 						= "gcp-key-20-3-setup.pub"
      "gce_ssh_user" 								= "admin"
      "gce_day0_sdwan_router_core_2b_config_file" 	= "gcp-core-2b-sdwan-r1-cloud-init.user_data"
    }
}



# Define variables for GCP Region 1b:
variable "region_1b_gcp" {
    type = map
    default = {
      "gcp_region_1b" 		= "us-west1"
      "gcp_region_1b_zone" 	= "us-west1-b"
    }
}

# Define variable with Networking Details. Make sure, that your naming matches the following "^(?:[a-z](?:[-a-z0-9]{0,61}[a-z0-9])?)$"
variable "region_1b_networking" {
    type = map
    default = {
        "gce_region_1b_sdwan_vpc_name_vpn512"  		= "region-1b-sd-wan-vpc-vpn512"
        "gce_region_1b_sdwan_vpc_name_vpn0"  		= "region-1b-sd-wan-vpc-vpn0"
        "gce_region_1b_sdwan_vpc_name_vpn10"  		= "region-1b-sd-wan-vpc-vpn10"
        "gce_region_1b_sdwan_r1_subnet_vpn512" 		= "region-1b-r1-subnet-vpn512"
        "gce_region_1b_sdwan_r1_subnet_vpn0" 		= "region-1b-r1-subnet-vpn0"
        "gce_region_1b_sdwan_r1_subnet_vpn10" 		= "region-1b-r1-subnet-vpn10"
        "gce_region_1b_sdwan_vpc_net_cidr_vpn512" 	= "10.21.1.0/24"
        "gce_region_1b_sdwan_vpc_net_cidr_vpn0" 	= "10.21.2.0/24"
        "gce_region_1b_sdwan_vpc_net_cidr_vpn10" 	= "10.21.3.0/24"
        "gce_region_1b_sdwan_r1_ext_ip_name_vpn512" = "region-1b-r1-external-ip-vpn512"
        "gce_region_1b_sdwan_r1_ext_ip_name_vpn0" 	= "region-1b-r1-external-ip-vpn0"
    }
}

variable "region_1b_security" {
    type = map
    default = {
      "gce_region_1b_firewall_rule_vpn512" 	= "region-1b-sdwan-r1-firewall-rule-vpn512"
      "gce_region_1b_firewall_rule_vpn0" 	= "region-1b-sdwan-r1-firewall-rule-vpn0"
      "gce_region_1b_firewall_rule_vpn10" 	= "region-1b-sdwan-r1-firewall-rule-vpn10"
    }
}

# Define variable with Router Details:
variable "region_1b_sdwan_router_instance" {
    type = map
    default = {
      "gce_instance_name" 		= "region-1b-sdwan-r1"
# You need 4 vCPU in oder to use 3 and more NICs:
      "gce_router_vm_flavor" 	= "n1-standard-4"
# c8kv GCP images: ({"17.04": "cisco-c8k-17-04-02", "17.05": "cisco-c8k-17-05-01b", "17.06": "cisco-c8k-17-06-04", "17.07": "cisco-c8k-17-07-01b", "17.08": "cisco-c8k-17-08-01b", "17.09": "cisco-c8k-17-09-01b"}) %}
# csr1k image:    "gce_csr_image" 			= "cisco-public/csr1000v1721r-byol"
      "gce_router_image" 		= "cisco-public/cisco-c8k-17-09-01a"
      "gce_ssh_pub_key_file" 	= "gcp-key-20-3-setup.pub"
      "gce_ssh_user" 			= "admin"
      "gce_day0_sdwan_router_region_1b_config_file" 	= "gcp-region-1b-sdwan-r1-cloud-init.user_data" 
    }
}



# Define variables for GCP Region 2b:
variable "gcp" {
    type = map
    default = {
      "gcp_credential_file" = "gcp-npitaev204eftgc-nprd-59635-88afc9cbd94e.json"
      "gcp_project_id" 		= "gcp-npitaev204eftgc-nprd-59635"
    }
}

# Define variable with GCP Project Details:
variable "region_2b_gcp" {
    type = map
    default = {
      "gcp_region_2b" 		= "us-east1"
      "gcp_region_2b_zone" 	= "us-east1-b"
    }
}

# Define variable with Networking Details. Make sure, that your naming matches the following "^(?:[a-z](?:[-a-z0-9]{0,61}[a-z0-9])?)$"
variable "region_2b_networking" {
    type = map
    default = {
        "gce_region_2b_sdwan_vpc_name_vpn512"  		= "region-2b-sd-wan-vpc-vpn512"
        "gce_region_2b_sdwan_vpc_name_vpn0"  		= "region-2b-sd-wan-vpc-vpn0"
        "gce_region_2b_sdwan_vpc_name_vpn10"  		= "region-2b-sd-wan-vpc-vpn10"
        "gce_region_2b_sdwan_r1_subnet_vpn512" 		= "region-2b-r1-subnet-vpn512"
        "gce_region_2b_sdwan_r1_subnet_vpn0" 		= "region-2b-r1-subnet-vpn0"
        "gce_region_2b_sdwan_r1_subnet_vpn10" 		= "region-2b-r1-subnet-vpn10"
        "gce_region_2b_sdwan_vpc_net_cidr_vpn512" 	= "10.221.1.0/24"
        "gce_region_2b_sdwan_vpc_net_cidr_vpn0" 	= "10.221.2.0/24"
        "gce_region_2b_sdwan_vpc_net_cidr_vpn10" 	= "10.221.3.0/24"
        "gce_region_2b_sdwan_r1_ext_ip_name_vpn512" = "region-2b-r1-external-ip-vpn512"
        "gce_region_2b_sdwan_r1_ext_ip_name_vpn0" 	= "region-2b-r1-external-ip-vpn0"
    }
}

variable "region_2b_security" {
    type = map
    default = {
      "gce_region_2b_firewall_rule_vpn512" 	= "region-2b-sdwan-r1-firewall-rule-vpn512"
      "gce_region_2b_firewall_rule_vpn0" 	= "region-2b-sdwan-r1-firewall-rule-vpn0"
      "gce_region_2b_firewall_rule_vpn10" 	= "region-2b-sdwan-r1-firewall-rule-vpn10"
    }
}

# Define variable with Router Details:
variable "region_2b_sdwan_router_instance" {
    type = map
    default = {
      "gce_instance_name" 		= "region-2b-sdwan-r1"
# You need 4 vCPU in oder to use 3 and more NICs:
      "gce_router_vm_flavor" 	= "n1-standard-4"
# c8kv GCP images: ({"17.04": "cisco-c8k-17-04-02", "17.05": "cisco-c8k-17-05-02b", "17.06": "cisco-c8k-17-06-04", "17.07": "cisco-c8k-17-07-02b", "17.08": "cisco-c8k-17-08-02b", "17.09": "cisco-c8k-17-09-02b"}) %}
# csr1k image:    "gce_csr_image" 			= "cisco-public/csr1000v1721r-byol"
      "gce_router_image" 		= "cisco-public/cisco-c8k-17-09-01a"
      "gce_ssh_pub_key_file" 	= "gcp-key-20-3-setup.pub"
      "gce_ssh_user" 			= "admin"
      "gce_day0_sdwan_router_region_2b_config_file" 	= "gcp-region-2b-sdwan-r1-cloud-init.user_data" 
    }
}





# AWS Variables

# Define Regions and Availability Zones:
variable "aws_core_1a_region" {    
    default = "us-west-2"
}

variable "aws_core_1a_az" {    
    default = "us-west-2a"
}

variable "aws_region_1a_region" {    
    default = "us-west-2"
}

variable "aws_region_1a_az" {    
    default = "us-west-2b"
}

variable "aws_core_2a_region" {    
    default = "us-east-2"
}

variable "aws_core_2a_az" {    
    default = "us-east-2a"
}

variable "aws_region_2a_region" {    
    default = "us-east-2"
}

variable "aws_region_2a_az" {    
    default = "us-east-2b"
}

variable "aws_region_12_vsmart_region" {    
    default = "us-west-2"
}

variable "aws_region_12_vsmart_az" {    
    default = "us-west-2b"
}


# SSH Key File:
variable "aws_key_pair_name" {
  default = "aws-key-20-3-setup"
}


variable "PRIVATE_KEY_PATH" {
  default = "aws-key-20-3-setup.pem"
}

variable "PUBLIC_KEY_PATH" {
  default = "aws-key-20-3-setup.pub"
}

variable "EC2_USER" {
  default = "ubuntu"
}


# IP addresses for the SD-WAN VPC in the Core Region 1a:
variable "aws_core_1a_sdwan_vpc_cidr" {    
    default = "10.101.0.0/16"
}

variable "aws_core_1a_sdwan_vpc_subnet1_cidr" {
    default = "10.101.1.0/24"
}

variable "aws_core_1a_sdwan_r1_nic1_private_ip" {  
    default = "10.101.1.11"
}

variable "aws_core_1a_sdwan_vpc_subnet2_cidr" {
    default = "10.101.2.0/24"
}

variable "aws_core_1a_sdwan_r1_nic2_private_ip" {  
    default = "10.101.2.11"
}

variable "aws_core_1a_sdwan_vpc_subnet3_cidr" {
    default = "10.101.3.0/24"
}

variable "aws_core_1a_sdwan_r1_nic3_private_ip" {  
    default = "10.101.3.11"
}

variable "aws_core_1a_sdwan_vpc_subnet4_cidr" {
    default = "10.101.4.0/24"
}



# IP addresses for the SD-WAN VPC in the Core Region 2a:
variable "aws_core_2a_sdwan_vpc_cidr" {    
    default = "10.102.0.0/16"
}

variable "aws_core_2a_sdwan_vpc_subnet1_cidr" {
    default = "10.102.1.0/24"
}

variable "aws_core_2a_sdwan_r1_nic1_private_ip" {  
    default = "10.102.1.11"
}

variable "aws_core_2a_sdwan_vpc_subnet2_cidr" {
    default = "10.102.2.0/24"
}

variable "aws_core_2a_sdwan_r1_nic2_private_ip" {  
    default = "10.102.2.11"
}

variable "aws_core_2a_sdwan_vpc_subnet3_cidr" {
    default = "10.102.3.0/24"
}

variable "aws_core_2a_sdwan_r1_nic3_private_ip" {  
    default = "10.102.3.11"
}



# IP addresses for the SD-WAN VPC in the Region 1a:
variable "aws_region_1a_sdwan_vpc_cidr" {    
    default = "10.11.0.0/16"
}

variable "aws_region_1a_sdwan_vpc_subnet1_cidr" {
    default = "10.11.1.0/24"
}

variable "aws_region_1a_sdwan_r1_nic1_private_ip" {  
    default = "10.11.1.11"
}

variable "aws_region_1a_sdwan_vpc_subnet2_cidr" {
    default = "10.11.2.0/24"
}

variable "aws_region_1a_sdwan_r1_nic2_private_ip" {  
    default = "10.11.2.11"
}

variable "aws_region_1a_sdwan_vpc_subnet3_cidr" {
    default = "10.11.3.0/24"
}

variable "aws_region_1a_sdwan_r1_nic3_private_ip" {  
    default = "10.11.3.11"
}


# IP addresses for the SD-WAN VPC in the Region 1a:
variable "aws_region_2a_sdwan_vpc_cidr" {    
    default = "10.211.0.0/16"
}

variable "aws_region_2a_sdwan_vpc_subnet1_cidr" {
    default = "10.211.1.0/24"
}

variable "aws_region_2a_sdwan_r1_nic1_private_ip" {  
    default = "10.211.1.11"
}

variable "aws_region_2a_sdwan_vpc_subnet2_cidr" {
    default = "10.211.2.0/24"
}

variable "aws_region_2a_sdwan_r1_nic2_private_ip" {  
    default = "10.211.2.11"
}

variable "aws_region_2a_sdwan_vpc_subnet3_cidr" {
    default = "10.211.3.0/24"
}

variable "aws_region_2a_sdwan_r1_nic3_private_ip" {  
    default = "10.211.3.11"
}




variable "corp_allow_cidr" {           # allow ssh only from Cisco San Jose VPN Cluster
    default = "128.107.0.0/16"
}



# Vars for SD-WAN VPC and SD-WAN routers:
variable "aws_ami_id_sdwan_core_1a_r1" {
  default = "ami-01c8db7f73e2feba9"   # Cisco Catalyst 8000V 17.09.01a in US-West 2. Change for another region!
}

variable "aws_ami_id_sdwan_core_2a_r1" {
  default = "ami-0fd3f119298b886d2"   # Cisco Catalyst 8000V 17.09.01a in US-East 2. Change for another region!
}

variable "aws_ami_id_sdwan_region_1a_r1" {
  default = "ami-01c8db7f73e2feba9"   # Cisco Catalyst 8000V 17.09.01a in US-West 2. Change for another region!
}

variable "aws_ami_id_sdwan_region_2a_r1" {
  default = "ami-0fd3f119298b886d2"   # Cisco Catalyst 8000V 17.09.01a in US-East 2. Change for another region!
}


variable "aws_ami_type_sdwan_r1" {
  default = "c5n.xlarge"
}



# Vars for AWS TGW in Core
variable "aws_tgw_core-1a-asn" {  
    default = "64532"
}

variable "aws_tgw_core-2a-asn" {  
    default = "64533"
}



# Vars for Regional vSmart

variable "aws_region_12_vsmart_vpc_cidr" {    
    default = "10.110.0.0/16"
}

variable "aws_region_12_vsmart_vpc_subnet1_cidr" {  
    default = "10.110.1.0/24"
}

variable "aws_region_12_vsmart_nic1_private_ip" {  
    default = "10.110.1.11"
}

variable "aws_region_12_vsmart_vpc_subnet2_cidr" {
    default = "10.110.2.0/24"
}

variable "aws_region_12_vsmart_nic2_private_ip" {  
    default = "10.110.2.11"
}


variable "aws_ami_id_region_12_vsmart" {
  default = "ami-02b64ace6198a0432"   # 20.9 eng. image, available only in us-west-2. Must be shared by Cisco as private AMI.
}

variable "aws_ami_type_region_12_vsmart" {
  default = "t2.medium"
}
