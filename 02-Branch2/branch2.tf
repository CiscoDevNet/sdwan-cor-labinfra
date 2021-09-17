# This file will create AWS Infrastructure (VPC, Subnets, IGW, Route Tables, etc) for SD-WAN Branch 1 with host and SD-WAN router for the ${var.bucket_prefix} demo

# Create Branch VPC:

resource "aws_vpc" "vpc_branch2" {
  cidr_block			= var.aws_branch2_vpc_cidr
  provider 				= aws.branch2
  tags = {
    Name = "${var.bucket_prefix} Branch2 VPC"
  }
}

# Create Subnets for Transit VPC:

resource "aws_subnet" "branch2_vpc_subnet-1" {
    vpc_id 				= aws_vpc.vpc_branch2.id
    cidr_block 			= var.aws_branch2_vpc_subnet-1_cidr
    map_public_ip_on_launch = "true" //it makes this a public subnet
    availability_zone = var.aws_branch2_az
    tags = {
        Name = "${var.bucket_prefix} Branch2 Subnet-1 Mgmt"
    }
}

resource "aws_subnet" "branch2_vpc_subnet-2" {
    vpc_id 				= aws_vpc.vpc_branch2.id
    cidr_block 			= var.aws_branch2_vpc_subnet-2_cidr
    availability_zone 	= var.aws_branch2_az
    tags = {
        Name = "${var.bucket_prefix} Branch2 Subnet-2"
    }
}

resource "aws_subnet" "branch2_vpc_subnet-3" {
    vpc_id 				= aws_vpc.vpc_branch2.id
    cidr_block 			= var.aws_branch2_vpc_subnet-3_cidr
    availability_zone 	= var.aws_branch2_az
    tags = {
        Name = "${var.bucket_prefix} Branch2 Subnet-3"
    }
}


# Create IGW for Internet Access:

resource "aws_internet_gateway" "branch2_vpc_igw" {
    vpc_id = aws_vpc.vpc_branch2.id
    tags = {
        Name = "${var.bucket_prefix} Branch2 VPC IGW"
    }
}


# Create route tables and default route pointing to IGW in VPN512 and VPN0:

resource "aws_route_table" "branch2_vpc_mgmt_rt" {
    vpc_id = aws_vpc.vpc_branch2.id
    route {
        //associated subnet can reach everywhere
        cidr_block = "0.0.0.0/0"         //CRT uses this IGW to reach internet
        gateway_id = aws_internet_gateway.branch2_vpc_igw.id
    }
    tags = {
        Name = "${var.bucket_prefix} Branch2 VPC Mgmt RT"
    }
} 

resource "aws_route_table" "branch2_vpc_rt_vpn0" {
    vpc_id = aws_vpc.vpc_branch2.id
    route {
        //associated subnet can reach everywhere
        cidr_block = "0.0.0.0/0"         //CRT uses this IGW to reach internet
        gateway_id = aws_internet_gateway.branch2_vpc_igw.id
    }
    tags = {
        Name = "${var.bucket_prefix} Branch2 VPC RT VPN0"
    }
} 

resource "aws_route_table" "branch2_vpc_rt_vpn10" {
    vpc_id = aws_vpc.vpc_branch2.id
    tags = {
        Name = "${var.bucket_prefix} Branch2 VPC RT Service VPN 10"
    }
} 


# Associate CRT and Subnet for Mgmt and Traffic:

resource "aws_route_table_association" "branch2_vpc_rta_subnet-1"{
    subnet_id 		= aws_subnet.branch2_vpc_subnet-1.id
    route_table_id 	= aws_route_table.branch2_vpc_mgmt_rt.id
}

resource "aws_route_table_association" "branch2_vpc_rta_subnet-2"{
    subnet_id 		= aws_subnet.branch2_vpc_subnet-2.id
    route_table_id 	= aws_route_table.branch2_vpc_rt_vpn0.id
}

resource "aws_route_table_association" "branch2_vpc_rta_subnet-3"{
    subnet_id 		= aws_subnet.branch2_vpc_subnet-3.id
    route_table_id 	= aws_route_table.branch2_vpc_rt_vpn10.id
}

# Create security group:

resource "aws_security_group" "branch2_vpc_mgmt_sg" {
    vpc_id = aws_vpc.vpc_branch2.id
    
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

    //Allow all from Branch1 Public IP - IP address must be changed after initial deployment
    ingress {
        from_port = 0
        to_port = 0
        protocol = "-1"  
        cidr_blocks = ["54.111.111.122/32"]
    } 
    
    //Allow all from Branch1 Public IP Linux Host with TE Mgmt - IP address must be changed after initial deployment
    ingress {
        from_port = 0
        to_port = 0
        protocol = "-1"  
        cidr_blocks = ["52.111.111.14/32"]
    } 

    ingress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        self = "true"
    } 
      
    tags = {
        Name = "${var.bucket_prefix} Branch2 SD-WAN Mgmt SG"
    }
}


resource "aws_security_group" "branch2_vpc_sg" {
    vpc_id = aws_vpc.vpc_branch2.id
    
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

    ingress {
        from_port = 8001
        to_port = 8009
        protocol = "tcp"
        // For TE Probing
        cidr_blocks = ["0.0.0.0/0"]
    } 

    ingress {
        from_port = 8001
        to_port = 8009
        protocol = "udp"
        // For TE Probing
        cidr_blocks = ["0.0.0.0/0"]
    }  

    //Allow all from Branch1 Public IP WANEM - IP address must be changed after initial deployment
    ingress {
        from_port = 0
        to_port = 0
        protocol = "-1"  
        cidr_blocks = ["54.111.111.122/32"]
    } 

    //Allow all from Branch1 Public IP Linux Host with TE Mgmt - IP address must be changed after initial deployment
    ingress {
        from_port = 0
        to_port = 0
        protocol = "-1"  
        cidr_blocks = ["52.111.111.14/32"]
    } 
        
    ingress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        self = "true"
    } 
    
    tags = {
        Name = "${var.bucket_prefix} Branch2 SD-WAN VPC SG"
    }
}


