resource "aws_key_pair" "test-key-pair" {
  key_name   = "test-key-pair"
  public_key = file(var.PUBLIC_KEY_PATH)
}

resource "aws_instance" "blue" {
  count = var.availability_zones_count

  ami                    = data.aws_ami.latest-ubuntu.id
  instance_type          = "t2.micro"

  subnet_id              = aws_subnet.prod-subnet-private[count.index].id
  vpc_security_group_ids = [aws_security_group.webservers.id]
  user_data = templatefile("${path.module}/install_httpd.sh", {
    file_content = "version 1.0 - #${count.index}"
  })

  key_name = aws_key_pair.test-key-pair.id

  tags = {
    Name = "version-1.0-${count.index}"
  }
}

resource "aws_lb_target_group" "blue" {
  name     = "blue-tg-${random_pet.app.id}-lb"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.prod-vpc.id

  health_check {
    port     = 80
    protocol = "HTTP"
    timeout  = 5
    interval = 10
  }
}

resource "aws_lb_target_group_attachment" "blue" {
  count            = length(aws_instance.blue)
  target_group_arn = aws_lb_target_group.blue.arn
  target_id        = aws_instance.blue[count.index].id
  port             = 80
}

output "lb_dns_name" {
  value = aws_lb.app.dns_name
}
