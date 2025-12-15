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
