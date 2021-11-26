# This file will create AWS Infrastructure (VPC, Subnets, IGW, Route Tables, etc) for SD-WAN VPC with two SD-WAN routers

# Create SDWAN VPC:

resource "aws_vpc" "vpc_sdwan" {
  cidr_block			= var.aws_sdwan_vpc_cidr
  provider 				= aws.sdwan
  tags = {
    Name = "${var.bucket_prefix} SDWAN VPC"
  }
}

# Create 3 Subnets for SDWAN VPC in 2 AZs:

resource "aws_subnet" "sdwan_vpc_az1_subnet-1" {
    vpc_id 				= aws_vpc.vpc_sdwan.id
    cidr_block 			= var.aws_sdwan_vpc_az1_subnet-1_cidr
    map_public_ip_on_launch = "true" //it makes this a public subnet
    availability_zone = var.aws_sdwan_az1
    tags = {
        Name = "${var.bucket_prefix} SDWAN AZ1 Subnet-1 Mgmt"
    }
}

resource "aws_subnet" "sdwan_vpc_az1_subnet-2" {
    vpc_id 				= aws_vpc.vpc_sdwan.id
    cidr_block 			= var.aws_sdwan_vpc_az1_subnet-2_cidr
    availability_zone 	= var.aws_sdwan_az1
    tags = {
        Name = "${var.bucket_prefix} SDWAN AZ1 Subnet-2"
    }
}

resource "aws_subnet" "sdwan_vpc_az1_subnet-3" {
    vpc_id 				= aws_vpc.vpc_sdwan.id
    cidr_block 			= var.aws_sdwan_vpc_az1_subnet-3_cidr
    availability_zone 	= var.aws_sdwan_az1
    tags = {
        Name = "${var.bucket_prefix} SDWAN AZ1 Subnet-3"
    }
}


resource "aws_subnet" "sdwan_vpc_az2_subnet-1" {
    vpc_id 				= aws_vpc.vpc_sdwan.id
    cidr_block 			= var.aws_sdwan_vpc_az2_subnet-1_cidr
    map_public_ip_on_launch = "true" //it makes this a public subnet
    availability_zone = var.aws_sdwan_az2
    tags = {
        Name = "${var.bucket_prefix} SDWAN AZ2 Subnet-1 Mgmt"
    }
}

resource "aws_subnet" "sdwan_vpc_az2_subnet-2" {
    vpc_id 				= aws_vpc.vpc_sdwan.id
    cidr_block 			= var.aws_sdwan_vpc_az2_subnet-2_cidr
    availability_zone 	= var.aws_sdwan_az2
    tags = {
        Name = "${var.bucket_prefix} SDWAN AZ2 Subnet-2"
    }
}

resource "aws_subnet" "sdwan_vpc_az2_subnet-3" {
    vpc_id 				= aws_vpc.vpc_sdwan.id
    cidr_block 			= var.aws_sdwan_vpc_az2_subnet-3_cidr
    availability_zone 	= var.aws_sdwan_az2
    tags = {
        Name = "${var.bucket_prefix} SDWAN AZ2 Subnet-3"
    }
}


# Create IGW for Internet Access:

resource "aws_internet_gateway" "sdwan_vpc_igw" {
    vpc_id = aws_vpc.vpc_sdwan.id
    tags = {
        Name = "${var.bucket_prefix} SDWAN VPC IGW"
    }
}


# Create route tables and default route pointing to IGW in VPN512 and VPN0:

resource "aws_route_table" "sdwan_vpc_az1_mgmt_rt" {
    vpc_id = aws_vpc.vpc_sdwan.id
    route {
        //associated subnet can reach everywhere
        cidr_block = "0.0.0.0/0"         //CRT uses this IGW to reach internet
        gateway_id = aws_internet_gateway.sdwan_vpc_igw.id
    }
    tags = {
        Name = "${var.bucket_prefix} SDWAN VPC AZ1 Mgmt RT"
    }
} 

resource "aws_route_table" "sdwan_vpc_az1_rt_vpn0" {
    vpc_id = aws_vpc.vpc_sdwan.id
    route {
        //associated subnet can reach everywhere
        cidr_block = "0.0.0.0/0"         //CRT uses this IGW to reach internet
        gateway_id = aws_internet_gateway.sdwan_vpc_igw.id
    }
    tags = {
        Name = "${var.bucket_prefix} SDWAN VPC AZ1 RT VPN0"
    }
} 

resource "aws_route_table" "sdwan_vpc_az1_rt_vpn10" {
    vpc_id = aws_vpc.vpc_sdwan.id
    tags = {
        Name = "${var.bucket_prefix} SDWAN VPC AZ1 RT Service VPN 10"
    }
} 

