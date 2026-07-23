####################################
# Default VPC
####################################

data "aws_vpc" "default" {
  default = true
}

####################################
# Default Subnet
####################################

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

####################################
# Ubuntu 24.04 LTS AMI
####################################

data "aws_ami" "ubuntu" {
  most_recent = true

  owners = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

####################################
# Key Pair
####################################

resource "aws_key_pair" "practice" {
  key_name   = "practice-key"
  public_key = file(var.public_key_path)
}

####################################
# Security Group
####################################

resource "aws_security_group" "practice_sg" {

  name        = "practice-sg"
  description = "Security Group for Practice Project"

  ingress {

    description = "SSH"

    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = ["0.0.0.0/0"]

  }

  ingress {

    description = "HTTP"

    from_port = 80
    to_port   = 80
    protocol  = "tcp"

    cidr_blocks = ["0.0.0.0/0"]

  }

  ingress {

    description = "HTTPS"

    from_port = 443
    to_port   = 443
    protocol  = "tcp"

    cidr_blocks = ["0.0.0.0/0"]

  }

  egress {

    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = ["0.0.0.0/0"]

  }

  tags = {
    name = "practice-sg"
  }

}

####################################
# EC2 Instance
####################################

resource "aws_instance" "practice" {

  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  subnet_id = "subnet-0618f0ef4bb6b5259"

  vpc_security_group_ids = [
    aws_security_group.practice_sg.id
  ]

  key_name = aws_key_pair.practice.key_name

  associate_public_ip_address = true

  tags = {
    Name = var.instance_name
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens = "required"
  }

}


output "public_ip" {
  value = aws_instance.practice.public_ip
}

output "public_dns" {
  value = aws_instance.practice.public_dns
}