output "ansible_control_node_ip" {
  value = aws_instance.ansible_server.public_ip
}

output "ubuntu_managed_node_ip" {
  value = aws_instance.ubuntu_server.public_ip
}

output "redhat_managed_node_ip" {
  value = aws_instance.redhat_server.public_ip
}
