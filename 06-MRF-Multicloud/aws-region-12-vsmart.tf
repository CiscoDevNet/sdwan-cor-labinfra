# This file will create AWS Infrastructure (VPC, Subnets, IGW, Route Tables, etc) for Regional vSmart (Regions 1 and 2)
# Because vSmart AMI is available in US West 2 only, both regional vSmarts will be deployed in AWS US West 2

# Create VPCs:

resource "aws_vpc" "region_12_vsmart_vpc" {
  cidr_block   = var.aws_region_12_vsmart_vpc_cidr
  provider	   = aws.region_12_vsmart  # vSmart AMI available in US West 2 only!
  tags = {
    Name       = "${var.bucket_prefix} Region 2a vSmart VPC"
  }
}


# Create Subnets for Region 2a vSmart:

# Management vpn 512:
resource "aws_subnet" "region_12_vsmart_subnet1" {
    vpc_id                    = aws_vpc.region_12_vsmart_vpc.id
    cidr_block                = var.aws_region_12_vsmart_vpc_subnet1_cidr
    map_public_ip_on_launch   = "true" //it makes this a public subnet
    availability_zone         = var.aws_region_12_vsmart_az
    tags = {
        Name                  = "${var.bucket_prefix} Region 2a vSmart Subnet1 vpn512"
    }
}

# vpn0 for SD-WAN:
resource "aws_subnet" "region_12_vsmart_subnet2" {
    vpc_id                    = aws_vpc.region_12_vsmart_vpc.id
    cidr_block                = var.aws_region_12_vsmart_vpc_subnet2_cidr
    availability_zone         = var.aws_region_12_vsmart_az
    tags = {
        Name                  = "${var.bucket_prefix} Region 2a vSmart Subnet2 vpn0"
    }
}


# Create IGW for Internet Access:

resource "aws_internet_gateway" "region_12_vsmart_igw" {
    vpc_id           = aws_vpc.region_12_vsmart_vpc.id
    tags = {
        Name         = "${var.bucket_prefix} Region 2a vSmart IGW"
    }
}



# Create route tables and default route pointing to IGW in VPN512 and VPN0:

resource "aws_route_table" "region_12_vsmart_vpn512_rt" {
    vpc_id           = aws_vpc.region_12_vsmart_vpc.id
    route {
        //associated subnet can reach everywhere
        cidr_block   = "0.0.0.0/0"
        gateway_id   = aws_internet_gateway.region_12_vsmart_igw.id
    }
    tags = {
        Name         = "${var.bucket_prefix} Region 2a vSmart VPN512 RT"
    }
} 

resource "aws_route_table" "region_12_vsmart_vpn0_rt" {
    vpc_id           = aws_vpc.region_12_vsmart_vpc.id
    route {
        //associated subnet can reach everywhere
        cidr_block   = "0.0.0.0/0"
        gateway_id   = aws_internet_gateway.region_12_vsmart_igw.id
    }
    tags = {
        Name         = "${var.bucket_prefix} Region 2a vSmart  VPN0 RT"
    }
} 



# Associate CRT and Subnet for VPN512 and VPN0:

resource "aws_route_table_association" "region_12_vsmart_rta_subnet1"{
    subnet_id        = aws_subnet.region_12_vsmart_subnet1.id
    route_table_id   = aws_route_table.region_12_vsmart_vpn512_rt.id
}

resource "aws_route_table_association" "region_12_vsmart_rta_subnet2"{
    subnet_id        = aws_subnet.region_12_vsmart_subnet2.id
    route_table_id   = aws_route_table.region_12_vsmart_vpn0_rt.id
}



# Create security group:

resource "aws_security_group" "region_12_vsmart_vpn512-sg" {
    vpc_id          = aws_vpc.region_12_vsmart_vpc.id
    
    egress {
        from_port    = 0
        to_port      = 0
        protocol     = -1
        cidr_blocks  = ["0.0.0.0/0"]
    }    
    
    ingress {
        from_port    = 22
        to_port      = 22
        protocol     = "tcp"        
        // This means, only Cisco San Jose and RTP VPN Cluster addresses are allowed! 
        cidr_blocks  = [var.corp_allow_cidr]
    }   
    
    //If you do not add this rule, you can not reach the vManage Web Interface  
    ingress {
        from_port    = 443
        to_port      = 443
        protocol     = "tcp"
        // This means, only Cisco San Jose and RTP VPN Cluster addresses are allowed! 
        cidr_blocks  = [var.corp_allow_cidr]
    }      
 
     ingress {
        from_port = 8  #allow ping
        to_port = 0
        protocol = "icmp"
        cidr_blocks = ["10.0.0.0/8"]
    }    

    ingress {
        from_port    = 830
        to_port      = 830
        protocol     = "tcp"        
        // SD-WAN TCP Ports
        cidr_blocks  = ["0.0.0.0/0"]
    }    

    //SD-WAN tcp ports 
    ingress {
        from_port    = 23456
        to_port      = 24156
        protocol     = "tcp"
        cidr_blocks  = ["0.0.0.0/0"]
    }  

    //SD-WAN udp ports 
    ingress {
        from_port    = 12346
        to_port      = 13046
        protocol     = "udp"
        cidr_blocks  = ["0.0.0.0/0"]
    } 

# You may need to allow additional IP address like Branch Routers or Controllers IP here

    tags = {
        Name = "${var.bucket_prefix} Region 2a VPN512 SG"
    }
}


