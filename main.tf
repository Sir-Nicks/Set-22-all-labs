// Use default VPC
data "aws_vpc" "default" {
  default = true
}

// Public subnet 
data "aws_subnets" "public_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}


// Maven Instance
resource "aws_instance" "maven" {
  ami           = var.ami_red
  instance_type = "t2.medium"
  key_name      = aws_key_pair.key.id
  vpc_security_group_ids = [aws_security_group.maven_sg.id]
  associate_public_ip_address = true
  user_data = file("./userdata.sh")
}

// Production Instance
resource "aws_instance" "prod" {
  ami           = var.ami_red
  instance_type = "t2.medium"
  key_name      = aws_key_pair.key.id
  vpc_security_group_ids = [aws_security_group.prod_sg.id]
  associate_public_ip_address = true
  user_data = file("./userdata2.sh")
  tags = {
    Name = "host-server"
  }
}

// Keypair
resource "aws_key_pair" "key" {
  key_name   = "demo_key"
  public_key = tls_private_key.key.public_key_openssh
}

// Maven Security Group
resource "aws_security_group" "maven_sg" {
  name        = "maven_sg"
  description = "Security group for Maven instance"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

// Production Security Group
resource "aws_security_group" "prod_sg" {
  name        = "prod_sg"
  description = "Security group for production server"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

// RSA key generation
resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

// Private key local storage
resource "local_file" "key" {
  content        = tls_private_key.key.private_key_pem
  filename       = "demo-key.pem"
  file_permission = 600
}

output "maven_ip" {
  value = aws_instance.maven.public_ip
}

output "prod_ip" {
  value = aws_instance.prod.public_ip
}