resource "aws_route_table" "sdwan_vpc_az2_mgmt_rt" {
    vpc_id = aws_vpc.vpc_sdwan.id
    route {
        //associated subnet can reach everywhere
        cidr_block = "0.0.0.0/0"         //CRT uses this IGW to reach internet
        gateway_id = aws_internet_gateway.sdwan_vpc_igw.id
    }
    tags = {
        Name = "${var.bucket_prefix} SDWAN VPC AZ2 Mgmt RT"
    }
} 

resource "aws_route_table" "sdwan_vpc_az2_rt_vpn0" {
    vpc_id = aws_vpc.vpc_sdwan.id
    route {
        //associated subnet can reach everywhere
        cidr_block = "0.0.0.0/0"         //CRT uses this IGW to reach internet
        gateway_id = aws_internet_gateway.sdwan_vpc_igw.id
    }
    tags = {
        Name = "${var.bucket_prefix} SDWAN VPC AZ2 RT VPN0"
    }
} 

resource "aws_route_table" "sdwan_vpc_az2_rt_vpn10" {
    vpc_id = aws_vpc.vpc_sdwan.id
    tags = {
        Name = "${var.bucket_prefix} SDWAN VPC AZ2 RT Service VPN 10"
    }
} 


# Associate CRT and Subnet for Mgmt and Traffic:

resource "aws_route_table_association" "sdwan_vpc_rta_az1_subnet-1"{
    subnet_id 		= aws_subnet.sdwan_vpc_az1_subnet-1.id
    route_table_id 	= aws_route_table.sdwan_vpc_az1_mgmt_rt.id
}

resource "aws_route_table_association" "sdwan_vpc_rta_az1_subnet-2"{
    subnet_id 		= aws_subnet.sdwan_vpc_az1_subnet-2.id
    route_table_id 	= aws_route_table.sdwan_vpc_az1_rt_vpn0.id
}

resource "aws_route_table_association" "sdwan_vpc_rta_az1_subnet-3"{
    subnet_id 		= aws_subnet.sdwan_vpc_az1_subnet-3.id
    route_table_id 	= aws_route_table.sdwan_vpc_az1_rt_vpn10.id
}

resource "aws_route_table_association" "sdwan_vpc_rta_az2_subnet-1"{
    subnet_id 		= aws_subnet.sdwan_vpc_az2_subnet-1.id
    route_table_id 	= aws_route_table.sdwan_vpc_az2_mgmt_rt.id
}

resource "aws_route_table_association" "sdwan_vpc_rta_az2_subnet-2"{
    subnet_id 		= aws_subnet.sdwan_vpc_az2_subnet-2.id
    route_table_id 	= aws_route_table.sdwan_vpc_az2_rt_vpn0.id
}

resource "aws_route_table_association" "sdwan_vpc_rta_az2_subnet-3"{
    subnet_id 		= aws_subnet.sdwan_vpc_az2_subnet-3.id
    route_table_id 	= aws_route_table.sdwan_vpc_az2_rt_vpn10.id
}

# Create security group:

resource "aws_security_group" "sdwan_vpc_mgmt_sg" {
    vpc_id = aws_vpc.vpc_sdwan.id
    
    egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    }    
    
    ingress {
        from_port = 22           # allow ssh from the CIDR block defined in vars.tf
        to_port = 22
        protocol = "tcp"        
        cidr_blocks = [var.ssh_allow_cidr]
    }   
     
    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = [var.ssh_allow_cidr]
    }       
    
    ingress {
        from_port = 8  #allow ping
        to_port = 0
        protocol = "icmp"
        cidr_blocks = ["10.0.0.0/8"]
    }  
 
     ingress {
        from_port = 830
        to_port = 830
        protocol = "tcp"        
        // SD-WAN TCP Ports
        cidr_blocks = ["0.0.0.0/0"]
    }    
 

    //SD-WAN tcp ports 
    ingress {
        from_port = 23456
        to_port = 24156
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }  

    ingress {
        from_port = 12346  # allow SD-WAN UDP ports
        to_port = 13046
        protocol = "udp"
        cidr_blocks = ["0.0.0.0/0"]
    } 
    
    //IPSec udp ports 
    ingress {
        from_port = 4500
        to_port = 4500
        protocol = "udp"
        cidr_blocks = ["0.0.0.0/0"]
    } 

    ingress {
        from_port = 500
        to_port = 500
        protocol = "udp"
        cidr_blocks = ["0.0.0.0/0"]
    } 

    ingress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        self = "true"
    } 
      
    tags = {
        Name = "${var.bucket_prefix} SDWAN SD-WAN Mgmt SG"
    }
}


