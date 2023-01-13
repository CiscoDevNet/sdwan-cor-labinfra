# This file will create AWS Infrastructure for SD-WAN MRF Multicloud Region 1, Subregion 1 (aka region-1a) like US-West

# Create SD-WAN VPC:

resource "aws_vpc" "region_1a_sdwan_vpc" {
  cidr_block 					= var.aws_region_1a_sdwan_vpc_cidr
  provider 						= aws.region_1a
  tags = {
    Name = "${var.bucket_prefix} AWS Region 1a SD-WAN VPC"
  }
}


# Create Subnets for SD-WAN VPC:

resource "aws_subnet" "region_1a_sdwan_vpc_subnet1" {
    provider 					= aws.region_1a
    vpc_id 						= aws_vpc.region_1a_sdwan_vpc.id
    cidr_block 					= var.aws_region_1a_sdwan_vpc_subnet1_cidr
    map_public_ip_on_launch 	= "true" //it makes this a public subnet
    availability_zone 			= var.aws_region_1a_az
    tags = {
        Name = "${var.bucket_prefix} AWS Region 1a SD-WAN Subnet1 Mgmt"
    }
}

resource "aws_subnet" "region_1a_sdwan_vpc_subnet2" {
    provider 					= aws.region_1a
    vpc_id 						= aws_vpc.region_1a_sdwan_vpc.id
    cidr_block 					= var.aws_region_1a_sdwan_vpc_subnet2_cidr
    availability_zone 			= var.aws_region_1a_az
    tags = {
        Name = "${var.bucket_prefix} AWS Region 1a SD-WAN Subnet2"
    }
}

resource "aws_subnet" "region_1a_sdwan_vpc_subnet3" {
    provider 			= aws.region_1a
    vpc_id 				= aws_vpc.region_1a_sdwan_vpc.id
    cidr_block 			= var.aws_region_1a_sdwan_vpc_subnet3_cidr
    availability_zone 	= var.aws_region_1a_az
    tags = {
        Name = "${var.bucket_prefix} AWS Region 1a SD-WAN Subnet3"
    }
}


# Create IGW for Internet Access:

resource "aws_internet_gateway" "region_1a_sdwan_vpc_igw" {
    provider 	= aws.region_1a
    vpc_id 		= aws_vpc.region_1a_sdwan_vpc.id
    tags = {
        Name = "${var.bucket_prefix} AWS Region 1a SD-WAN VPC IGW"
    }
}


# Create route tables and default route pointing to IGW in VPN512 and VPN0:

resource "aws_default_route_table" "region_1a_sdwan_vpc_default_rt" {
  provider 					= aws.region_1a
  default_route_table_id 	= aws_vpc.region_1a_sdwan_vpc.default_route_table_id
    route {
        //associated subnet can reach everywhere
        cidr_block = "0.0.0.0/0"         //CRT uses this IGW to reach internet
        gateway_id = aws_internet_gateway.region_1a_sdwan_vpc_igw.id
    }
  tags = {
    Name = "${var.bucket_prefix} AWS Region 1a SD-WAN VPC Default Route Table"
  }
}


# Create security group:

