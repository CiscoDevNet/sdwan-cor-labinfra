# This file will create AWS Infrastructure (VPC, Subnets, IGW, Route Tables, etc) for SD-WAN controllers (vBond, vSmart, vManage)
# Please note, that controller images are not generally available on Marketplace. 
# In very special cases images can be shared with customers. You need to ask your Cisco account team for details.
# In such cases customers are fully responsible for controller operations because this is NOT currently Cisco-supported modus operandi.
# After initial install vManage will format data partition upon first login and reboot.

# Create VPCs:

resource "aws_vpc" "vpc_controllers" {
  cidr_block   = var.aws_controllers_vpc_cidr
  provider	   = aws.controllers
  tags = {
    Name       = "${var.bucket_prefix} SD-WAN-Controllers-VPC"
  }
}



# Create Subnets for Controllers:

# Management vpn 512:
resource "aws_subnet" "controllers_subnet-1" {
    vpc_id                    = aws_vpc.vpc_controllers.id
    cidr_block                = var.aws_controllers_subnet-1_cidr
    map_public_ip_on_launch   = "true" //it makes this a public subnet
    availability_zone         = var.aws_controllers_az
    tags = {
        Name                  = "${var.bucket_prefix} SD-WAN-Controllers-Subnet-1-vpn512"
    }
}

# vpn0 for SD-WAN:
resource "aws_subnet" "controllers_subnet-2" {
    vpc_id                    = aws_vpc.vpc_controllers.id
    cidr_block                = var.aws_controllers_subnet-2_cidr
    availability_zone         = var.aws_controllers_az
    tags = {
        Name                  = "${var.bucket_prefix} SD-WAN-Controllers-Subnet-2-vpn0"
    }
}


# Create IGW for Internet Access:

resource "aws_internet_gateway" "controllers_igw" {
    vpc_id           = aws_vpc.vpc_controllers.id
    tags = {
        Name         = "${var.bucket_prefix} Controllers-igw"
    }
}



# Create route tables and default route pointing to IGW in VPN512 and VPN0:

resource "aws_route_table" "controllers_vpn512_rt" {
    vpc_id           = aws_vpc.vpc_controllers.id
    route {
        //associated subnet can reach everywhere
        cidr_block   = "0.0.0.0/0"
        gateway_id   = aws_internet_gateway.controllers_igw.id
    }
    tags = {
        Name         = "${var.bucket_prefix} Controllers-VPN512-rt"
    }
} 

resource "aws_route_table" "controllers_vpn0_rt" {
    vpc_id           = aws_vpc.vpc_controllers.id
    route {
        //associated subnet can reach everywhere
        cidr_block   = "0.0.0.0/0"
        gateway_id   = aws_internet_gateway.controllers_igw.id
    }
    tags = {
        Name         = "${var.bucket_prefix} Controllers-VPN0-rt"
    }
} 



# Associate CRT and Subnet for VPN512 and VPN0:

resource "aws_route_table_association" "controllers_rta_subnet-1"{
    subnet_id        = aws_subnet.controllers_subnet-1.id
    route_table_id   = aws_route_table.controllers_vpn512_rt.id
}

resource "aws_route_table_association" "controllers_rta_subnet-2"{
    subnet_id        = aws_subnet.controllers_subnet-2.id
    route_table_id   = aws_route_table.controllers_vpn0_rt.id
}



# Create security group:

resource "aws_security_group" "controllers_vpn512-sg" {
    vpc_id          = aws_vpc.vpc_controllers.id
    
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
        cidr_blocks  = [var.ssh_allow_cidr]
    }   
    
    //If you do not add this rule, you can not reach the vManage Web Interface  
    ingress {
        from_port    = 443
        to_port      = 443
        protocol     = "tcp"
        // This means, only Cisco San Jose and RTP VPN Cluster addresses are allowed! 
        cidr_blocks  = [var.https_allow_cidr]
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
        Name = "${var.bucket_prefix} Controllers-VPN512-SG"
    }
}


resource "aws_security_group" "controllers_vpn0-sg" {
    vpc_id = aws_vpc.vpc_controllers.id
    
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
        cidr_blocks  = [var.https_allow_cidr]
    }    
 
     ingress {
        from_port    = 22
        to_port      = 22
        protocol     = "tcp"        
        // This means, only Cisco San Jose and RTP VPN Cluster addresses are allowed! 
        cidr_blocks  = [var.ssh_allow_cidr]
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
        Name = "${var.bucket_prefix} Controllers-VPN0-SG"
    }
}



# Create NICs:

