# This file will create AWS Infrastructure (VPC, Subnets, IGW, Route Tables, etc) for SD-WAN Branch 1 with host, 1 WAN Emulator Linux and SD-WAN router

# Create Branch VPC:

resource "aws_vpc" "vpc_branch1" {
  cidr_block			= var.aws_branch1_vpc_cidr
  provider 				= aws.branch1
  tags = {
    Name = "${var.bucket_prefix} Branch1 VPC"
  }
}

# Create Subnets for Branch VPC:

resource "aws_subnet" "branch1_vpc_subnet1" {
    vpc_id 				= aws_vpc.vpc_branch1.id
    cidr_block 			= var.aws_branch1_vpc_subnet1_cidr
    map_public_ip_on_launch = "true" //it makes this a public subnet
    availability_zone = var.aws_branch1_az
    tags = {
        Name = "${var.bucket_prefix} Branch1 Subnet-1 Mgmt"
    }
}

resource "aws_subnet" "branch1_vpc_subnet2" {
    vpc_id 				= aws_vpc.vpc_branch1.id
    cidr_block 			= var.aws_branch1_vpc_subnet2_cidr
    availability_zone 	= var.aws_branch1_az
    tags = {
        Name = "${var.bucket_prefix} Branch1 Subnet-2 VPN0"
    }
}

resource "aws_subnet" "branch1_vpc_subnet3" {
    vpc_id 				= aws_vpc.vpc_branch1.id
    cidr_block 			= var.aws_branch1_vpc_subnet3_cidr
    availability_zone 	= var.aws_branch1_az
    tags = {
        Name = "${var.bucket_prefix} Branch1 Subnet-3 VPN10"
    }
}

resource "aws_subnet" "branch1_vpc_subnet4" {
    vpc_id 				= aws_vpc.vpc_branch1.id
    cidr_block 			= var.aws_branch1_vpc_subnet4_cidr
    availability_zone 	= var.aws_branch1_az
    tags = {
        Name = "${var.bucket_prefix} Branch1 Subnet-3 WANEM"
    }
}

# Create IGW for Internet Access:

resource "aws_internet_gateway" "branch1_vpc_igw" {
    vpc_id = aws_vpc.vpc_branch1.id
    tags = {
        Name = "${var.bucket_prefix} Branch1 VPC IGW"
    }
}


# Create route tables and default route pointing to IGW in MGMT and Inet networks:

resource "aws_route_table" "branch1_vpc_mgmt_rt" {
    vpc_id = aws_vpc.vpc_branch1.id
    route {
        //associated subnet can reach everywhere
        cidr_block = "0.0.0.0/0"         //CRT uses this IGW to reach internet
        gateway_id = aws_internet_gateway.branch1_vpc_igw.id
    }
    tags = {
        Name = "${var.bucket_prefix} Branch1 VPC Mgmt RT"
    }
} 

resource "aws_route_table" "branch1_vpc_rt_wanem" {
    vpc_id = aws_vpc.vpc_branch1.id
    route {
        cidr_block = "0.0.0.0/0"         //CRT uses this IGW to reach internet
        gateway_id = aws_internet_gateway.branch1_vpc_igw.id
    }
    tags = {
        Name = "${var.bucket_prefix} Branch1 VPC RT WANEM"
    }
} 


# Associate CRT and Subnet for Mgmt and Traffic:

resource "aws_route_table_association" "branch1_vpc_rta_subnet-1"{
    subnet_id 		= aws_subnet.branch1_vpc_subnet1.id
    route_table_id 	= aws_route_table.branch1_vpc_mgmt_rt.id
}

resource "aws_route_table_association" "branch1_vpc_rta_subnet-2"{
    subnet_id 		= aws_subnet.branch1_vpc_subnet2.id
    route_table_id 	= aws_route_table.branch1_vpc_rt_vpn0.id
}

resource "aws_route_table_association" "branch1_vpc_rta_subnet-3"{
    subnet_id 		= aws_subnet.branch1_vpc_subnet3.id
    route_table_id 	= aws_route_table.branch1_vpc_rt_vpn10.id
}

resource "aws_route_table_association" "branch1_vpc_rta_subnet-4"{
    subnet_id 		= aws_subnet.branch1_vpc_subnet4.id
    route_table_id 	= aws_route_table.branch1_vpc_rt_wanem.id
}


# Create security group:

