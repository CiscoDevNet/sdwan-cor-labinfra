# This file will create AWS Infrastructure (VPC, Subnets, IGW, Route Tables, etc) for 
# shared services VPC, which will be used for Security and SD-WAN centralized design demo.
# This VPC will have two Firewalls (Cisco FTDv) in two different AZs, which will be used to inspect traffic to SD-WAN / cloud app 2
# AWS Gateway Load Balancer (GWLB) with appropriate GWLB Endpoints will use GENEVE protocol between GWLB and Firewalls.
# Please note, that you will need to configure FTDv afterwards via FMCv (i.e. GENEVE protocol)


# Create Shared Services VPC:

resource "aws_vpc" "vpc_shared-services" {
  cidr_block			= var.aws_shared-services_vpc_cidr
  provider 				= aws.shared-services
  tags = {
    Name = "${var.bucket_prefix} Shared Services VPC"
  }
}


# Create Subnets
# for the first Availability Zone (AZ):
resource "aws_subnet" "shared-services_vpc_az1_subnet-1" {
    vpc_id 				= aws_vpc.vpc_shared-services.id
    cidr_block 			= var.aws_shared-services_vpc_az1_subnet-1_cidr
    map_public_ip_on_launch = "true"                 # it makes this a public subnet
    availability_zone = var.aws_shared-services_az1
    tags = {
        Name = "${var.bucket_prefix} Shared Services 1st AZ Subnet-1 Mgmt"
    }
}

resource "aws_subnet" "shared-services_vpc_az1_subnet-2" {
    vpc_id 				= aws_vpc.vpc_shared-services.id
    cidr_block 			= var.aws_shared-services_vpc_az1_subnet-2_cidr
    availability_zone 	= var.aws_shared-services_az1
    tags = {
        Name = "${var.bucket_prefix} Shared Services 1st AZ Subnet-2"
    }
}

resource "aws_subnet" "shared-services_vpc_az1_subnet-3" {
    vpc_id 				= aws_vpc.vpc_shared-services.id
    cidr_block 			= var.aws_shared-services_vpc_az1_subnet-3_cidr
    availability_zone 	= var.aws_shared-services_az1
    tags = {
        Name = "${var.bucket_prefix} Shared Services 1st AZ Subnet-3"
    }
}

# Creating Subnets for the 2nd Availability Zone:
resource "aws_subnet" "shared-services_vpc_az2_subnet-1" {
    vpc_id 				= aws_vpc.vpc_shared-services.id
    cidr_block 			= var.aws_shared-services_vpc_az2_subnet-1_cidr
    map_public_ip_on_launch = "true"                 # it makes this a public subnet
    availability_zone = var.aws_shared-services_az2
    tags = {
        Name = "${var.bucket_prefix} Shared Services 2nd AZ Subnet-1 Mgmt"
    }
}

resource "aws_subnet" "shared-services_vpc_az2_subnet-2" {
    vpc_id 				= aws_vpc.vpc_shared-services.id
    cidr_block 			= var.aws_shared-services_vpc_az2_subnet-2_cidr
    availability_zone 	= var.aws_shared-services_az2
    tags = {
        Name = "${var.bucket_prefix} Shared Services 2nd AZ Subnet-2"
    }
}

resource "aws_subnet" "shared-services_vpc_az2_subnet-3" {
    vpc_id 				= aws_vpc.vpc_shared-services.id
    cidr_block 			= var.aws_shared-services_vpc_az2_subnet-3_cidr
    availability_zone 	= var.aws_shared-services_az2
    tags = {
        Name = "${var.bucket_prefix} Shared Services 2nd AZ Subnet-3"
    }
}


# Create IGW for Internet Access:

resource "aws_internet_gateway" "shared-services_vpc_igw" {
    vpc_id = aws_vpc.vpc_shared-services.id
    tags = {
        Name = "${var.bucket_prefix} Shared Services VPC IGW"
    }
}