resource "aws_network_interface" "vmanage_nic1" {
  subnet_id          = aws_subnet.controllers_subnet-1.id
  private_ips        = [var.aws_vmanage-subnet-1_private_ip]
  security_groups    = [aws_security_group.controllers_vpn512-sg.id]
  source_dest_check  = false
  description = "${var.bucket_prefix} vManage-NIC1-VPN512"
  tags  = {
    Name             = "${var.bucket_prefix} vManage-NIC1-VPN512"
  }
}

resource "aws_network_interface" "vmanage_nic2" {
  subnet_id          = aws_subnet.controllers_subnet-2.id
  private_ips        = [var.aws_vmanage-subnet-2_private_ip]
  security_groups    = [aws_security_group.controllers_vpn0-sg.id]
  source_dest_check  = false
  description = "${var.bucket_prefix} vManage-NIC2-VPN0"
  tags  = {
    Name             = "${var.bucket_prefix} vManage-NIC2-VPN0"
  }
}


resource "aws_network_interface" "vbond_nic1" {
  subnet_id          = aws_subnet.controllers_subnet-1.id
  private_ips        = [var.aws_vbond-subnet-1_private_ip]
  security_groups    = [aws_security_group.controllers_vpn512-sg.id]
  source_dest_check  = false
  description        = "${var.bucket_prefix} vBond-NIC1-VPN512"
  tags  = {
    Name             = "${var.bucket_prefix} vBond-NIC1-VPN512"
  }
}

resource "aws_network_interface" "vbond_nic2" {
  subnet_id          = aws_subnet.controllers_subnet-2.id
  private_ips        = [var.aws_vbond-subnet-2_private_ip]
  security_groups    = [aws_security_group.controllers_vpn0-sg.id]
  source_dest_check  = false
  description        = "${var.bucket_prefix} vBond-NIC2-VPN0"
  tags  = {
    Name             = "${var.bucket_prefix} vBond-NIC2-VPN0"
  }
}


resource "aws_network_interface" "vsmart_nic1" {
  subnet_id          = aws_subnet.controllers_subnet-1.id
  private_ips        = [var.aws_vsmart-subnet-1_private_ip]
  security_groups    = [aws_security_group.controllers_vpn512-sg.id]
  source_dest_check  = false
  description        = "${var.bucket_prefix} vSmart-NIC1-VPN512"
  tags  = {
    Name             = "${var.bucket_prefix} vSmart-NIC1-VPN512"
  }
}

resource "aws_network_interface" "vsmart_nic2" {
  subnet_id          = aws_subnet.controllers_subnet-2.id
  private_ips        = [var.aws_vsmart-subnet-2_private_ip]
  security_groups    = [aws_security_group.controllers_vpn0-sg.id]
  source_dest_check  = false
  description        = "${var.bucket_prefix} vSmart-NIC2-VPN0"
  tags  = {
    Name             = "${var.bucket_prefix} vSmart-NIC2-VPN0"
  }
}



# Create Controller VMs:

resource "aws_instance" "controllers_vmanage" {
  ami                = var.aws_ami_id_vmanage
  instance_type      = var.aws_ami_type_vmanage
  key_name           = var.aws_key_pair_name
  availability_zone  = var.aws_controllers_az
  user_data  		 = file("vmanage-cloud-init.user_data")
  # Please note, that user_data file does NOT have variables,
  # so, adjust IP addresses and other parameters as needed directly in that file!
  # Cisco internal HowTo for controller cloud-init files: 
  # https://techzone.cisco.com/t5/Viptela/Configure-Cloud-Init-Bootstrap-for-SD-WAN-Controllers-Onboarding/ta-p/1739744

  network_interface {
    device_index            = 0
    network_interface_id    = aws_network_interface.vmanage_nic1.id
    delete_on_termination   = false
  }

  network_interface {
    device_index            = 1
    network_interface_id    = aws_network_interface.vmanage_nic2.id
    delete_on_termination   = false
  }

  tags  = {
    Name             = "${var.bucket_prefix} vManage"
  }

}

# Create 200 Gig volume for vManage partiton and attach it to vManage

resource "aws_ebs_volume" "vmanage_storage_volume" {
  availability_zone  =  var.aws_controllers_az
  size               =  200
  type               =  "gp2"
  tags = {
    Name = "${var.bucket_prefix} vManage Storage Partition"
  }
}

# Please note, that the disk name sdb mentioned below is different from the disk name in the cloud 
# init file vmanage-cloud-init.user_data - nvme1n1
# Refer to AWS Doc for more details on that: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/device_naming.html
# Also please note, that during terraform destroy, it takes a while to detach the volume, so, you may want to force detach manually.

