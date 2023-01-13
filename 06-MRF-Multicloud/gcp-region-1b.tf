# This file will create GCP Infrastructure for SD-WAN MRF Multicloud Region 1, Subregion 2 (aka region-1b) like US-West
# Based on https://gist.github.com/rtortori/dda3711d7e49cf8da858f8b84e49bc72

# Make sure, that your ssh keys are in right format and valid!
locals {
  gce_ssh_pub_key_file_clean_region_1b = "${replace(file(var.region_1b_sdwan_router_instance["gce_ssh_pub_key_file"]), "\n", "")}"
}


provider "google" {
  credentials 	= file(var.gcp["gcp_credential_file"])
  project 		= var.gcp["gcp_project_id"]
  region  		= var.region_1b_gcp["gcp_region_1b"]
  zone    		= var.region_1b_gcp["gcp_region_1b_zone"]
  alias 		= "gcp_region_1b"
}


# Creating VPC networks (one VPV per NIC required):
resource "google_compute_network" "region_1b_vpc_network_vpn512" {
  name                    = var.region_1b_networking["gce_region_1b_sdwan_vpc_name_vpn512"]
  auto_create_subnetworks = "false"
}

resource "google_compute_network" "region_1b_vpc_network_vpn0" {
  name                    = var.region_1b_networking["gce_region_1b_sdwan_vpc_name_vpn0"]
  auto_create_subnetworks = "false"
}

resource "google_compute_network" "region_1b_vpc_network_vpn10" {
  name                    = var.region_1b_networking["gce_region_1b_sdwan_vpc_name_vpn10"]
  auto_create_subnetworks = "false"
}


# Creating Subnets for vpn512 (management), vpn0 (wan) and vpn10 (service):
resource "google_compute_subnetwork" "region_1b_sdwan_r1_subnet_vpn512" {
  name          = var.region_1b_networking["gce_region_1b_sdwan_r1_subnet_vpn512"]
  ip_cidr_range = var.region_1b_networking["gce_region_1b_sdwan_vpc_net_cidr_vpn512"]
  region        = var.region_1b_gcp["gcp_region_1b"]
  network       = google_compute_network.region_1b_vpc_network_vpn512.name
}

resource "google_compute_subnetwork" "region_1b_sdwan_r1_subnet_vpn0" {
  name          = var.region_1b_networking["gce_region_1b_sdwan_r1_subnet_vpn0"]
  ip_cidr_range = var.region_1b_networking["gce_region_1b_sdwan_vpc_net_cidr_vpn0"]
  region        = var.region_1b_gcp["gcp_region_1b"]
  network       = google_compute_network.region_1b_vpc_network_vpn0.name
}

resource "google_compute_subnetwork" "region_1b_sdwan_r1_subnet_vpn10" {
  name          = var.region_1b_networking["gce_region_1b_sdwan_r1_subnet_vpn10"]
  ip_cidr_range = var.region_1b_networking["gce_region_1b_sdwan_vpc_net_cidr_vpn10"]
  region        = var.region_1b_gcp["gcp_region_1b"]
  network       = google_compute_network.region_1b_vpc_network_vpn10.name
}


# Creating public IPv4 address:
resource "google_compute_address" "region-1b-r1-public-ip-vpn512" {
  name 		= var.region_1b_networking["gce_region_1b_sdwan_r1_ext_ip_name_vpn512"]
  region	= var.region_1b_gcp["gcp_region_1b"]
}

resource "google_compute_address" "region-1b-r1-public-ip-vpn0" {
  name 		= var.region_1b_networking["gce_region_1b_sdwan_r1_ext_ip_name_vpn0"]
  region	= var.region_1b_gcp["gcp_region_1b"]
}


# Creating basic firewall rules permitting ping, ssh and SD-WAN ports:
resource "google_compute_firewall" "region-1b-fw-rules-vpn512" {
  project 		= var.gcp["gcp_project_id"]
  name    		= var.region_1b_security["gce_region_1b_firewall_rule_vpn512"]
  network 		= google_compute_network.region_1b_vpc_network_vpn512.name
  description 	= "Region 1b basic firewall rules VPN512"

  allow {
    protocol 	= "icmp"
  }

  allow {
    protocol 	= "tcp"
    ports    	= ["22", "23456-24156"]
  }

  allow {
    protocol 	= "udp"
    ports    	= ["12346-13046"]
  }

 source_ranges 	= ["128.107.0.0/16", "10.0.0.0/8"]
 
}