# Create route tables and default route pointing to IGW in Mgmt, Incoming from TGW and Outgoing to TGW route tables
# Creating 3 Route Tables for the 1st Availability Zone:
resource "aws_route_table" "shared-services_vpc_az1_mgmt_rt" {
    vpc_id = aws_vpc.vpc_shared-services.id
    route {
        //associated subnet can reach everywhere
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.shared-services_vpc_igw.id
    }
    tags = {
        Name = "${var.bucket_prefix} Shared Services VPC 1st AZ Mgmt RT"
    }
} 

resource "aws_route_table" "shared-services_vpc_az1_rt_incoming" {
    vpc_id = aws_vpc.vpc_shared-services.id
    tags = {
        Name = "${var.bucket_prefix} Shared Services VPC 1st AZ RT Incoming from TGW"
    }
} 

resource "aws_route_table" "shared-services_vpc_az1_rt_outgoing" {
    vpc_id = aws_vpc.vpc_shared-services.id
    tags = {
        Name = "${var.bucket_prefix} Shared Services VPC 1st AZ RT Outgoing to TGW"
    }
} 

# Creating 3 Route Tables for the 2nd Availability Zone:
resource "aws_route_table" "shared-services_vpc_az2_mgmt_rt" {
    vpc_id = aws_vpc.vpc_shared-services.id
    route {
        //associated subnet can reach everywhere
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.shared-services_vpc_igw.id
    }
    tags = {
        Name = "${var.bucket_prefix} Shared Services VPC 2nd AZ Mgmt RT"
    }
} 

resource "aws_route_table" "shared-services_vpc_az2_rt_incoming" {
    vpc_id = aws_vpc.vpc_shared-services.id
    tags = {
        Name = "${var.bucket_prefix} Shared Services VPC 2nd AZ RT Incoming from TGW"
    }
} 

resource "aws_route_table" "shared-services_vpc_az2_rt_outgoing" {
    vpc_id = aws_vpc.vpc_shared-services.id
    tags = {
        Name = "${var.bucket_prefix} Shared Services VPC 2nd AZ RT Outgoing to TGW"
    }
} 


# Associate CRT and Subnet for Mgmt and Traffic
# for the 1st AZ:
resource "aws_route_table_association" "shared-services_vpc_az1_rta_subnet-1"{
    subnet_id 		= aws_subnet.shared-services_vpc_az1_subnet-1.id
    route_table_id 	= aws_route_table.shared-services_vpc_az1_mgmt_rt.id
}

resource "aws_route_table_association" "shared-services_vpc_az1_rta_subnet-2"{
    subnet_id 		= aws_subnet.shared-services_vpc_az1_subnet-2.id
    route_table_id 	= aws_route_table.shared-services_vpc_az1_rt_incoming.id
}

resource "aws_route_table_association" "shared-services_vpc_az1_rta_subnet-3"{
    subnet_id 		= aws_subnet.shared-services_vpc_az1_subnet-3.id
    route_table_id 	= aws_route_table.shared-services_vpc_az1_rt_outgoing.id
}

# for the 2nd AZ:
resource "aws_route_table_association" "shared-services_vpc_az2_rta_subnet-1"{
    subnet_id 		= aws_subnet.shared-services_vpc_az2_subnet-1.id
    route_table_id 	= aws_route_table.shared-services_vpc_az2_mgmt_rt.id
}

resource "aws_route_table_association" "shared-services_vpc_az2_rta_subnet-2"{
    subnet_id 		= aws_subnet.shared-services_vpc_az2_subnet-2.id
    route_table_id 	= aws_route_table.shared-services_vpc_az2_rt_incoming.id
}

resource "aws_route_table_association" "shared-services_vpc_az2_rta_subnet-3"{
    subnet_id 		= aws_subnet.shared-services_vpc_az2_subnet-3.id
    route_table_id 	= aws_route_table.shared-services_vpc_az2_rt_outgoing.id
}


# Create security group:

