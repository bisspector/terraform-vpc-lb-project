resource "aws_vpc" "prod-vpc" {
  cidr_block       = var.main_vpc_cidr
  instance_tenancy = "default"

  tags = {
    Name = "prod-vpc"
  }
}

resource "aws_subnet" "prod-subnet-public" {
  count = var.availability_zones_count

  vpc_id                  = aws_vpc.prod-vpc.id
  cidr_block              = cidrsubnet(aws_vpc.prod-vpc.cidr_block, 8, count.index)
  map_public_ip_on_launch = true // Public subnet
  availability_zone       = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "prod-subnet-public-${count.index}"
  }
}

resource "aws_subnet" "prod-subnet-private" {
  count = var.availability_zones_count

  vpc_id            = aws_vpc.prod-vpc.id
  cidr_block        = cidrsubnet(aws_vpc.prod-vpc.cidr_block, 8, var.availability_zones_count + count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "prod-subnet-private-${count.index}"
  }
}
