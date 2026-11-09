terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Existing ECR repositories
resource "aws_ecr_repository" "user_service" {
  name                 = "user-service"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "product_service" {
  name                 = "product-service"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "order_service" {
  name                 = "order-service"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

# Existing security group
resource "aws_security_group" "microservices_sg" {
  name        = "launch-wizard-1"
  description = "launch-wizard-1 created 2026-11-05T04:25:38.106Z"
  vpc_id      = "vpc-012328939d1a38678"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    ignore_changes = all
  }
}

# Existing EC2 instance
resource "aws_instance" "microservices_server" {
  ami                    = "ami-0c24c764e44ed98f2"
  instance_type          = var.instance_type
  subnet_id              = "subnet-0aee8e00d4c7ee71e"
  vpc_security_group_ids = ["sg-01860aa24428c98d2"]
  key_name               = "micro"
  iam_instance_profile   = "ec2-ecr-access-role"

  lifecycle {
    ignore_changes = all
  }
}

# Import existing resources into Terraform state
import {
  to = aws_ecr_repository.user_service
  id = "user-service"
}

import {
  to = aws_ecr_repository.product_service
  id = "product-service"
}

import {
  to = aws_ecr_repository.order_service
  id = "order-service"
}

import {
  to = aws_security_group.microservices_sg
  id = "sg-01860aa24428c98d2"
}

import {
  to = aws_instance.microservices_server
  id = "i-00955cc9c357d6856"
}