resource "aws_security_group" "shared-services_vpc_mgmt_sg" {
    vpc_id = aws_vpc.vpc_shared-services.id
    
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
        Name = "${var.bucket_prefix} Shared Services Mgmt SG"
    }
}


resource "aws_security_group" "shared-services_vpc_sg" {
    vpc_id = aws_vpc.vpc_shared-services.id
    
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
        Name = "${var.bucket_prefix} Shared Services VPC SG"
    }
}


# Create NICs for the firewalls
# First Firewall:
resource "aws_network_interface" "fw1_nic1" {
  subnet_id       	= aws_subnet.shared-services_vpc_az1_subnet-1.id
  private_ips     	= [var.aws_fw1_subnet-1_private_ip]
  security_groups 	= [aws_security_group.shared-services_vpc_mgmt_sg.id]
  source_dest_check = false
  description 		= "${var.bucket_prefix} FW1 NIC1 MGMT"
  tags = {
    Name = "${var.bucket_prefix} FW1 NIC1 MGMT"
  }
}

resource "aws_network_interface" "fw1_nic2" {
  subnet_id       	= aws_subnet.shared-services_vpc_az1_subnet-2.id
  private_ips     	= [var.aws_fw1_subnet-2_private_ip]
  security_groups 	= [aws_security_group.shared-services_vpc_sg.id]
  source_dest_check = false
  description 		= "${var.bucket_prefix} FW1 NIC2"
  tags = {
    Name = "${var.bucket_prefix} FW1 NIC2"
  }
}

resource "aws_network_interface" "fw1_nic3" {
  subnet_id       	= aws_subnet.shared-services_vpc_az1_subnet-3.id
  private_ips     	= [var.aws_fw1_subnet-3_private_ip]
  security_groups 	= [aws_security_group.shared-services_vpc_sg.id]
  source_dest_check = false
  description 		= "${var.bucket_prefix} FW1 NIC3"
  tags = {
    Name = "${var.bucket_prefix} FW1 NIC3"
  }
}

# Second Firewall
resource "aws_network_interface" "fw2_nic1" {
  subnet_id       	= aws_subnet.shared-services_vpc_az2_subnet-1.id
  private_ips     	= [var.aws_fw2_subnet-1_private_ip]
  security_groups 	= [aws_security_group.shared-services_vpc_mgmt_sg.id]
  source_dest_check = false
  description 		= "${var.bucket_prefix} FW2 NIC1 MGMT"
  tags = {
    Name = "${var.bucket_prefix} FW2 NIC1 MGMT"
  }
}

resource "aws_network_interface" "fw2_nic2" {
  subnet_id       	= aws_subnet.shared-services_vpc_az2_subnet-2.id
  private_ips     	= [var.aws_fw2_subnet-2_private_ip]
  security_groups 	= [aws_security_group.shared-services_vpc_sg.id]
  source_dest_check = false
  description 		= "${var.bucket_prefix} FW2 NIC2"
  tags = {
    Name = "${var.bucket_prefix} FW2 NIC2"
  }
}

resource "aws_network_interface" "fw2_nic3" {
  subnet_id       	= aws_subnet.shared-services_vpc_az2_subnet-3.id
  private_ips     	= [var.aws_fw2_subnet-3_private_ip]
  security_groups 	= [aws_security_group.shared-services_vpc_sg.id]
  source_dest_check = false
  description 		= "${var.bucket_prefix} FW2 NIC3"
  tags = {
    Name = "${var.bucket_prefix} FW2 NIC3"
  }
}