resource "aws_volume_attachment" "vmanage_storage_attachment" {
  device_name = "/dev/sdb"
  volume_id   = aws_ebs_volume.vmanage_storage_volume.id
  instance_id = aws_instance.controllers_vmanage.id
}


resource "aws_instance" "controllers_vbond" {
  ami                = var.aws_ami_id_vbond
  instance_type      = var.aws_ami_type_vbond
  key_name           = var.aws_key_pair_name
  availability_zone  = var.aws_controllers_az
  user_data  		 = file("vbond-cloud-init.user_data")
  # Please note, that user_data file does NOT have variables,
  # so, adjust IP addresses and other parameters as needed directly in that file!
  # Cisco internal HowTo for controller cloud-init files: 
  # https://techzone.cisco.com/t5/Viptela/Configure-Cloud-Init-Bootstrap-for-SD-WAN-Controllers-Onboarding/ta-p/1739744

  network_interface {
    device_index            = 0
    network_interface_id    = aws_network_interface.vbond_nic1.id
    delete_on_termination   = false
  }

  network_interface {
    device_index            = 1
    network_interface_id    = aws_network_interface.vbond_nic2.id
    delete_on_termination   = false
  }

  tags = {
    Name             = "${var.bucket_prefix} vBond"
  }

}


resource "aws_instance" "controllers_vsmart" {
  ami                = var.aws_ami_id_vsmart
  instance_type      = var.aws_ami_type_vsmart
  key_name           = var.aws_key_pair_name
  availability_zone  = var.aws_controllers_az
  user_data  		 = file("vsmart-cloud-init.user_data")
  # Please note, that user_data file does NOT have variables,
  # so, adjust IP addresses and other parameters as needed directly in that file!
  # Cisco internal HowTo for controller cloud-init files: 
  # https://techzone.cisco.com/t5/Viptela/Configure-Cloud-Init-Bootstrap-for-SD-WAN-Controllers-Onboarding/ta-p/1739744

  network_interface {
    device_index            = 0
    network_interface_id    = aws_network_interface.vsmart_nic1.id
    delete_on_termination   = false
  }

  network_interface {
    device_index            = 1
    network_interface_id    = aws_network_interface.vsmart_nic2.id
    delete_on_termination   = false
  }

  tags = {
    Name = "${var.bucket_prefix} vSmart"
  }
}


# Allocate and assign public IP addresses to VPN512 and VPN0 interfaces for SD-WAN controllers

resource "aws_eip" "vmanage_nic1_eip_vpn512" {
#  vpc                       = true
  domain   					= "vpc"
  network_interface         = aws_network_interface.vmanage_nic1.id
  associate_with_private_ip = var.aws_vmanage-subnet-1_private_ip
  tags = {
    Name = "${var.bucket_prefix} vManage-vpn512-EIP"
  }
}

resource "aws_eip" "vmanage_nic2_eip_vpn0" {
#  vpc                       = true
  domain   					= "vpc"
  network_interface         = aws_network_interface.vmanage_nic2.id
  associate_with_private_ip = var.aws_vmanage-subnet-2_private_ip
  tags = {
    Name = "${var.bucket_prefix} vManage-vpn0-EIP"
  }
}


resource "aws_eip" "vbond_nic1_eip_vpn512" {
#  vpc                       = true
  domain   					= "vpc"
  network_interface         = aws_network_interface.vbond_nic1.id
  associate_with_private_ip = var.aws_vbond-subnet-1_private_ip
  tags = {
    Name = "${var.bucket_prefix} vBond-vpn512-EIP"
  }
}

resource "aws_eip" "vbond_nic2_eip_vpn0" {
#  vpc                       = true
  domain   					= "vpc"
  network_interface         = aws_network_interface.vbond_nic2.id
  associate_with_private_ip = var.aws_vbond-subnet-2_private_ip
  tags = {
    Name = "${var.bucket_prefix} vBond-vpn0-EIP"
  }
}


resource "aws_eip" "vsmart_nic1_eip_vpn512" {
#  vpc                       = true
  domain   					= "vpc"
  network_interface         = aws_network_interface.vsmart_nic1.id
  associate_with_private_ip = var.aws_vsmart-subnet-1_private_ip
  tags = {
    Name = "${var.bucket_prefix} vSmart-vpn512-EIP"
  }
}

resource "aws_eip" "vsmart_nic2_eip_vpn0" {
#  vpc                       = true
  domain   					= "vpc"
  network_interface         = aws_network_interface.vsmart_nic2.id
  associate_with_private_ip = var.aws_vsmart-subnet-2_private_ip
  tags = {
    Name = "${var.bucket_prefix} vSmart-vpn0-EIP"
  }
}
