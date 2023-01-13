# This file will create AWS Infrastructure for SD-WAN MRF Multicloud Core Site 2a like US-East
# The main difference to the 1a is WAN Emulator, which is only present in 1a.

# Create SD-WAN VPC:

resource "aws_vpc" "core_2a_sdwan_vpc" {
  cidr_block 					= var.aws_core_2a_sdwan_vpc_cidr
  provider 						= aws.core_2a
  tags = {
    Name = "${var.bucket_prefix} AWS Core 2a SD-WAN VPC"
  }
}


# Create Subnets for SD-WAN VPC:

resource "aws_subnet" "core_2a_sdwan_vpc_subnet1" {
   provider 					= aws.core_2a
    vpc_id 						= aws_vpc.core_2a_sdwan_vpc.id
    cidr_block 					= var.aws_core_2a_sdwan_vpc_subnet1_cidr
    map_public_ip_on_launch 	= "true" //it makes this a public subnet
    availability_zone 			= var.aws_core_2a_az
    tags = {
        Name = "${var.bucket_prefix} AWS Core 2a SD-WAN Subnet1 Mgmt"
    }
}

resource "aws_subnet" "core_2a_sdwan_vpc_subnet2" {
   provider 					= aws.core_2a
    vpc_id 						= aws_vpc.core_2a_sdwan_vpc.id
    cidr_block 					= var.aws_core_2a_sdwan_vpc_subnet2_cidr
    availability_zone 			= var.aws_core_2a_az
    tags = {
        Name = "${var.bucket_prefix} AWS Core 2a SD-WAN Subnet2"
    }
}

resource "aws_subnet" "core_2a_sdwan_vpc_subnet3" {
    provider 			= aws.core_2a
    vpc_id 				= aws_vpc.core_2a_sdwan_vpc.id
    cidr_block 			= var.aws_core_2a_sdwan_vpc_subnet3_cidr
    availability_zone 	= var.aws_core_2a_az
    tags = {
        Name = "${var.bucket_prefix} AWS Core 2a SD-WAN Subnet3"
    }
}


# Create IGW for Internet Access:

resource "aws_internet_gateway" "core_2a_sdwan_vpc_igw" {
    provider 	= aws.core_2a
    vpc_id		= aws_vpc.core_2a_sdwan_vpc.id
    tags = {
        Name = "${var.bucket_prefix} AWS Core 2a SD-WAN VPC IGW"
    }
}


# Create route tables and default route pointing to IGW in VPN512 and VPN0:

resource "aws_default_route_table" "core_2a_sdwan_vpc_default_rt" {
  provider 					= aws.core_2a
  default_route_table_id 	= aws_vpc.core_2a_sdwan_vpc.default_route_table_id
    route {
        //associated subnet can reach everywhere
        cidr_block 	= "0.0.0.0/0"         //CRT uses this IGW to reach internet
        gateway_id 	= aws_internet_gateway.core_2a_sdwan_vpc_igw.id
    }
  tags = {
    Name = "${var.bucket_prefix} AWS Core 2a SD-WAN VPC Default Route Table"
  }
}


# Create security group:

resource "aws_security_group" "core_2a_sdwan_vpc_sg" {
   provider 	= aws.core_2a
    vpc_id 		= aws_vpc.core_2a_sdwan_vpc.id
    
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
        Name = "${var.bucket_prefix} AWS Core 2a SD-WAN VPC SG"
    }
}


# Create NICs for SD-WAN Router:

resource "aws_network_interface" "core_2a_sdwan_r1_nic1" {
  provider 			= aws.core_2a
  subnet_id       	= aws_subnet.core_2a_sdwan_vpc_subnet1.id
  private_ips     	= [var.aws_core_2a_sdwan_r1_nic1_private_ip]
  security_groups 	= [aws_security_group.core_2a_sdwan_vpc_sg.id]
  source_dest_check = false
  description 		= "${var.bucket_prefix} AWS Core 2a SD-WAN R1 NIC1 MGMT"
  tags = {
    Name = "${var.bucket_prefix} AWS Core 2a SD-WAN R1 NIC1 MGMT"
  }
}

resource "aws_network_interface" "core_2a_sdwan_r1_nic2" {
  provider 			= aws.core_2a
  subnet_id       	= aws_subnet.core_2a_sdwan_vpc_subnet2.id
  private_ips     	= [var.aws_core_2a_sdwan_r1_nic2_private_ip]
  security_groups 	= [aws_security_group.core_2a_sdwan_vpc_sg.id]
  source_dest_check = false
  description 		= "${var.bucket_prefix} AWS Core 2a SD-WAN R1 NIC2 VPN0"
  tags = {
    Name  = "${var.bucket_prefix} AWS Core 2a SD-WAN R1 NIC2 VPN0"
  }
}

resource "aws_network_interface" "core_2a_sdwan_r1_nic3" {
  provider 			= aws.core_2a
  subnet_id       	= aws_subnet.core_2a_sdwan_vpc_subnet3.id
  private_ips     	= [var.aws_core_2a_sdwan_r1_nic3_private_ip]
  security_groups 	= [aws_security_group.core_2a_sdwan_vpc_sg.id]
  source_dest_check = false
  description 		= "${var.bucket_prefix} AWS Core 2a SD-WAN R1 NIC3 CSP Backbone"
  tags = {
    Name = "${var.bucket_prefix} AWS Core 2a SD-WAN R1 NIC3 CSP Backbone"
  }
}