# Create FW VMs
# Create 1st FW:
resource "aws_instance" "shared-services_fw1" {
  ami 				= var.aws_ami_id_fw
  instance_type 	= var.aws_ami_type_fw
  key_name 			= var.aws_key_pair_name
  availability_zone =  var.aws_shared-services_az1
  user_data  		= file("cloud-init-shared-services_fw1.user_data")

  network_interface {
    device_index         	= 0
    network_interface_id 	= aws_network_interface.fw1_nic1.id
    delete_on_termination 	= false
  }

  network_interface {
    device_index         	= 1
    network_interface_id 	= aws_network_interface.fw1_nic2.id
    delete_on_termination 	= false
  }

  network_interface {
    device_index         	= 2
    network_interface_id 	= aws_network_interface.fw1_nic3.id
    delete_on_termination 	= false
  }
  
  tags = {
    Name = "${var.bucket_prefix} FW1"
  }

}

# Create 2nd FW:
resource "aws_instance" "shared-services_fw2" {
  ami 				= var.aws_ami_id_fw
  instance_type 	= var.aws_ami_type_fw
  key_name 			= var.aws_key_pair_name
  availability_zone =  var.aws_shared-services_az2
  user_data  		= file("cloud-init-shared-services_fw2.user_data")

  network_interface {
    device_index         	= 0
    network_interface_id 	= aws_network_interface.fw2_nic1.id
    delete_on_termination 	= false
  }

  network_interface {
    device_index         	= 1
    network_interface_id 	= aws_network_interface.fw2_nic2.id
    delete_on_termination 	= false
  }

  network_interface {
    device_index         	= 2
    network_interface_id 	= aws_network_interface.fw2_nic3.id
    delete_on_termination 	= false
  }
  
  tags = {
    Name = "${var.bucket_prefix} FW2"
  }

}


# Allocate and assign public IP address to the mgmt interface for the FW1:
resource "aws_eip" "fw1_nic1_eip_mgmt" {
  vpc                       = true
  network_interface         = aws_network_interface.fw1_nic1.id
  associate_with_private_ip = var.aws_fw1_subnet-1_private_ip
  depends_on 				= [aws_instance.shared-services_fw1]
  tags = {
    Name = "${var.bucket_prefix} FW1 Mgmt EIP"
  }
}

# Allocate and assign public IP address to the mgmt interface for the FW2:
resource "aws_eip" "fw2_nic1_eip_mgmt" {
  vpc                       = true
  network_interface         = aws_network_interface.fw2_nic1.id
  associate_with_private_ip = var.aws_fw2_subnet-1_private_ip
  depends_on 				= [aws_instance.shared-services_fw2]
  tags = {
    Name = "${var.bucket_prefix} FW2 Mgmt EIP"
  }
}


# Write Management IP of the Firewalls to CLI
output "fw1_mgmt_ip" {
  value         = "${aws_instance.shared-services_fw1.public_ip}  Re-run 'terraform apply' if you don't see the IP. To connect: ssh -i <aws-key-file> ec2-user@<IP> "
  depends_on 	= [aws_instance.shared-services_fw1]
}

output "fw2_mgmt_ip" {
  value         = "${aws_instance.shared-services_fw2.public_ip}  Re-run 'terraform apply' if you don't see the IP. To connect: ssh -i <aws-key-file> ec2-user@<IP> "
  depends_on 	= [aws_instance.shared-services_fw2]
}





# Create Load Balancing Target Group using GENEVE with Health Check

resource "aws_lb_target_group" "target_group_geneve" {
  name        = "SEC-target-group-geneve"
  port        = 6081
  protocol    = "GENEVE"
  target_type = "ip"
  vpc_id      = aws_vpc.vpc_shared-services.id
  
  health_check {  # using TCP health check on port 443:
    port      = 443
    protocol  = "TCP"
  }

}


# Add IP addresses of the Firewalls to the target group using GENEVE port 6081
resource "aws_lb_target_group_attachment" "target_group_attachment_fw1" {
  target_group_arn = aws_lb_target_group.target_group_geneve.arn
  target_id        = var.aws_fw1_subnet-2_private_ip
  port             = 6081
  depends_on 	   = [
                        aws_lb_target_group.target_group_geneve,
                        aws_instance.shared-services_fw1
                     ]
}
resource "aws_lb_target_group_attachment" "target_group_attachment_fw2" {
  target_group_arn = aws_lb_target_group.target_group_geneve.arn
  target_id        = var.aws_fw2_subnet-2_private_ip
  port             = 6081
  depends_on 	   = [
                        aws_lb_target_group.target_group_geneve,
                        aws_instance.shared-services_fw2
                     ]
}


