# AWS Provider:

provider "aws" {
  alias = "core_1a"
  region = var.aws_core_1a_region
}

provider "aws" {
  alias = "core_2a"
  region = "us-east-2"
}

provider "aws" {
  alias = "region_1a"
  region = var.aws_region_1a_region
}

provider "aws" {
  alias = "region_2a"
  region = var.aws_region_2a_region
}

provider "aws" {
  alias = "region_12_vsmart"
  region = var.aws_region_12_vsmart_region
}


# GCP Provider:

provider "google" {
  credentials 	= file(var.gcp["gcp_credential_file"])
  project 		= var.gcp["gcp_project_id"]
}
