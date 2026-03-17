variable "aws_region" {
  description = "The AWS region to deploy resources in."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
    default = "devops-master"
}

variable "vpc_cidr" {
    default = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
    default = "10.0.1.0/24"
}

variable "public_subnet_cidr_2" {
    default = "10.0.2.0/24"
}

variable "container_image" {
    description = "Docker image"
}

variable "az1" {
    description = "Availability Zone 1"
    default     = "us-east-1a"
}

variable "az2" {
    description = "Availability Zone 2"
    default     = "us-east-1b"
}