# Create NICs:

resource "aws_network_interface" "branch2_r1_nic1" {
  subnet_id       	= aws_subnet.branch2_vpc_subnet-1.id
  private_ips     	= [var.aws_branch2_r1_nic1_private_ip]
  security_groups 	= [aws_security_group.branch2_vpc_mgmt_sg.id]
  source_dest_check = false
  description 		= "${var.bucket_prefix} Branch R1 NIC1 MGMT"
  tags = {
    Name = "${var.bucket_prefix} Branch2 R1 NIC1 MGMT"
  }
}

resource "aws_network_interface" "branch2_r1_nic2" {
  subnet_id       	= aws_subnet.branch2_vpc_subnet-2.id
  private_ips     	= [var.aws_branch2_r1_nic2_private_ip]
  security_groups 	= [aws_security_group.branch2_vpc_sg.id]
  source_dest_check = false
  description 		= "${var.bucket_prefix} Branch2 R1 NIC2 VPN0"
  tags = {
    Name  = "${var.bucket_prefix} Branch2 R1 NIC2 VPN0"
  }
}

resource "aws_network_interface" "branch2_r1_nic3" {
  subnet_id       	= aws_subnet.branch2_vpc_subnet-3.id
  private_ips     	= [var.aws_branch2_r1_nic3_private_ip]
  security_groups 	= [aws_security_group.branch2_vpc_sg.id]
  source_dest_check = false
  description 		= "${var.bucket_prefix} Branch2 R1 NIC3 Service VPN"
  tags = {
    Name = "${var.bucket_prefix} Branch2 R1 NIC3 Service VPN"
  }
}

# Create SD-WAN Router in the Branch:

resource "aws_instance" "branch2_r1" {
  ami 				= var.aws_ami_id_branch2_r1
  instance_type 	= var.aws_ami_type_branch2_r1
  key_name 			= var.aws_key_pair_name
  availability_zone = var.aws_branch2_az
  user_data  		= file("cloud-init-branch2-r1.user_data")

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.branch2_r1_nic1.id
    delete_on_termination = false
  }

  network_interface {
    device_index         = 1
    network_interface_id = aws_network_interface.branch2_r1_nic2.id
    delete_on_termination = false
  }
  
  network_interface {
    device_index         = 2
    network_interface_id = aws_network_interface.branch2_r1_nic3.id
    delete_on_termination = false
  }

  tags = {
    Name = "${var.bucket_prefix} Branch2 SD-WAN R1"
  }

}


# Allocate and assign public IP address to the mgmt interface for the SD-WAN Router R1:

resource "aws_eip" "branch2_r1_nic1_eip_mgmt" {
  vpc                       = true
  network_interface         = aws_network_interface.branch2_r1_nic1.id
  associate_with_private_ip = var.aws_branch2_r1_nic1_private_ip
  depends_on 				= [aws_instance.branch2_r1]
  tags = {
    Name = "${var.bucket_prefix} Branch2 SD-WAN R1 Mgmt EIP"
  }
}

resource "aws_eip" "sdwan_r1_nic1_eip_vpn0" {
  vpc                       = true
  network_interface         = aws_network_interface.branch2_r1_nic2.id
  associate_with_private_ip = var.aws_branch2_r1_nic2_private_ip
  depends_on 				= [aws_instance.branch2_r1]
  tags = {
    Name = "${var.bucket_prefix} Branch2 R1 VPN0 EIP"
  }
}




# Create NICs for the host:

resource "aws_network_interface" "host1_nic1" {
  subnet_id       	= aws_subnet.branch2_vpc_subnet-1.id
  private_ips     	= [var.aws_host1-subnet-1_private_ip]
  security_groups 	= [aws_security_group.branch2_vpc_mgmt_sg.id]
  source_dest_check = false
  description 		= "${var.bucket_prefix} Branch2 Host1 NIC1 MGMT"
  tags = {
    Name = "${var.bucket_prefix} Branch2 Host1 NIC1 MGMT"
  }
}

resource "aws_network_interface" "host1_nic2" {
  subnet_id       	= aws_subnet.branch2_vpc_subnet-3.id
  private_ips     	= [var.aws_host1-subnet-3_private_ip]
  security_groups 	= [aws_security_group.branch2_vpc_sg.id]
  source_dest_check = false
  description 		= "${var.bucket_prefix} Branch2 Host1 NIC2"
  tags = {
    Name = "${var.bucket_prefix} Branch2 Host1 NIC2"
  }
}


# Create Host VM:

resource "aws_instance" "branch2_host1" {
  ami 				= var.aws_ami_id_host1
  instance_type 	= var.aws_ami_type_host1
  key_name 			= var.aws_key_pair_name
  availability_zone =  var.aws_branch2_az

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
    Name = "${var.bucket_prefix} Branch2 Host1"
  }

}


# Allocate and assign public IP address to the mgmt interface for the host

resource "aws_eip" "host1_nic1_eip_mgmt" {
  vpc                       = true
  network_interface         = aws_network_interface.host1_nic1.id
  associate_with_private_ip = var.aws_host1-subnet-1_private_ip
  depends_on 				= [aws_instance.branch2_host1]
  tags = {
    Name = "${var.bucket_prefix} Branch2 Host1 Mgmt EIP"
  }
}