resource "aws_security_group" "branch1_vpc_mgmt_sg" {
    vpc_id = aws_vpc.vpc_branch1.id
    
    egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    }    
      
    ingress {
        from_port = 22    # allow ssh from the CIDR block defined in vars.tf
        to_port = 22
        protocol = "tcp"        
        cidr_blocks = [var.ssh_allow_cidr]
    }   
    
    ingress {
        from_port = 443   # allow https access from the CIDR block defined in vars.tf
        to_port = 443
        protocol = "tcp"
        cidr_blocks = [var.ssh_allow_cidr]
    }    

    ingress {
        from_port = 8     # allow ping
        to_port = 0
        protocol = "icmp"
        cidr_blocks = [var.ssh_allow_cidr]
    }           
 
     ingress {
        from_port = 830    # allow Netconf
        to_port = 830
        protocol = "tcp"        
        // SD-WAN TCP Ports
        cidr_blocks = ["0.0.0.0/0"]
    }    

    ingress {
        from_port = 0     # allow all traffic between all branches using private IPs
        to_port = 0      
        protocol = "-1"  
        cidr_blocks = ["10.0.0.0/8"]
    } 

    ingress {
        from_port = 23456  # allow SD-WAN TCP ports
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

    ingress {
        from_port = 4500  # allow IKE-based IPSec ports
        to_port = 4500
        protocol = "udp"
        cidr_blocks = ["0.0.0.0/0"]
    } 

    ingress {
        from_port = 500  # allow IKE-based IPSec ports
        to_port = 500
        protocol = "udp"
        cidr_blocks = ["0.0.0.0/0"]
    } 

    ingress {
        from_port = 0
        to_port = 0
        protocol = "-1"        
        cidr_blocks = ["54.112.112.125/32"]   # SD-WAN Branch2 R1 Public IP - needs to be adjusted after initial deployment
    } 

    ingress {
        from_port = 0
        to_port = 0
        protocol = "-1"        
        cidr_blocks = ["54.112.112.174/32"]   # SD-WAN Branch2 Linux Host with TE Mgmt - needs to be adjusted after initial deployment
    }
    
    ingress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        self = "true"
    }     
    
    tags = {
        Name = "${var.bucket_prefix} Branch1 SD-WAN Mgmt SG"
    }
}


resource "aws_security_group" "branch1_vpc_sg" {
    vpc_id = aws_vpc.vpc_branch1.id
    
    egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    }    
        
    ingress {
        from_port = 443  # allow https from the CIDR block defined in vars.tf
        to_port = 443
        protocol = "tcp"
        cidr_blocks = [var.ssh_allow_cidr]
    }    

    ingress {
        from_port = 22   # allow ssh from the CIDR block defined in vars.tf
        to_port = 22
        protocol = "tcp"        
        cidr_blocks = [var.ssh_allow_cidr]
    }   

    ingress {
        from_port = 8    # allow ping from the CIDR block defined in vars.tf
        to_port = 0
        protocol = "icmp"
        cidr_blocks = [var.ssh_allow_cidr]
    }   

    ingress {
        from_port = 0
        to_port = 0      
        protocol = "-1"  
        cidr_blocks = ["10.0.0.0/8"]
    } 

    ingress {
        from_port = 830  # allow Netconf
        to_port = 830
        protocol = "tcp"        
        cidr_blocks = ["0.0.0.0/0"]
    }    

    ingress {
        from_port = 23456   # allow SD-WAN TCP Ports
        to_port = 24156
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }  

    ingress {
        from_port = 12346   # allow SD-WAN UDP Ports
        to_port = 13046
        protocol = "udp"
        cidr_blocks = ["0.0.0.0/0"]
    } 

    //IPSec udp ports 
    ingress {
        from_port = 4500   # allow IKE-based IPSec
        to_port = 4500
        protocol = "udp"
        cidr_blocks = ["0.0.0.0/0"]
    } 

    ingress {
        from_port = 500    # allow IKE-based IPSec
        to_port = 500
        protocol = "udp"
        cidr_blocks = ["0.0.0.0/0"]
    } 

    ingress {
        from_port = 8001   # allow TCP ports 8001-8009n for app probing / monitoring
        to_port = 8009
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    } 

    ingress {
        from_port = 0
        to_port = 0
        protocol = "-1"        
        cidr_blocks = ["54.112.112.125/32"]  # SD-WAN Branch2 R1 Public IP - needs to be adjusted after initial deployment
    } 

    ingress {
        from_port = 0
        to_port = 0
        protocol = "-1"        
        cidr_blocks = ["54.112.112.174/32"]  # SD-WAN Branch2 Linux Host with TE Mgmt - needs to be adjusted after initial deployment
    }

    ingress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        self = "true"
    } 
        
    tags = {
        Name = "${var.bucket_prefix} Branch1 SD-WAN VPC SG"
    }
}


# Create NICs:

resource "aws_network_interface" "branch1_r1_nic1" {
  subnet_id       	= aws_subnet.branch1_vpc_subnet1.id
  private_ips     	= [var.aws_branch1_r1_nic1_private_ip]
  security_groups 	= [aws_security_group.branch1_vpc_mgmt_sg.id]
  source_dest_check = false
  description 		= "${var.bucket_prefix} Branch R1 NIC1 MGMT"
  tags = {
    Name = "${var.bucket_prefix} Branch1 R1 NIC1 MGMT"
  }
}

