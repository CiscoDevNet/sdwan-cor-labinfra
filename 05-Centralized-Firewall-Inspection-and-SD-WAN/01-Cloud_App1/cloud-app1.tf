# This file will create AWS Infrastructure (VPC, Subnets, IGW, Route Tables, TGW, etc) for 
# cloud app 1 security host VPC, which will be used for Security and SD-WAN centralized design demo.
# This host VPC will have only one linux VM, which will be used to generate traffic to SD-WAN / cloud app 2
# for east-west and north-south inspection. A web server will be used as "cloud-app".


# Create Security Host 1 VPC:
resource "aws_vpc" "vpc_cloud-site" {
  cidr_block			= var.aws_cloud-site_vpc_cidr
  provider 				= aws.cloud-site
  tags = {
    Name = "${var.bucket_prefix} Cloud App1 VPC"
  }
}

# Create Subnets:
resource "aws_subnet" "cloud-site_vpc_subnet-1" {
    vpc_id 				= aws_vpc.vpc_cloud-site.id
    cidr_block 			= var.aws_cloud-site_vpc_subnet-1_cidr
    map_public_ip_on_launch = "true" //it makes this a public subnet
    availability_zone = var.aws_cloud-site_az
    tags = {
        Name = "${var.bucket_prefix} Cloud App1 Subnet-1 Mgmt"
    }
}
resource "aws_subnet" "cloud-site_vpc_subnet-2" {
    vpc_id 				= aws_vpc.vpc_cloud-site.id
    cidr_block 			= var.aws_cloud-site_vpc_subnet-2_cidr
    availability_zone 	= var.aws_cloud-site_az
    tags = {
        Name = "${var.bucket_prefix} Cloud App1 Subnet-2"
    }
}


# Create IGW for Internet Access:
resource "aws_internet_gateway" "cloud-site_vpc_igw" {
    vpc_id = aws_vpc.vpc_cloud-site.id
    tags = {
        Name = "${var.bucket_prefix} Cloud App1 VPC IGW"
    }
}


# Create route tables and default route pointing to IGW in VPN512 (Mgmt) and VPN10 (Infra):
resource "aws_route_table" "cloud-site_vpc_mgmt_rt" {
    vpc_id = aws_vpc.vpc_cloud-site.id
    route {
        //associated subnet can reach everywhere
        cidr_block = "0.0.0.0/0"         //CRT uses this IGW to reach internet
        gateway_id = aws_internet_gateway.cloud-site_vpc_igw.id
    }
    tags = {
        Name = "${var.bucket_prefix} Cloud App1 VPC Mgmt RT"
    }
} 
resource "aws_route_table" "cloud-site_vpc_rt_vpn10" {
    vpc_id = aws_vpc.vpc_cloud-site.id
    tags = {
        Name = "${var.bucket_prefix} Cloud App1 VPC RT Service VPN 10"
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
        from_port = 8  # allow ping for your white list CIDR
        to_port = 0
        protocol = "icmp"
        cidr_blocks = [var.ssh_allow_cidr]
    }  
    
    ingress {
        from_port = 8  # allow ping for all cloud infra
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
        Name = "${var.bucket_prefix} Cloud App1 Mgmt SG"
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
        from_port = 80  # will be used to generate test http traffic
        to_port = 80
        protocol = "tcp"        
        cidr_blocks = ["10.0.0.0/8"]
    }  

    ingress {
        from_port = 8  # allow ping for your white list CIDR
        to_port = 0
        protocol = "icmp"
        cidr_blocks = [var.ssh_allow_cidr]
    }  

    ingress {
        from_port = 8  # allow ping for all cloud infra
        to_port = 0
        protocol = "icmp"
        cidr_blocks = ["10.0.0.0/8"]
    } 
    
    tags = {
        Name = "${var.bucket_prefix} Cloud App1 VPC SG"
    }
}


