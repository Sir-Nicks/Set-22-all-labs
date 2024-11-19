// AWS Provider Configuration
provider "aws" {
  region = "eu-west-1"
}

// VPC and Subnet Configuration
resource "aws_subnet" "default_subnet" {
  vpc_id                  = "vpc-0f7a985c4a51dd38f" 
  cidr_block              = "172.31.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "eu-west-1a"

  tags = {
    Name = "default-subnet"
  }
}

// RSA Key Pair
resource "tls_private_key" "keypair" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

// Create Private Key File
resource "local_file" "private_key" {
  content         = tls_private_key.keypair.private_key_pem
  filename        = "prom-key.pem"
  file_permission = "600"
}

// EC2 KeyPair
resource "aws_key_pair" "keypair" {
  key_name   = "pros-keypair"
  public_key = tls_private_key.keypair.public_key_openssh
}

// Security Group for Prometheus and Grafana
resource "aws_security_group" "ec2_sg" {
  name        = "prom_graf_sg"
  description = "Allow inbound traffic for Prometheus and Grafana"

  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Prometheus"
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Node Exporter Port"
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Grafana"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ec2-sg"
  }
}

// EC2 Instance for Prometheus and Grafana
resource "aws_instance" "prom_graf" {
  ami                    = "ami-0d64bb532e0502c46" // Ubuntu AMI
  instance_type          = "t2.medium"
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  key_name               = aws_key_pair.keypair.key_name
  associate_public_ip_address = true
  subnet_id              = aws_subnet.default_subnet.id
  user_data              = templatefile("prom-graf-userdata.sh", {
    ec2_webserver_ip = aws_instance.ec2_server.public_ip
  })

  tags = {
    Name = "prom-graf-server"
  }
}

// EC2 Instance for General Web Server
resource "aws_instance" "ec2_server" {
  ami                    = "ami-0d64bb532e0502c46" // Ubuntu AMI
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  key_name               = aws_key_pair.keypair.key_name
  associate_public_ip_address = true
  subnet_id              = aws_subnet.default_subnet.id
  user_data              = file("./ec2-server-userdata.sh")

  tags = {
    Name = "ec2-server"
  }
}

// Outputs
output "prom_graf_ip" {
  value = aws_instance.prom_graf.public_ip
}

output "ec2_ip" {
  value = aws_instance.ec2_server.public_ip
}