resource "aws_network_interface" "branch1_r1_nic2" {
  subnet_id       	= aws_subnet.branch1_vpc_subnet2.id
  private_ips     	= [var.aws_branch1_r1_nic2_private_ip]
  security_groups 	= [aws_security_group.branch1_vpc_sg.id]
  source_dest_check = false
  description 		= "${var.bucket_prefix} Branch1 R1 NIC2 VPN0"
  tags = {
    Name  = "${var.bucket_prefix} Branch1 R1 NIC2 VPN0"
  }
}

resource "aws_network_interface" "branch1_r1_nic3" {
  subnet_id       	= aws_subnet.branch1_vpc_subnet3.id
  private_ips     	= [var.aws_branch1_r1_nic3_private_ip]
  security_groups 	= [aws_security_group.branch1_vpc_sg.id]
  source_dest_check = false
  description 		= "${var.bucket_prefix} Branch1 R1 NIC3 Service VPN"
  tags = {
    Name = "${var.bucket_prefix} Branch1 R1 NIC3 Service VPN"
  }
}


# Create SD-WAN Router in the Branch:

resource "aws_instance" "branch1_r1" {
  ami 				= var.aws_ami_id_branch1_r1
  instance_type 	= var.aws_ami_type_branch1_r1
  key_name 			= var.aws_key_pair_name
  availability_zone = var.aws_branch1_az
  user_data  		= file("cloud-init-branch1-r1.user_data")

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.branch1_r1_nic1.id
    delete_on_termination = false
  }

  network_interface {
    device_index         = 1
    network_interface_id = aws_network_interface.branch1_r1_nic2.id
    delete_on_termination = false
  }
  
  network_interface {
    device_index         = 2
    network_interface_id = aws_network_interface.branch1_r1_nic3.id
    delete_on_termination = false
  }

  tags = {
    Name = "${var.bucket_prefix} Branch1 SD-WAN R1"
  }

}


# Allocate and assign public IP address to the mgmt interface for the SD-WAN Router R1:

resource "aws_eip" "branch1_r1_nic1_eip_mgmt" {
  vpc                       = true
  network_interface         = aws_network_interface.branch1_r1_nic1.id
  associate_with_private_ip = var.aws_branch1_r1_nic1_private_ip
  depends_on 				= [aws_instance.branch1_r1]
  tags = {
    Name = "${var.bucket_prefix} Branch1 SD-WAN R1 Mgmt EIP"
  }
}

resource "aws_eip" "sdwan_r1_nic1_eip_vpn0" {
  vpc                       = true
  network_interface         = aws_network_interface.branch1_r1_nic2.id
  associate_with_private_ip = var.aws_branch1_r1_nic2_private_ip
  depends_on 				= [aws_instance.branch1_r1]
  tags = {
    Name = "${var.bucket_prefix} Branch1 R1 VPN0 EIP"
  }
}



# Create NICs for the host:

resource "aws_network_interface" "host1_nic1" {
  subnet_id       	= aws_subnet.branch1_vpc_subnet1.id
  private_ips     	= [var.aws_host1-subnet1_private_ip]
  security_groups 	= [aws_security_group.branch1_vpc_mgmt_sg.id]
  source_dest_check = false
  description 		= "${var.bucket_prefix} Branch1 Host1 NIC1 MGMT"
  tags = {
    Name = "${var.bucket_prefix} Branch1 Host1 NIC1 MGMT"
  }
}

resource "aws_network_interface" "host1_nic2" {
  subnet_id       	= aws_subnet.branch1_vpc_subnet3.id
  private_ips     	= [var.aws_host1-subnet3_private_ip]
  security_groups 	= [aws_security_group.branch1_vpc_sg.id]
  source_dest_check = false
  description 		= "${var.bucket_prefix} Branch1 Host1 NIC2"
  tags = {
    Name = "${var.bucket_prefix} Branch1 Host1 NIC2"
  }
}


# Create NICs for Linux Public Internet WAN Emulator:

resource "aws_network_interface" "branch1_wanem_nic1" {
  subnet_id       	= aws_subnet.branch1_vpc_subnet1.id
  private_ips     	= [var.aws_branch1_wanem_nic1_private_ip]
  security_groups 	= [aws_security_group.branch1_vpc_sg.id]
  source_dest_check = false
  description 		= "${var.bucket_prefix} Branch1 WANEM Linux NIC1 MGMT"
  tags = {
    Name = "${var.bucket_prefix} Branch1 WANEM Linux NIC1 MGMT"
  }
}

