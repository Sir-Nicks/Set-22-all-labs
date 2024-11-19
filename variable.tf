variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "public_subnet_1_cidr" {
  description = "The CIDR block for the first public subnet"
  default     = "10.0.1.0/24"
}

variable "public_subnet_2_cidr" {
  description = "The CIDR block for the second public subnet"
  default     = "10.0.2.0/24"
}

variable "private_subnet_1_cidr" {
  description = "The CIDR block for the first private subnet"
  default     = "10.0.3.0/24"
}

variable "private_subnet_2_cidr" {
  description = "The CIDR block for the second private subnet"
  default     = "10.0.4.0/24"
}

variable "port_number" {
  description = "The port number for SSH access"
  default     = 22
}

variable "ami_ubuntu" {
  description = "The AMI ID for the Ubuntu instances"
  default     = "ami-0d64bb532e0502c46" // Valid for eu-west-1
}

variable "ami_red" {
  description = "The AMI ID for the RedHat instances"
  default     = "ami-07d4917b6f95f5c2a" // Valid RedHat AMI in eu-west-1
}

