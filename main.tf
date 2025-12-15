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