# Create SD-WAN Router in SD-WAN VPC:

resource "aws_instance" "core_2a_sdwan_r1" {
  provider 			= aws.core_2a
  ami 				= var.aws_ami_id_sdwan_core_2a_r1
  instance_type 	= var.aws_ami_type_sdwan_r1
  key_name 			= var.aws_key_pair_name
  availability_zone = var.aws_core_2a_az
  user_data  		= file("aws-core-2a-sdwan-r1-cloud-init.user_data")

  network_interface {
    device_index         	= 0
    network_interface_id 	= aws_network_interface.core_2a_sdwan_r1_nic1.id
    delete_on_termination 	= false
  }

  network_interface {
    device_index         	= 1
    network_interface_id 	= aws_network_interface.core_2a_sdwan_r1_nic2.id
    delete_on_termination 	= false
  }
  
  network_interface {
    device_index         	= 2
    network_interface_id 	= aws_network_interface.core_2a_sdwan_r1_nic3.id
    delete_on_termination 	= false
  }

  tags = {
    Name = "${var.bucket_prefix} AWS Core 2a SD-WAN R1"
  }

}


# Allocate and assign public IP address to the mgmt interface for the SD-WAN Router R1:

resource "aws_eip" "core_2a_sdwan_r1_nic1_eip_mgmt" {
  provider 					= aws.core_2a
  vpc                       = true
  network_interface         = aws_network_interface.core_2a_sdwan_r1_nic1.id
  associate_with_private_ip = var.aws_core_2a_sdwan_r1_nic1_private_ip
  depends_on 				= [aws_instance.core_2a_sdwan_r1]
  tags = {
    Name = "${var.bucket_prefix} AWS Core 2a SD-WAN R1 Mgmt EIP"
  }
}

resource "aws_eip" "core_2a_sdwan_r1_nic1_eip_vpn0" {
  provider 					= aws.core_2a
  vpc                       = true
  network_interface         = aws_network_interface.core_2a_sdwan_r1_nic2.id
  associate_with_private_ip = var.aws_core_2a_sdwan_r1_nic2_private_ip
  depends_on 				= [aws_instance.core_2a_sdwan_r1]
  tags = {
    Name = "${var.bucket_prefix} AWS Core 2a SD-WAN R1 VPN0 EIP"
  }
}


# Create AWS TGW for this region:

resource "aws_ec2_transit_gateway" "core_2a_tgw" {
  provider 							= aws.core_2a
  description                     	= "${var.bucket_prefix} AWS Core 2a TGW"
  amazon_side_asn                 	= var.aws_tgw_core-2a-asn
  default_route_table_association 	= "enable"
  default_route_table_propagation 	= "enable"
  auto_accept_shared_attachments  	= "enable"
  vpn_ecmp_support                	= "enable"
  dns_support                     	= "enable"
  tags =  {
      Name = "${var.bucket_prefix} AWS Core 2a TGW"
    }
}


# Attach SD-WAN VPC as VPC Attachment to TGW:

resource "aws_ec2_transit_gateway_vpc_attachment" "core_2a_tgw_attachment_sdwan_vpc" {
  provider 						= aws.core_2a
  transit_gateway_id 			= aws_ec2_transit_gateway.core_2a_tgw.id
  vpc_id             			= aws_vpc.core_2a_sdwan_vpc.id
  subnet_ids         			= [aws_subnet.core_2a_sdwan_vpc_subnet3.id]
  transit_gateway_default_route_table_association = true
  transit_gateway_default_route_table_propagation = true
  tags = {
      Name = "${var.bucket_prefix} AWS Core 2a VPC Attachment for the SD-WAN VPC"
    }
}


# Create TGW Peering from AWS TGW Core 2a to AWS TGW from Core 1a

data "aws_region" "core_1a_tgw" {
  provider = aws.core_1a
}

resource "aws_ec2_transit_gateway_peering_attachment" "aws_core_tgw_peering" {
  provider 					= aws.core_2a
  peer_account_id         	= aws_ec2_transit_gateway.core_1a_tgw.owner_id
  peer_region             	= data.aws_region.core_1a_tgw.name
  peer_transit_gateway_id 	= aws_ec2_transit_gateway.core_1a_tgw.id
  transit_gateway_id      	= aws_ec2_transit_gateway.core_2a_tgw.id
  tags = {
    Name = "${var.bucket_prefix} TGW Peering Requestor"
  }
} 

# Do not forget to create a static route in the TGW route table for the SD-WAN VPN0 Subnet on the other side!
# After terraform deployment, go to AWS Console, manually select TGW route table and configure static routes using appropriate peering!
#
# The following configuration does not work because it will create VPC ressource type, not peering!
#resource "aws_ec2_transit_gateway_route" "aws_tgw_rt_entry_for_east" {
#  destination_cidr_block         = var.aws_core_2a_sdwan_vpc_subnet1_cidr
#  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.core_1a_tgw_attachment_sdwan_vpc.id
#  transit_gateway_route_table_id = aws_ec2_transit_gateway.core_1a_tgw.association_default_route_table_id
#}


# Printing out public IP addresses of the created SD-WAN router:

output "aws_core_2a_sdwan_r1_mgmt_public_ip" {
  value = aws_eip.core_2a_sdwan_r1_nic1_eip_mgmt.public_ip
}

output "aws_core_2a_sdwan_r1_vpn0_public_ip" {
  value = aws_eip.core_2a_sdwan_r1_nic1_eip_vpn0.public_ip
}