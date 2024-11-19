// AWS Provider Configuration
provider "aws" {
  region = "eu-west-1"
}

// Subnet Configuration
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

// Save Private Key Locally
resource "local_file" "private_key" {
  content         = tls_private_key.keypair.private_key_pem
  filename        = "kube-key.pem"
  file_permission = "600"
}

// AWS Key Pair
resource "aws_key_pair" "keypair" {
  key_name   = "kube-key"
  public_key = tls_private_key.keypair.public_key_openssh
}

// Security Group for Cluster
resource "aws_security_group" "kube_sg" {
  name        = "kube-cluster-sg"
  description = "Allow inbound traffic for Kubernetes Cluster"

  ingress {
    from_port   = 0
    to_port     = 65535
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
    Name = "kube-cluster-sg"
  }
}

// EC2 Instance: Master Node
resource "aws_instance" "master" {
  ami                    = "ami-0d64bb532e0502c46"
  instance_type          = "t2.medium"
  vpc_security_group_ids = [aws_security_group.kube_sg.id]
  subnet_id              = aws_subnet.default_subnet.id
  key_name               = aws_key_pair.keypair.key_name
  associate_public_ip_address = true
  user_data              = file("./master-userdata.sh")

  tags = {
    Name = "master-node"
  }
}

// EC2 Instances: Worker Nodes
resource "aws_instance" "worker" {
  count                  = 2
  ami                    = "ami-0d64bb532e0502c46"
  instance_type          = "t2.medium"
  vpc_security_group_ids = [aws_security_group.kube_sg.id]
  subnet_id              = aws_subnet.default_subnet.id
  key_name               = aws_key_pair.keypair.key_name
  associate_public_ip_address = true
  user_data              = file("./worker-userdata.sh")

  tags = {
    Name = "worker-node-${count.index}"
  }
}

// Outputs
output "master" {
  value = aws_instance.master.public_ip
}
output "worker_nodes" {
  value = aws_instance.worker.*.public_ip
}