# Create NICs for the host:
resource "aws_network_interface" "host1_nic1" {
  subnet_id       	= aws_subnet.cloud-site_vpc_subnet-1.id
  private_ips     	= [var.aws_host1-subnet-1_private_ip]
  security_groups 	= [aws_security_group.cloud-site_vpc_mgmt_sg.id]
  source_dest_check = false
  description 		= "${var.bucket_prefix} Cloud App1 NIC1 MGMT"
  tags = {
    Name = "${var.bucket_prefix} Cloud App1 NIC1 MGMT"
  }
}
resource "aws_network_interface" "host1_nic2" {
  subnet_id       	= aws_subnet.cloud-site_vpc_subnet-2.id
  private_ips     	= [var.aws_host1-subnet-2_private_ip]
  security_groups 	= [aws_security_group.cloud-site_vpc_sg.id]
  source_dest_check = false
  description 		= "${var.bucket_prefix} Cloud App1 NIC2"
  tags = {
    Name = "${var.bucket_prefix} Cloud App1 NIC2"
  }
}


# Create Host VM:
resource "aws_instance" "cloud-site_host1" {
  ami 				= var.aws_ami_id_host1
  instance_type 	= var.aws_ami_type_host1
  key_name 			= var.aws_key_pair_name
  availability_zone = var.aws_cloud-site_az
  user_data  		= file("cloud-init-cloud-site_host1.user_data")

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
    Name = "${var.bucket_prefix} Cloud App1"
  }

}


# Allocate and assign public IP address to the mgmt interface for the host
resource "aws_eip" "host1_nic1_eip_mgmt" {
  vpc                       = true
  network_interface         = aws_network_interface.host1_nic1.id
  associate_with_private_ip = var.aws_host1-subnet-1_private_ip
  depends_on 				= [aws_instance.cloud-site_host1]
  tags = {
    Name = "${var.bucket_prefix} Cloud App1 Mgmt EIP"
  }
}


# Create TGW and two TGW route tables, attaching host VPC with cloud-app1 to TGW as VPC attachment
# Creating TGW itself:
resource "aws_ec2_transit_gateway" "sec_tgw" {
  description                     = "${var.bucket_prefix} TGW"
  amazon_side_asn                 = var.tgw_amazon_side_asn
  auto_accept_shared_attachments  = "enable"
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
  tags = {
    Name = "${var.bucket_prefix} TGW"
  }
}
# Creating incoming TGW Route Table (from host VPCs to shared services for inspection):
resource "aws_ec2_transit_gateway_route_table" "sec_tgw_incoming_from_host_vpcs_rt" {
  transit_gateway_id             = aws_ec2_transit_gateway.sec_tgw.id
  depends_on 		             = [aws_ec2_transit_gateway.sec_tgw]
  tags = {
    Name = "${var.bucket_prefix} TGW Route Table incoming from host VPCs to shared services"
  }
}

# Creating Outgoing TGW Route Table (from shared services, after inspection):
resource "aws_ec2_transit_gateway_route_table" "tgw_outgoing_from_shared_services_rt" {
  transit_gateway_id             = aws_ec2_transit_gateway.sec_tgw.id
  depends_on 		             = [aws_ec2_transit_gateway.sec_tgw]
  tags = {
    Name = "${var.bucket_prefix} TGW Route Table outgoing from shared services"
  }
}
# Attaching Host VPC (cloud-app1) to TGW as VPC Attachment:
resource "aws_ec2_transit_gateway_vpc_attachment" "host_vpc_1_tgw_attachment" {
  subnet_ids         = [aws_subnet.cloud-site_vpc_subnet-2.id]
  transit_gateway_id = aws_ec2_transit_gateway.sec_tgw.id
  vpc_id             = aws_vpc.vpc_cloud-site.id
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  depends_on 		 = [aws_ec2_transit_gateway.sec_tgw]
  tags = {
    Name = "${var.bucket_prefix} VPC Attachment for Host VPC 1 aka cloud-app1"
  }
}
# Associate Cloud App VPC with the incoming TGW Route Table:
resource "aws_ec2_transit_gateway_route_table_association" "sec_tgw_rt_host_vpc_attachment_association" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.host_vpc_1_tgw_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.sec_tgw_incoming_from_host_vpcs_rt.id
  depends_on 		 = [aws_ec2_transit_gateway.sec_tgw]
}

# Additional Route Table programming will be done later in a different section. 
# We need to create other ressources like shared services VPC and GWLB Endpoints first.


# Write Management IP of the Host 1 to CLI
output "app1_mgmt_ip" {
  value         = "${aws_instance.cloud-site_host1.public_ip}  Re-run 'terraform apply' if you don't see the IP. To connect: ssh -i <aws-key-file> ec2-user@<IP> "
  depends_on 	= [aws_instance.cloud-site_host1]
}