resource "aws_security_group" "sdwan_vpc_sg" {
    vpc_id = aws_vpc.vpc_sdwan.id
    
    egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    }    
        
    //If you do not add this rule, you can not reach the web interface
    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = [var.ssh_allow_cidr]
    }    

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"        
        cidr_blocks = [var.ssh_allow_cidr]
    }     

    ingress {
        from_port = 8  #allow ping
        to_port = 0
        protocol = "icmp"
        cidr_blocks = ["10.0.0.0/8"]
    } 

    ingress {
        from_port = 830
        to_port = 830
        protocol = "tcp"        
        // SD-WAN TCP Ports
        cidr_blocks = ["0.0.0.0/0"]
    }    

    //SD-WAN tcp ports 
    ingress {
        from_port = 23456
        to_port = 24156
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }  

    //SD-WAN udp ports 
    ingress {
        from_port = 12346
        to_port = 13046
        protocol = "udp"
        cidr_blocks = ["0.0.0.0/0"]
    } 
    
    //IPSec udp ports 
    ingress {
        from_port = 4500
        to_port = 4500
        protocol = "udp"
        cidr_blocks = ["0.0.0.0/0"]
    } 

    ingress {
        from_port = 500
        to_port = 500
        protocol = "udp"
        cidr_blocks = ["0.0.0.0/0"]
    } 

    //Allow GRE tunnels  
    ingress {
        protocol  = "47"
        from_port = 0
        to_port   = 65535
        cidr_blocks = ["0.0.0.0/0"]
    } 
    
    ingress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        self = "true"
    } 
    
    tags = {
        Name = "${var.bucket_prefix} SDWAN SD-WAN VPC SG"
    }
}


# Create NICs for routers:

resource "aws_network_interface" "sdwan_r1_nic1" {
  subnet_id       	= aws_subnet.sdwan_vpc_az1_subnet-1.id
  private_ips     	= [var.aws_sdwan_r1_nic1_private_ip]
  security_groups 	= [aws_security_group.sdwan_vpc_mgmt_sg.id]
  source_dest_check = false
  description 		= "${var.bucket_prefix} SDWAN R1 NIC1 MGMT"
  tags = {
    Name = "${var.bucket_prefix} SDWAN R1 NIC1 MGMT"
  }
}

resource "aws_network_interface" "sdwan_r1_nic2" {
  subnet_id       	= aws_subnet.sdwan_vpc_az1_subnet-2.id
  private_ips     	= [var.aws_sdwan_r1_nic2_private_ip]
  security_groups 	= [aws_security_group.sdwan_vpc_sg.id]
  source_dest_check = false
  description 		= "${var.bucket_prefix} SDWAN R1 NIC2 VPN0"
  tags = {
    Name  = "${var.bucket_prefix} SDWAN R1 NIC2 VPN0"
  }
}

resource "aws_network_interface" "sdwan_r1_nic3" {
  subnet_id       	= aws_subnet.sdwan_vpc_az1_subnet-3.id
  private_ips     	= [var.aws_sdwan_r1_nic3_private_ip]
  security_groups 	= [aws_security_group.sdwan_vpc_sg.id]
  source_dest_check = false
  description 		= "${var.bucket_prefix} SDWAN R1 NIC3 Service VPN"
  tags = {
    Name = "${var.bucket_prefix} SDWAN R1 NIC3 Service VPN"
  }
}

resource "aws_network_interface" "sdwan_r2_nic1" {
  subnet_id       	= aws_subnet.sdwan_vpc_az2_subnet-1.id
  private_ips     	= [var.aws_sdwan_r2_nic1_private_ip]
  security_groups 	= [aws_security_group.sdwan_vpc_mgmt_sg.id]
  source_dest_check = false
  description 		= "${var.bucket_prefix} SDWAN R2 NIC1 MGMT"
  tags = {
    Name = "${var.bucket_prefix} SDWAN R2 NIC1 MGMT"
  }
}

resource "aws_network_interface" "sdwan_r2_nic2" {
  subnet_id       	= aws_subnet.sdwan_vpc_az2_subnet-2.id
  private_ips     	= [var.aws_sdwan_r2_nic2_private_ip]
  security_groups 	= [aws_security_group.sdwan_vpc_sg.id]
  source_dest_check = false
  description 		= "${var.bucket_prefix} SDWAN R2 NIC2 VPN0"
  tags = {
    Name  = "${var.bucket_prefix} SDWAN R2 NIC2 VPN0"
  }
}

resource "aws_network_interface" "sdwan_r2_nic3" {
  subnet_id       	= aws_subnet.sdwan_vpc_az2_subnet-3.id
  private_ips     	= [var.aws_sdwan_r2_nic3_private_ip]
  security_groups 	= [aws_security_group.sdwan_vpc_sg.id]
  source_dest_check = false
  description 		= "${var.bucket_prefix} SDWAN R2 NIC3 Service VPN"
  tags = {
    Name = "${var.bucket_prefix} SDWAN R2 NIC3 Service VPN"
  }
}


