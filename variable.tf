variable "region" {
  type        = string
  description = "Region to Deploy VPC"
  default     = "us-east-2"
}

variable "ami" {
  type        = string
  description = "AMI ID"
  default     = "ami-024e6efaf93d85776"
}

variable "instance" {
  type        = string
  description = "EC2 Instance Type"
  default     = "t2.micro"
}

variable "key_name" {
  type = string
  default = "jenkinskey"
}