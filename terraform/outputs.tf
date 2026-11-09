output "ec2_instance_id" {
  description = "ID of the microservices EC2 instance"
  value       = aws_instance.microservices_server.id
}

output "ec2_public_ip" {
  description = "Public IP of the microservices EC2 instance"
  value       = aws_instance.microservices_server.public_ip
}

output "security_group_id" {
  description = "ID of the microservices security group"
  value       = aws_security_group.microservices_sg.id
}

output "user_service_ecr_url" {
  value = aws_ecr_repository.user_service.repository_url
}

output "product_service_ecr_url" {
  value = aws_ecr_repository.product_service.repository_url
}

output "order_service_ecr_url" {
  value = aws_ecr_repository.order_service.repository_url
}
