provider aws {
  region = us-east-1
}

# Data Sources (Get existing VPC/Subnets/AMI)
data aws_vpc default {
  default = true
}

data aws_subnets default {
  filter {
    name   = vpc-id
    values = [data.aws_vpc.default.id]
  }
}

data aws_ami amazon_linux {
  most_recent = true
  owners      = [amazon]
  filter {
    name   = name
    values = [al2023-ami-2023.*-x86_64]
  }
}
# Security Group (The Firewall)
resource aws_security_group web_sg {
  name        = terraform-web-sg
  description = Allow HTTP traffic
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = tcp
    cidr_blocks = [0.0.0.0/0]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = [0.0.0.0/0]
  }
}

# The Two Servers
resource "aws_instance" "server_1" {
  ami             = data.aws_ami.amazon_linux.id
  instance_type   = "t2.micro"
  subnet_id       = data.aws_subnets.default.ids[0]
  security_groups = [aws_security_group.web_sg.id]
  tags            = { Name = "Terraform-Server-1" }

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Hello from SERVER 1</h1>" > /var/www/html/index.html
              EOF
}

resource "aws_instance" "server_2" {
  ami             = data.aws_ami.amazon_linux.id
  instance_type   = "t2.micro"
  subnet_id       = data.aws_subnets.default.ids[1]
  security_groups = [aws_security_group.web_sg.id]
  tags            = { Name = "Terraform-Server-2" }

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Hello from SERVER 2</h1>" > /var/www/html/index.html
              EOF
}
# Load Balancer
resource aws_lb my_alb {
  name               = terraform-ping-pong-alb
  internal           = false
  load_balancer_type = application
  security_groups    = [aws_security_group.web_sg.id]
  subnets            = data.aws_subnets.default.ids
}

# Target Group
resource aws_lb_target_group my_tg {
  name     = terraform-target-group
  port     = 80
  protocol = HTTP
  vpc_id   = data.aws_vpc.default.id
}

# Attachments
resource aws_lb_target_group_attachment attach_server_1 {
  target_group_arn = aws_lb_target_group.my_tg.arn
  target_id        = aws_instance.server_1.id
  port             = 80
}

resource aws_lb_target_group_attachment attach_server_2 {
  target_group_arn = aws_lb_target_group.my_tg.arn
  target_id        = aws_instance.server_2.id
  port             = 80
}

# Listener
resource aws_lb_listener front_end {
  load_balancer_arn = aws_lb.my_alb.arn
  port              = 80
  protocol          = HTTP

  default_action {
    type             = forward
    target_group_arn = aws_lb_target_group.my_tg.arn
  }
}

output load_balancer_dns {
  value = aws_lb.my_alb.dns_name
}