resource "aws_network_interface" "branch1_wanem_nic2" {
  subnet_id       	= aws_subnet.branch1_vpc_subnet2.id
  private_ips     	= [var.aws_branch1_wanem_nic2_private_ip]
  security_groups 	= [aws_security_group.branch1_vpc_sg.id]
  source_dest_check = false
  description 		= "${var.bucket_prefix} Branch1 WANEM Linux NIC2 VPN0"
  tags = {
    Name  = "${var.bucket_prefix} Branch1 WANEM Linux NIC2 VPN0"
  }
}

resource "aws_network_interface" "branch1_wanem_nic3" {
  subnet_id       	= aws_subnet.branch1_vpc_subnet4.id
  private_ips     	= [var.aws_branch1_wanem_nic3_private_ip]
  security_groups 	= [aws_security_group.branch1_vpc_sg.id]
  source_dest_check = false
  description 		= "${var.bucket_prefix} Branch1 WANEM NIC3 out to Internet"
  tags = {
    Name = "${var.bucket_prefix} Branch1 WANEM NIC3 out to Internet"
  }
}


resource "aws_route_table" "branch1_vpc_rt_vpn0" {
    vpc_id = aws_vpc.vpc_branch1.id
    route {
        cidr_block = "0.0.0.0/0"         
        network_interface_id = aws_network_interface.branch1_wanem_nic2.id  //NIC of the WANEM
    }
    tags = {
        Name = "${var.bucket_prefix} Branch1 VPC RT VPN0"
    }
} 

resource "aws_route_table" "branch1_vpc_rt_vpn10" {
    vpc_id = aws_vpc.vpc_branch1.id
    route {
        cidr_block = "0.0.0.0/0"         //CRT uses SD-WAN router to reach internet
        network_interface_id = aws_network_interface.branch1_r1_nic3.id
    }    
    tags = {
        Name = "${var.bucket_prefix} Branch1 VPC RT Service VPN 10"
    }
} 


# Create Host VM:

resource "aws_instance" "branch1_host1" {
  ami 				= var.aws_ami_id_host1
  instance_type 	= var.aws_ami_type_host1
  key_name 			= var.aws_key_pair_name
  availability_zone =  var.aws_branch1_az

  network_interface {
    device_index         	= 0
    network_interface_id 	= aws_network_interface.host1_nic1.id
    delete_on_termination 	= false
  }

  network_interface {
    device_index         	= 1
    network_interface_id 	= aws_network_interface.host1_nic2.id
    delete_on_termination 	= false
  }

  tags = {
    Name = "${var.bucket_prefix} Branch1 Host1"
  }

}


# Create Linux WAN Emulator in Branch1 VPC:

resource "aws_instance" "branch1_sdwan_wanem" {
  ami 				= var.aws_ami_id_host1
  instance_type 	= var.aws_ami_type_host1
  key_name 			= var.aws_key_pair_name
  availability_zone = var.aws_branch1_az

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.branch1_wanem_nic1.id
    delete_on_termination = false
  }

  network_interface {
    device_index         = 1
    network_interface_id = aws_network_interface.branch1_wanem_nic2.id
    delete_on_termination = false
  }
  
  network_interface {
    device_index         = 2
    network_interface_id = aws_network_interface.branch1_wanem_nic3.id
    delete_on_termination = false
  }

  tags = {
    Name = "${var.bucket_prefix} Branch1 WANEM Linux"
  }

}

# Allocate and assign public IP address to the mgmt interface for the host

resource "aws_eip" "host1_nic1_eip_mgmt" {
  vpc                       = true
  network_interface         = aws_network_interface.host1_nic1.id
  associate_with_private_ip = var.aws_host1-subnet1_private_ip
  depends_on 				= [aws_instance.branch1_host1]
  tags = {
    Name = "${var.bucket_prefix} Branch1 Host1 Mgmt EIP"
  }
}


# Allocate and assign public IP address to the mgmt interface for the WANEM Linux:

resource "aws_eip" "branch1_sdwan_wanem_nic1_eip_mgmt" {
  vpc                       = true
  network_interface         = aws_network_interface.branch1_wanem_nic1.id
  associate_with_private_ip = var.aws_branch1_wanem_nic1_private_ip
  depends_on 				= [aws_instance.branch1_sdwan_wanem]
  tags = {
    Name = "${var.bucket_prefix} Branch1 WANEM Mgmt EIP"
  }
}

resource "aws_eip" "branch1_sdwan_wanem_nic1_eip_inet" {
  vpc                       = true
  network_interface         = aws_network_interface.branch1_wanem_nic3.id
  associate_with_private_ip = var.aws_branch1_wanem_nic3_private_ip
  depends_on 				= [aws_instance.branch1_sdwan_wanem]
  tags = {
    Name = "${var.bucket_prefix} Branch1 WANEM Inet EIP"
  }
}
