# This file will create AWS Infrastructure (VPC, Subnets, IGW, Route Tables, etc) for SD-WAN Branch 1 with host and SD-WAN router for the ${var.bucket_prefix} demo

# Create Branch VPC:

resource "aws_vpc" "vpc_cloud-site" {
  cidr_block			= var.aws_cloud-site_vpc_cidr
  provider 				= aws.cloud-site
  tags = {
    Name = "${var.bucket_prefix} Cloud App VPC"
  }
}

# Create Subnets:

resource "aws_subnet" "cloud-site_vpc_subnet-1" {
    vpc_id 				= aws_vpc.vpc_cloud-site.id
    cidr_block 			= var.aws_cloud-site_vpc_subnet-1_cidr
    map_public_ip_on_launch = "true" //it makes this a public subnet
    availability_zone = var.aws_cloud-site_az
    tags = {
        Name = "${var.bucket_prefix} Cloud App Subnet-1 Mgmt"
    }
}

resource "aws_subnet" "cloud-site_vpc_subnet-2" {
    vpc_id 				= aws_vpc.vpc_cloud-site.id
    cidr_block 			= var.aws_cloud-site_vpc_subnet-2_cidr
    availability_zone 	= var.aws_cloud-site_az
    tags = {
        Name = "${var.bucket_prefix} Cloud App Subnet-2"
    }
}


# Create IGW for Internet Access:

resource "aws_internet_gateway" "cloud-site_vpc_igw" {
    vpc_id = aws_vpc.vpc_cloud-site.id
    tags = {
        Name = "${var.bucket_prefix} Cloud App VPC IGW"
    }
}


# Create route tables and default route pointing to IGW in VPN512 and VPN0:

resource "aws_route_table" "cloud-site_vpc_mgmt_rt" {
    vpc_id = aws_vpc.vpc_cloud-site.id
    route {
        //associated subnet can reach everywhere
        cidr_block = "0.0.0.0/0"         //CRT uses this IGW to reach internet
        gateway_id = aws_internet_gateway.cloud-site_vpc_igw.id
    }
    tags = {
        Name = "${var.bucket_prefix} Cloud App VPC Mgmt RT"
    }
} 


resource "aws_route_table" "cloud-site_vpc_rt_vpn10" {
    vpc_id = aws_vpc.vpc_cloud-site.id
    tags = {
        Name = "${var.bucket_prefix} Cloud App VPC RT Service VPN 10"
    }
} 


# Associate CRT and Subnet for Mgmt and Traffic:

resource "aws_route_table_association" "cloud-site_vpc_rta_subnet-1"{
    subnet_id 		= aws_subnet.cloud-site_vpc_subnet-1.id
    route_table_id 	= aws_route_table.cloud-site_vpc_mgmt_rt.id
}

resource "aws_route_table_association" "cloud-site_vpc_rta_subnet-2"{
    subnet_id 		= aws_subnet.cloud-site_vpc_subnet-2.id
    route_table_id 	= aws_route_table.cloud-site_vpc_rt_vpn10.id
}


# Create security group:

resource "aws_security_group" "cloud-site_vpc_mgmt_sg" {
    vpc_id = aws_vpc.vpc_cloud-site.id
    
    egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
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
        cidr_blocks = [var.ssh_allow_cidr]
    }  
    
    ingress {
        from_port = 8  #allow ping
        to_port = 0
        protocol = "icmp"
        cidr_blocks = ["10.0.0.0/8"]
    }  
        
    ingress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        self = "true"
    } 
         
    tags = {
        Name = "${var.bucket_prefix} Cloud App Mgmt SG"
    }
}


resource "aws_security_group" "cloud-site_vpc_sg" {
    vpc_id = aws_vpc.vpc_cloud-site.id
    
    egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
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
        cidr_blocks = [var.ssh_allow_cidr]
    }  

    ingress {
        from_port = 8  #allow ping
        to_port = 0
        protocol = "icmp"
        cidr_blocks = ["10.0.0.0/8"]
    } 
 
    ingress {
        from_port = 8001
        to_port = 8009
        protocol = "tcp"
        // For TE Probing
        cidr_blocks = ["0.0.0.0/0"]
    } 
    
    tags = {
        Name = "${var.bucket_prefix} Cloud App VPC SG"
    }
}


# Create NICs for the host:

resource "aws_network_interface" "host1_nic1" {
  subnet_id       	= aws_subnet.cloud-site_vpc_subnet-1.id
  private_ips     	= [var.aws_host1-subnet-1_private_ip]
  security_groups 	= [aws_security_group.cloud-site_vpc_mgmt_sg.id]
  source_dest_check = false
  description 		= "${var.bucket_prefix} Cloud App Host1 NIC1 MGMT"
  tags = {
    Name = "${var.bucket_prefix} Cloud App Host1 NIC1 MGMT"
  }
}

resource "aws_network_interface" "host1_nic2" {
  subnet_id       	= aws_subnet.cloud-site_vpc_subnet-2.id
  private_ips     	= [var.aws_host1-subnet-2_private_ip]
  security_groups 	= [aws_security_group.cloud-site_vpc_sg.id]
  source_dest_check = false
  description 		= "${var.bucket_prefix} Cloud App Host1 NIC2"
  tags = {
    Name = "${var.bucket_prefix} Cloud App Host1 NIC2"
  }
}


# Create Host VM:

resource "aws_instance" "cloud-site_host1" {
  ami 				= var.aws_ami_id_host1
  instance_type 	= var.aws_ami_type_host1
  key_name 			= var.aws_key_pair_name
  availability_zone =  var.aws_cloud-site_az

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
    Name = "${var.bucket_prefix} Cloud App Host1"
  }

}


# Allocate and assign public IP address to the mgmt interface for the host

resource "aws_eip" "host1_nic1_eip_mgmt" {
  vpc                       = true
  network_interface         = aws_network_interface.host1_nic1.id
  associate_with_private_ip = var.aws_host1-subnet-1_private_ip
  depends_on 				= [aws_instance.cloud-site_host1]
  tags = {
    Name = "${var.bucket_prefix} Cloud App Host1 Mgmt EIP"
  }
}