resource "aws_security_group" "region_1a_sdwan_vpc_sg" {
    provider 	= aws.region_1a
    vpc_id 		= aws_vpc.region_1a_sdwan_vpc.id
    
    egress {
        from_port 	= 0
        to_port 	= 0
        protocol 	= -1
        cidr_blocks = ["0.0.0.0/0"]
    }    

    ingress {
        from_port 	= 22
        to_port 	= 22
        protocol 	= "tcp"        
        cidr_blocks = [var.corp_allow_cidr]
    } 
        
    //If you do not add this rule, you can not reach the web interface
    ingress {
        from_port 	= 443
        to_port 	= 443
        protocol 	= "tcp"
        cidr_blocks = [var.corp_allow_cidr]
    }    

    ingress {
        from_port 	= 8  #allow ping
        to_port 	= 0
        protocol 	= "icmp"
        cidr_blocks = [var.corp_allow_cidr]
    }   

    ingress {
        from_port 	= 8  #allow ping
        to_port 	= 0
        protocol 	= "icmp"
        cidr_blocks = ["10.0.0.0/8"]
    } 

    ingress {
        from_port 	= 830
        to_port 	= 830
        protocol 	= "tcp"        
        // SD-WAN TCP Ports
        cidr_blocks = ["0.0.0.0/0"]
    }    

    ingress {
        from_port 	= 0
        to_port 	= 0      
        protocol 	= "-1"  
        // SD-WAN vBond Public IP in vpn0
        cidr_blocks = ["44.227.177.103/32"]
    }  
    
    ingress {
        from_port 	= 0
        to_port 	= 0      
        protocol 	= "-1"  
        // SD-WAN vBond Public IP in vpn512
        cidr_blocks = ["52.10.204.24/32"]
    }      

    ingress {
        from_port 	= 0
        to_port 	= 0
        protocol 	= "-1"        
        // SD-WAN vManage Public IP in vpn0
        cidr_blocks = ["44.224.160.247/32"]
    }  
    
    ingress {
        from_port 	= 0
        to_port 	= 0
        protocol 	= "-1"        
        // SD-WAN vManage Public IP in vpn0
        cidr_blocks = ["52.11.122.201/32"]
    }  
    ingress {
        from_port 	= 0
        to_port 	= 0
        protocol 	= "-1"        
        // SD-WAN vSmart Public Elastic IP in vpn0
        cidr_blocks = ["52.39.27.13/32"]
    } 

    ingress {
        from_port 	= 0
        to_port 	= 0
        protocol 	= "-1"        
        // SD-WAN vSmart Public Elastic IP in vpn512
        cidr_blocks = ["44.224.199.89/32"]
    }  

    //SD-WAN tcp ports 
    ingress {
        from_port 	= 23456
        to_port 	= 24156
        protocol 	= "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }  

    //SD-WAN udp ports 
    ingress {
        from_port 	= 12346
        to_port 	= 13046
        protocol 	= "udp"
        cidr_blocks = ["0.0.0.0/0"]
    } 

    //IPSec udp ports 
    ingress {
        from_port 	= 4500
        to_port 	= 4500
        protocol 	= "udp"
        cidr_blocks = ["0.0.0.0/0"]
    } 

    ingress {
        from_port 	= 500
        to_port 	= 500
        protocol 	= "udp"
        cidr_blocks = ["0.0.0.0/0"]
    } 

    ingress {
        from_port 	= 0
        to_port 	= 0
        protocol 	= "-1"        
        // SD-WAN Site2 R1 VPN0 IP
        cidr_blocks = ["13.250.145.89/32"] 
    } 

    ingress {
        from_port 	= 0
        to_port 	= 0
        protocol 	= "-1"        
        // SD-WAN Site1 R1 VPN0 IP
        cidr_blocks = ["44.224.229.221/32"]
    } 
        
    ingress {
        from_port 	= 0
        to_port 	= 0
        protocol 	= "-1"
        self 		= "true"
    } 
       
    tags = {
        Name = "${var.bucket_prefix} AWS Region 1a SD-WAN VPC SG"
    }
}


# Create NICs for SD-WAN Router:

resource "aws_network_interface" "region_1a_sdwan_r1_nic1" {
  provider 			= aws.region_1a
  subnet_id       	= aws_subnet.region_1a_sdwan_vpc_subnet1.id
  private_ips     	= [var.aws_region_1a_sdwan_r1_nic1_private_ip]
  security_groups 	= [aws_security_group.region_1a_sdwan_vpc_sg.id]
  source_dest_check = false
  description 		= "${var.bucket_prefix} AWS Region 1a SD-WAN R1 NIC1 MGMT"
  tags = {
    Name = "${var.bucket_prefix} AWS Region 1a SD-WAN R1 NIC1 MGMT"
  }
}

resource "aws_network_interface" "region_1a_sdwan_r1_nic2" {
  provider 			= aws.region_1a
  subnet_id       	= aws_subnet.region_1a_sdwan_vpc_subnet2.id
  private_ips     	= [var.aws_region_1a_sdwan_r1_nic2_private_ip]
  security_groups 	= [aws_security_group.region_1a_sdwan_vpc_sg.id]
  source_dest_check = false
  description 		= "${var.bucket_prefix} AWS Region 1a SD-WAN R1 NIC2 VPN0"
  tags = {
    Name  = "${var.bucket_prefix} AWS Region 1a SD-WAN R1 NIC2 VPN0"
  }
}

resource "aws_network_interface" "region_1a_sdwan_r1_nic3" {
  provider 			= aws.region_1a
  subnet_id       	= aws_subnet.region_1a_sdwan_vpc_subnet3.id
  private_ips     	= [var.aws_region_1a_sdwan_r1_nic3_private_ip]
  security_groups 	= [aws_security_group.region_1a_sdwan_vpc_sg.id]
  source_dest_check = false
  description 		= "${var.bucket_prefix} AWS Region 1a SD-WAN R1 NIC3 Service VPN"
  tags = {
    Name = "${var.bucket_prefix} AWS Region 1a SD-WAN R1 NIC3 Service VPN"
  }
}


# Create SD-WAN Router in SD-WAN VPC:

resource "aws_instance" "region_1a_sdwan_r1" {
  provider 			= aws.region_1a
  ami 				= var.aws_ami_id_sdwan_region_1a_r1
  instance_type 	= var.aws_ami_type_sdwan_r1
  key_name 			= var.aws_key_pair_name
  availability_zone = var.aws_region_1a_az
  user_data  		= file("aws-region-1a-sdwan-r1-cloud-init.user_data")

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.region_1a_sdwan_r1_nic1.id
    delete_on_termination = false
  }

  network_interface {
    device_index         = 1
    network_interface_id = aws_network_interface.region_1a_sdwan_r1_nic2.id
    delete_on_termination = false
  }
  
  network_interface {
    device_index         = 2
    network_interface_id = aws_network_interface.region_1a_sdwan_r1_nic3.id
    delete_on_termination = false
  }

  tags = {
    Name = "${var.bucket_prefix} AWS Region 1a SD-WAN R1"
  }

}