resource "google_compute_firewall" "region-1b-fw-rules-vpn0" {
  project 		= var.gcp["gcp_project_id"]
  name    		= var.region_1b_security["gce_region_1b_firewall_rule_vpn0"]
  network 		= google_compute_network.region_1b_vpc_network_vpn0.name
  description 	= "Region 1b basic firewall rules VPN0"

  allow {
    protocol 	= "icmp"
  }

  allow {
    protocol 	= "tcp"
    ports    	= ["22", "23456-24156"]
  }

  allow {
    protocol 	= "udp"
    ports    	= ["12346-13046"]
  }

 source_ranges 	= ["128.107.0.0/16", "10.0.0.0/8"]
 
}

resource "google_compute_firewall" "region-1b-fw-rules-vpn10" {
  project 		= var.gcp["gcp_project_id"]
  name    		= var.region_1b_security["gce_region_1b_firewall_rule_vpn10"]
  network 		= google_compute_network.region_1b_vpc_network_vpn10.name
  description 	= "Region 1b basic firewall rules VPN10"

  allow {
    protocol 	= "icmp"
  }

  allow {
    protocol 	= "tcp"
    ports    	= ["22", "23456-24156"]
  }

  allow {
    protocol 	= "udp"
    ports    	= ["12346-13046"]
  }

 source_ranges 	= ["128.107.0.0/16", "10.0.0.0/8"]
 
}


# Creating router with multiple NICs:
resource "google_compute_instance" "region_1b_sdwan_r1_vm_instance" {
  name         		= var.region_1b_sdwan_router_instance["gce_instance_name"]
  machine_type 		= var.region_1b_sdwan_router_instance["gce_router_vm_flavor"]
  zone    			= var.region_1b_gcp["gcp_region_1b_zone"]
  can_ip_forward 	= true

  boot_disk {
    initialize_params {
      image 		= var.region_1b_sdwan_router_instance["gce_router_image"]
      type 			= "pd-ssd"
    }
  }

  network_interface {
    subnetwork 		= google_compute_subnetwork.region_1b_sdwan_r1_subnet_vpn512.self_link
    access_config {
      nat_ip 		= google_compute_address.region-1b-r1-public-ip-vpn512.address
      network_tier 	= "PREMIUM"
    }
  }

  network_interface {
    subnetwork 		= google_compute_subnetwork.region_1b_sdwan_r1_subnet_vpn0.self_link
    access_config {
      nat_ip 		= google_compute_address.region-1b-r1-public-ip-vpn0.address
      network_tier 	= "PREMIUM"
    }
  }

  network_interface {
    subnetwork 		= google_compute_subnetwork.region_1b_sdwan_r1_subnet_vpn10.self_link
    access_config {
      network_tier 	= "PREMIUM"
    }
  }
  

#  Pass Day 0 cloud init file with basic SD-WAN router configuration:
   metadata_startup_script = file(var.region_1b_sdwan_router_instance["gce_day0_sdwan_router_region_1b_config_file"])


  metadata = {
    ssh-keys = <<EOF
       npitaev:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDGUaIINbJQwwlkscsre2T0L6qH6tHbvit/AZsIj0wy+qBYdpGGQWiosfGq9vxPKexp9u0Mja5s4zWF1HvUKrHJkMNbxss4OeWTaa9WcrgQzyPJwfXTJRlPMv2XSBkV96EECBgJoTBy+LYLULeC1j0bKsLd8/bCjjFws0oJFPerhcL3oomh8lYSCJBnAB+gGS1yrW+JdiGHLAGesNSejmh5ZqQBgc89Q/Fzc8ndmx22VncLxFY8nzZtI9F4Qm9DbnMV8ItK3KcbaL6amnGtEaG5+AWqJYB8d2RzBhsMPhPmUzrTOkBYoPXK1wiMWcG8m6UJTj6nnfmxc7pqcE+GvSXK6uSult/WS3ThbEOqLg4YG8hRc+pXPezU78I6wldmVu5HqsullFHsRyG5wU3NZkj3l7KUAJz2o9buw4nch/Uflfq09vp+3Z1z3rDYn2zWYbhib9HFsC+shnedK0U3ut5fugE61M3/imNJyIpS/vYtS+i2jTWtKXMgNSs1p55aGWc= npitaev@NPITAEV-M-144E
      EOF
    serial-port-enable = "true"
  }
}


# Printing out public IP addresses:
output "gcp_region_1b_r1_public_ip_vpn512" {
  value = google_compute_address.region-1b-r1-public-ip-vpn512.address
}

output "gcp_region_1b_r1_public_ip_vpn0" {
  value = google_compute_address.region-1b-r1-public-ip-vpn0.address
}