# Create Gateway Load Balancer (GWLB) with cross AZ Load Balancing
resource "aws_lb" "gwlb_geneve" {
  name                = "SEC-geneve-GWLB"
  load_balancer_type  = "gateway"
  subnets             = [
                           aws_subnet.shared-services_vpc_az1_subnet-2.id, 
                           aws_subnet.shared-services_vpc_az2_subnet-2.id
                        ]
  enable_cross_zone_load_balancing = true   # critical to enable because we use multiple availability zones! 
  tags = {
    Name = "${var.bucket_prefix} GWLB for Firewalls"
  }
}

# Create GWLB Listener pointing to the appropriate target grou:
resource "aws_lb_listener" "gwlb_geneve_listener" {
  load_balancer_arn = aws_lb.gwlb_geneve.id

  default_action {
    target_group_arn = aws_lb_target_group.target_group_geneve.id
    type             = "forward"
  }
}

# Create GWLB Endpoints in two steps: create endpoint service first and then endpoints in two Availability Zones
data "aws_caller_identity" "current" {}
# Create Endpoint Service:
resource "aws_vpc_endpoint_service" "gwlb_endpoint_service" {
  acceptance_required        = false
  allowed_principals         = [data.aws_caller_identity.current.arn]
  gateway_load_balancer_arns = [aws_lb.gwlb_geneve.arn]
  depends_on 	             = [aws_lb.gwlb_geneve]
  tags = {
    Name = "${var.bucket_prefix} GWLB Endpoint Service for FW Load Balancing using GENEVE"
  }
}
# Create Endpoint in AZ1:
resource "aws_vpc_endpoint" "gwlb_endpoint_az1" {
  service_name      = aws_vpc_endpoint_service.gwlb_endpoint_service.service_name
  subnet_ids        = [aws_subnet.shared-services_vpc_az1_subnet-3.id]
  vpc_endpoint_type = aws_vpc_endpoint_service.gwlb_endpoint_service.service_type
  vpc_id            = aws_vpc.vpc_shared-services.id
  depends_on 	    = [aws_vpc_endpoint_service.gwlb_endpoint_service]
  tags = {
    Name = "${var.bucket_prefix} GWLB Endpoint in AZ1"
  }
}
# Create Endpoint in AZ2:
resource "aws_vpc_endpoint" "gwlb_endpoint_az2" {
  service_name      = aws_vpc_endpoint_service.gwlb_endpoint_service.service_name
  subnet_ids        = [aws_subnet.shared-services_vpc_az2_subnet-3.id]
  vpc_endpoint_type = aws_vpc_endpoint_service.gwlb_endpoint_service.service_type
  vpc_id            = aws_vpc.vpc_shared-services.id
  depends_on 	    = [aws_vpc_endpoint_service.gwlb_endpoint_service]
  tags = {
    Name = "${var.bucket_prefix} GWLB Endpoint in AZ2"
  }
}
# Please note, that the health check between GWLB and FTDv firewalls will not work until you configure GENEVE protocol on firewalls via FMC!


