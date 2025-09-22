terraform {
  backend "s3" {
    bucket  = "my-terraform-state-bucket-gmricardo3"
    key     = "terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_security_group" "ec2_sg" {
  name        = "ec2-httpd-sg"
  description = "Allow HTTP traffic"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] // Permite acceso desde cualquier IP
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["186.154.174.170/32"] // Solo tu IP, por seguridad
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] // Permite salida a cualquier IP
  }
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

locals {
  server1_html = templatefile("${path.module}/presentation.html.tpl", { server_name = "1" })
  server2_html = templatefile("${path.module}/presentation.html.tpl", { server_name = "2" })
}

resource "aws_instance" "first_instance" {
  ami           = "ami-0886832e6b5c3b9e2" // AMI Amazon Linux 2
  instance_type = "t2.micro"
  subnet_id     = data.aws_subnets.default.ids[0]
  security_groups = [aws_security_group.ec2_sg.id]
  key_name = "keyPairGmricardo3"

  // Script de inicialización para instalar httpd y mostrar la IP privada
  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd
    systemctl start httpd
    systemctl enable httpd
    sleep 5
    TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
    PRIVATE_IP=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/local-ipv4)
    cat <<EOT > /var/www/html/index.html
      ${local.server1_html}
    <h3>Private IP: $PRIVATE_IP</h3>
    EOT
  EOF

  tags = {
    Name        = "FirstInstance"
    Environment = var.environment
  }
}

resource "aws_instance" "second_instance" {
  ami           = "ami-0886832e6b5c3b9e2"
  instance_type = "t2.micro"
  subnet_id     = data.aws_subnets.default.ids[1]
  security_groups = [aws_security_group.ec2_sg.id]
  key_name = "keyPairGmricardo3"

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd
    systemctl start httpd
    systemctl enable httpd
    sleep 5
    TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
    PRIVATE_IP=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/local-ipv4)
    cat <<EOT > /var/www/html/index.html
      ${local.server2_html}
      <h3>Private IP: $PRIVATE_IP</h3>
    EOT
  EOF

  tags = {
    Name        = "SecondInstance"
    Environment = var.environment
  }
}

resource "aws_lb" "app_lb" {
  name               = "app-lb"
  internal           = false // Público
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ec2_sg.id]
  subnets            = data.aws_subnets.default.ids
}

resource "aws_lb_target_group" "app_tg" {
  name     = "app-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id
}

resource "aws_lb_listener" "app_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

resource "aws_lb_target_group_attachment" "first_instance" {
  target_group_arn = aws_lb_target_group.app_tg.arn
  target_id        = aws_instance.first_instance.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "second_instance" {
  target_group_arn = aws_lb_target_group.app_tg.arn
  target_id        = aws_instance.second_instance.id
  port             = 80
}