# Create two SD-WAN Routers in the SDWAN VPC:

resource "aws_instance" "sdwan_r1" {
  ami 				= var.aws_ami_id_sdwan_router
  instance_type 	= var.aws_ami_type_sdwan_router
  key_name 			= var.aws_key_pair_name
  availability_zone = var.aws_sdwan_az1
  user_data  		= file("cloud-init-sdwan-r1.user_data")

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.sdwan_r1_nic1.id
    delete_on_termination = false
  }

  network_interface {
    device_index         = 1
    network_interface_id = aws_network_interface.sdwan_r1_nic2.id
    delete_on_termination = false
  }
  
  network_interface {
    device_index         = 2
    network_interface_id = aws_network_interface.sdwan_r1_nic3.id
    delete_on_termination = false
  }

  tags = {
    Name = "${var.bucket_prefix} SDWAN R1"
  }

}


resource "aws_instance" "sdwan_r2" {
  ami 				= var.aws_ami_id_sdwan_router
  instance_type 	= var.aws_ami_type_sdwan_router
  key_name 			= var.aws_key_pair_name
  availability_zone = var.aws_sdwan_az2
  user_data  		= file("cloud-init-sdwan-r2.user_data")

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.sdwan_r2_nic1.id
    delete_on_termination = false
  }

  network_interface {
    device_index         = 1
    network_interface_id = aws_network_interface.sdwan_r2_nic2.id
    delete_on_termination = false
  }
  
  network_interface {
    device_index         = 2
    network_interface_id = aws_network_interface.sdwan_r2_nic3.id
    delete_on_termination = false
  }

  tags = {
    Name = "${var.bucket_prefix} SDWAN R2"
  }

}


# Allocate and assign public IP address to the mgmt interface for the SD-WAN Routers:

resource "aws_eip" "sdwan_r1_nic1_eip_mgmt" {
  vpc                       = true
  network_interface         = aws_network_interface.sdwan_r1_nic1.id
  associate_with_private_ip = var.aws_sdwan_r1_nic1_private_ip
  depends_on 				= [aws_instance.sdwan_r1]
  tags = {
    Name = "${var.bucket_prefix} SDWAN R1 Mgmt EIP"
  }
}

resource "aws_eip" "sdwan_r1_nic1_eip_vpn0" {
  vpc                       = true
  network_interface         = aws_network_interface.sdwan_r1_nic2.id
  associate_with_private_ip = var.aws_sdwan_r1_nic2_private_ip
  depends_on 				= [aws_instance.sdwan_r1]
  tags = {
    Name = "${var.bucket_prefix} SDWAN R1 VPN0 EIP"
  }
}

resource "aws_eip" "sdwan_r2_nic1_eip_mgmt" {
  vpc                       = true
  network_interface         = aws_network_interface.sdwan_r2_nic1.id
  associate_with_private_ip = var.aws_sdwan_r2_nic1_private_ip
  depends_on 				= [aws_instance.sdwan_r2]
  tags = {
    Name = "${var.bucket_prefix} SDWAN R2 Mgmt EIP"
  }
}

resource "aws_eip" "sdwan_r2_nic1_eip_vpn0" {
  vpc                       = true
  network_interface         = aws_network_interface.sdwan_r2_nic2.id
  associate_with_private_ip = var.aws_sdwan_r2_nic2_private_ip
  depends_on 				= [aws_instance.sdwan_r2]
  tags = {
    Name = "${var.bucket_prefix} SDWAN R2 VPN0 EIP"
  }
}


# Please note, that Terraform currently (Nov. 2021) does NOT support TGW Connect (GRE) attachments
# Details: https://github.com/hashicorp/terraform-provider-aws/pull/20780
# Please connect SD-WAN VPC manually as Connect Attachment to TGW, use VPN Attachment instead or use other tools.
# Example for Terraform Repo for VPN attachment: https://github.com/terraform-aws-modules/terraform-aws-vpn-gateway/tree/v2.11.0/examples/complete-vpn-connection-transit-gateway


# Write Management IP of the Host 1 to CLI
output "r1_mgmt_ip" {
  value         = "${aws_instance.sdwan_r1.public_ip}  Re-run 'terraform plan or apply' if you don't see the IP. To connect: ssh -i <aws-key-file> ec2-user@<IP> "
  depends_on 	= [aws_instance.sdwan_r1]
}
output "r2_mgmt_ip" {
  value         = "${aws_instance.sdwan_r2.public_ip} "
  depends_on 	= [aws_instance.sdwan_r2]
}