# Find out TGW, which was created earlier by cloud-app1 script and attach shared services VPC to TGW
data "aws_ec2_transit_gateway" "sec_tgw" {
  filter {
    name   = "options.amazon-side-asn"
    values = [var.tgw_amazon_side_asn]  # the assumption here: there is only ONE TGW with this ASN
  }
  filter {
    name   = "state"
    values = ["available"]
  }
}
# Attaching Shared Services VPC to TGW as VPC Attachment with Appliance Mode support:
resource "aws_ec2_transit_gateway_vpc_attachment" "shared_services_tgw_attachment" {
  subnet_ids             = [
                              aws_subnet.shared-services_vpc_az1_subnet-2.id,
                              aws_subnet.shared-services_vpc_az2_subnet-2.id
                           ]
  transit_gateway_id     = data.aws_ec2_transit_gateway.sec_tgw.id
  vpc_id                 = aws_vpc.vpc_shared-services.id
  appliance_mode_support = "enable"   # this is critical to ensure symmetric routing!
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  tags = {
    Name = "${var.bucket_prefix} VPC Attachment for Shared Services VPC"
  }
}
# Associate Shared Services VPC with the outgoing TGW Route Table:
data "aws_ec2_transit_gateway_route_table" "sec_tgw_outgoing_rt" {
  filter {
    name   = "tag:Name"
    values = ["${var.bucket_prefix} TGW Route Table outgoing from shared services"]  # the assumption here: there is only ONE TGW with this ASN
  }
}
resource "aws_ec2_transit_gateway_route_table_association" "sec_tgw_rt_shared_services_attachment_association" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.shared_services_tgw_attachment.id
  transit_gateway_route_table_id = data.aws_ec2_transit_gateway_route_table.sec_tgw_outgoing_rt.id
}


# Now we have needed infrastructure created and can tweak routes in existing route tables
# Find out route table from Cloud App1 Host VPC:
data "aws_route_table" "cloud_app1_rt_vpn10" {
  filter {
    name   = "tag:Name"
    values = ["${var.bucket_prefix} Cloud App1 VPC RT Service VPN 10"]  # the assumption here: description from cloud-app1 script was not changed
  }
}
# Create default route in the Cloud App1 Host VPC pointing to TGW:
resource "aws_route" "cloud_app1_default_route_to_tgw" {
  route_table_id            = data.aws_route_table.cloud_app1_rt_vpn10.id
  destination_cidr_block    = "0.0.0.0/0"
  transit_gateway_id        = data.aws_ec2_transit_gateway.sec_tgw.id
  depends_on                = [data.aws_ec2_transit_gateway.sec_tgw]
}
# Find out route table from Cloud App2 Host VPC:
data "aws_route_table" "cloud_app2_rt_vpn10" {
  filter {
    name   = "tag:Name"
    values = ["${var.bucket_prefix} Cloud App2 VPC RT Service VPN 10"]  # the assumption here: description from cloud-app1 script was not changed
  }
}
# Create default route in the Cloud App2 Host VPC pointing to TGW:
resource "aws_route" "cloud_app2_default_route_to_tgw" {
  route_table_id            = data.aws_route_table.cloud_app2_rt_vpn10.id
  destination_cidr_block    = "0.0.0.0/0"
  transit_gateway_id        = data.aws_ec2_transit_gateway.sec_tgw.id
  depends_on                = [data.aws_ec2_transit_gateway.sec_tgw]
}
 
# Add route to the incoming TGW route table pointing to shared services
# Find out TGW incoming route table, which was defined in cloud-app1 script:
data "aws_ec2_transit_gateway_route_table" "sec_tgw_incoming_route_table" {
  filter {
    name   = "tag:Name"
    values = ["${var.bucket_prefix} TGW Route Table incoming from host VPCs to shared services"]  # the assumption here: description from cloud-app1 script was not changed
  }
}
# Install default route in the incoming TGW route table pointing to shared services VPC attachment:
resource "aws_ec2_transit_gateway_route" "sec_tgw_rt_incoming_to_shared_services" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.shared_services_tgw_attachment.id
  transit_gateway_route_table_id = data.aws_ec2_transit_gateway_route_table.sec_tgw_incoming_route_table.id
}

