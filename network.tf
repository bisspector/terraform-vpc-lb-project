resource "aws_internet_gateway" "prod-igw" {
  vpc_id = aws_vpc.prod-vpc.id
  tags = {
    Name = "prod-igw"
  }
}

resource "aws_eip" "nat-eip" {
  count = var.availability_zones_count
  vpc   = true

  tags = {
    Name = "nat-eip-${count.index}"
  }
}

resource "aws_nat_gateway" "prod-natgw" {
  count = var.availability_zones_count

  allocation_id = aws_eip.nat-eip[count.index].id
  subnet_id     = aws_subnet.prod-subnet-public[count.index].id

  tags = {
    Name = "prod-natgw-${count.index}"
  }
}

resource "aws_route_table" "prod-public-crt" {
  vpc_id = aws_vpc.prod-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.prod-igw.id
  }

  tags = {
    Name = "prod-public-crt"
  }
}

resource "aws_route_table" "prod-private-crt" {
  count = var.availability_zones_count

  vpc_id = aws_vpc.prod-vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.prod-natgw[count.index].id
  }

  tags = {
    Name = "prod-private-crt-${count.index}"
  }
}

resource "aws_route_table_association" "prod-crta-public-subnet" {
  count = var.availability_zones_count

  subnet_id      = aws_subnet.prod-subnet-public[count.index].id
  route_table_id = aws_route_table.prod-public-crt.id
}

resource "aws_route_table_association" "prod-crta-private-subnet" {
  count = var.availability_zones_count

  subnet_id      = aws_subnet.prod-subnet-private[count.index].id
  route_table_id = aws_route_table.prod-private-crt[count.index].id
}

resource "aws_lb" "app" {
  name               = "main-app-${random_pet.app.id}-lb"
  internal           = false
  load_balancer_type = "application"
  subnets            = aws_subnet.prod-subnet-public.*.id
  security_groups    = [aws_security_group.webservers.id]
}

resource "aws_lb_listener" "app" {
  load_balancer_arn = aws_lb.app.arn
  port = "80"
  protocol = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.blue.arn
  }
}

resource "aws_security_group" "webservers" {
  vpc_id = aws_vpc.prod-vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ssh-allowed"
  }
}
