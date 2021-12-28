variable "AWS_REGION" {
  default = "eu-central-1"
}

variable "PRIVATE_KEY_PATH" {
  default = "security/test-key-pair"
}

variable "PUBLIC_KEY_PATH" {
  default = "security/test-key-pair.pub"
}

variable "main_vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "availability_zones_count" {
  default = 2
}

resource "random_pet" "app" {
  length    = 2
  separator = "-"
}

data "aws_ami" "latest-ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}