# Install default route in Shared Services AZ1 Incoming Route Table pointing to GWLB Endpoint
resource "aws_route" "shared-services_vpc_az1_rt_incoming_route_to_gwlb_endpoint" {
  route_table_id            = aws_route_table.shared-services_vpc_az1_rt_incoming.id
  destination_cidr_block    = "0.0.0.0/0"
  vpc_endpoint_id 			= aws_vpc_endpoint.gwlb_endpoint_az1.id
  depends_on                = [aws_vpc_endpoint.gwlb_endpoint_az1]
}
# Install default route in Shared Services AZ2 Incoming Route Table pointing to GWLB Endpoint
resource "aws_route" "shared-services_vpc_az2_rt_incoming_route_to_gwlb_endpoint" {
  route_table_id            = aws_route_table.shared-services_vpc_az2_rt_incoming.id
  destination_cidr_block    = "0.0.0.0/0"
  vpc_endpoint_id 			= aws_vpc_endpoint.gwlb_endpoint_az2.id
  depends_on                = [aws_vpc_endpoint.gwlb_endpoint_az2]
}

# Install static route in the Shared Services AZ1 outgoing pointing to TGW
resource "aws_route" "shared-services_vpc_az1_rt_outgoing_route_to_tgw" {
  route_table_id            = aws_route_table.shared-services_vpc_az1_rt_outgoing.id
  destination_cidr_block    = var.aws_shared-services_vpc_az1_cidr_route_back_to_tgw
  transit_gateway_id 		= data.aws_ec2_transit_gateway.sec_tgw.id
  depends_on                = [data.aws_ec2_transit_gateway.sec_tgw]
}
# Install static route in the Shared Services AZ2 outgoing pointing to TGW
resource "aws_route" "shared-services_vpc_az2_rt_outgoing_route_to_tgw" {
  route_table_id            = aws_route_table.shared-services_vpc_az2_rt_outgoing.id
  destination_cidr_block    = var.aws_shared-services_vpc_az2_cidr_route_back_to_tgw
  transit_gateway_id 		= data.aws_ec2_transit_gateway.sec_tgw.id
  depends_on                = [data.aws_ec2_transit_gateway.sec_tgw]
}

# Install static routes in the outgoing TGW route table pointing to cloud apps (host VPCs)
# find out CIDR for the cloud app1 VPC:
data "aws_vpc" "host_vpc1_cidr" {
  filter {
    name   = "tag:Name"
    values = ["${var.bucket_prefix} Cloud App1 VPC"]  # the assumption here: description from cloud-app1 script was not changed
  }
}
# find out outgoing TGW route table:
data "aws_ec2_transit_gateway_route_table" "sec_tgw_outgoing_route_table" {
  filter {
    name   = "tag:Name"
    values = ["${var.bucket_prefix} TGW Route Table outgoing from shared services"]  # the assumption here: description from cloud-app1 script was not changed
  }
}
# install static route for cloud app1 into TGW outgoing route table:
resource "aws_ec2_transit_gateway_route" "sec_tgw_rt_outgoing_route_to_host_vpc1" {
  destination_cidr_block         = data.aws_vpc.host_vpc1_cidr.cidr_block
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.shared_services_tgw_attachment.id
  transit_gateway_route_table_id = data.aws_ec2_transit_gateway_route_table.sec_tgw_outgoing_route_table.id
  depends_on                     = [data.aws_ec2_transit_gateway.sec_tgw]
}
# find out CIDR for the cloud app2 VPC:
data "aws_vpc" "host_vpc2_cidr" {
  filter {
    name   = "tag:Name"
    values = ["${var.bucket_prefix} Cloud App2 VPC"]  # the assumption here: description from cloud-app1 script was not changed
  }
}
# install static route for cloud app2 into TGW outgoing route table:
resource "aws_ec2_transit_gateway_route" "sec_tgw_rt_outgoing_route_to_host_vpc2" {
  destination_cidr_block         = data.aws_vpc.host_vpc2_cidr.cidr_block
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.shared_services_tgw_attachment.id
  transit_gateway_route_table_id = data.aws_ec2_transit_gateway_route_table.sec_tgw_outgoing_route_table.id
  depends_on                     = [data.aws_ec2_transit_gateway.sec_tgw]
}