# Allocate and assign public IP address to the mgmt interface for the SD-WAN Router R1:

resource "aws_eip" "region_1a_sdwan_r1_nic1_eip_mgmt" {
  provider 					= aws.region_1a
  vpc                       = true
  network_interface         = aws_network_interface.region_1a_sdwan_r1_nic1.id
  associate_with_private_ip = var.aws_region_1a_sdwan_r1_nic1_private_ip
  depends_on 				= [aws_instance.region_1a_sdwan_r1]
  tags = {
    Name = "${var.bucket_prefix} AWS Region 1a SD-WAN R1 Mgmt EIP"
  }
}

resource "aws_eip" "region_1a_sdwan_r1_nic1_eip_vpn0" {
  provider 					= aws.region_1a
  vpc                       = true
  network_interface         = aws_network_interface.region_1a_sdwan_r1_nic2.id
  associate_with_private_ip = var.aws_region_1a_sdwan_r1_nic2_private_ip
  depends_on 				= [aws_instance.region_1a_sdwan_r1]
  tags = {
    Name = "${var.bucket_prefix} AWS Region 1a SD-WAN R1 VPN0 EIP"
  }
}



# Printing out public IP addresses of the created SD-WAN router:

output "aws_region_1a_sdwan_r1_mgmt_public_ip" {
  value = aws_eip.region_1a_sdwan_r1_nic1_eip_mgmt.public_ip
}

output "aws_region_1a_sdwan_r1_vpn0_public_ip" {
  value = aws_eip.region_1a_sdwan_r1_nic1_eip_vpn0.public_ip
}