resource "aws_security_group" "region_12_vsmart_vpn0-sg" {
    vpc_id = aws_vpc.region_12_vsmart_vpc.id
    
    egress {
        from_port    = 0
        to_port      = 0
        protocol     = -1
        cidr_blocks  = ["0.0.0.0/0"]
    }    
    
    ingress {
        from_port    = 23456
        to_port      = 24156
        protocol     = "tcp"        
        // SD-WAN TCP Ports
        cidr_blocks  = ["0.0.0.0/0"]
    }   

    ingress {
        from_port    = 12346
        to_port      = 13046	
        protocol     = "udp"        
        // SD-WAN TCP Ports
        cidr_blocks  = ["0.0.0.0/0"]
    }  
        
    //If you do not add this rule, you can not reach the vManage UI from vpn0
    ingress {
        from_port    = 443
        to_port      = 443
        protocol     = "tcp"
        cidr_blocks  = [var.corp_allow_cidr]
    }    
 
     ingress {
        from_port    = 22
        to_port      = 22
        protocol     = "tcp"        
        // This means, only Cisco San Jose and RTP VPN Cluster addresses are allowed! 
        cidr_blocks  = [var.corp_allow_cidr]
    }  

    ingress {
        from_port = 8  #allow ping
        to_port = 0
        protocol = "icmp"
        cidr_blocks = ["10.0.0.0/8"]
    } 
           
    ingress {
        from_port    = 830
        to_port      = 830
        protocol     = "tcp"        
        // SD-WAN TCP Ports
        cidr_blocks  = ["0.0.0.0/0"]
    }    
 
# You may need to allow additional IP address like Branch Routers or Controllers IP here


    tags = {
        Name = "${var.bucket_prefix} Region 2a vSmart VPN0 SG"
    }
}



# Create vSmart NICs:

resource "aws_network_interface" "region_12_vsmart_nic1" {
  subnet_id          = aws_subnet.region_12_vsmart_subnet1.id
  private_ips        = [var.aws_region_12_vsmart_nic1_private_ip] 
  security_groups    = [aws_security_group.region_12_vsmart_vpn512-sg.id]
  source_dest_check  = false
  description        = "${var.bucket_prefix} Region 2a vSmart NIC1 VPN512"
  tags  = {
    Name             = "${var.bucket_prefix} Region 2a vSmart NIC1 VPN512"
  }
}

resource "aws_network_interface" "region_12_vsmart_nic2" {
  subnet_id          = aws_subnet.region_12_vsmart_subnet2.id
  private_ips        = [var.aws_region_12_vsmart_nic2_private_ip]
  security_groups    = [aws_security_group.region_12_vsmart_vpn0-sg.id]
  source_dest_check  = false
  description        = "${var.bucket_prefix} Region 2a vSmart NIC2 VPN0"
  tags  = {
    Name             = "${var.bucket_prefix} Region 2a vSmart NIC2 VPN0"
  }
}



# Create vSmart VMs:

resource "aws_instance" "region_12_vsmart" {
  ami                = var.aws_ami_id_region_12_vsmart
  instance_type      = var.aws_ami_type_region_12_vsmart
  key_name           = var.aws_key_pair_name
  availability_zone  =  var.aws_region_12_vsmart_az
  user_data  		= file("aws-region-12-vsmart-cloud-init.user_data")
  # Cisco internal HowTo for controller cloud-init files: 
  # https://techzone.cisco.com/t5/Viptela/Configure-Cloud-Init-Bootstrap-for-SD-WAN-Controllers-Onboarding/ta-p/1739744

  network_interface {
    device_index            = 0
    network_interface_id    = aws_network_interface.region_12_vsmart_nic1.id
    delete_on_termination   = false
  }

  network_interface {
    device_index            = 1
    network_interface_id    = aws_network_interface.region_12_vsmart_nic2.id
    delete_on_termination   = false
  }

  tags = {
    Name = "${var.bucket_prefix} Region 2a vSmart"
  }
}


# Allocate and assign public IP addresses to VPN512 and VPN0 interfaces for Region 2a vSmart

resource "aws_eip" "region_12_vsmart_nic1_eip_vpn512" {
  vpc                       = true
  network_interface         = aws_network_interface.region_12_vsmart_nic1.id
  associate_with_private_ip = var.aws_region_12_vsmart_nic1_private_ip
  tags = {
    Name = "${var.bucket_prefix} Region 2a vSmart vpn512 EIP"
  }
  depends_on  = [ aws_instance.region_12_vsmart ]
}

resource "aws_eip" "region_12_vsmart_nic2_eip_vpn0" {
  vpc                       = true
  network_interface         = aws_network_interface.region_12_vsmart_nic2.id
  associate_with_private_ip = var.aws_region_12_vsmart_nic2_private_ip
  tags = {
    Name = "${var.bucket_prefix} Region 2a vSmart vpn0 EIP"
  }
  depends_on  = [ aws_instance.region_12_vsmart ]
}
