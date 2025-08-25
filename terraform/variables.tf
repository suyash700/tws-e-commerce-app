variable "instance_type" {
  type = string
  default = "t2.medium"
  description = "Instance type for the EC2 instance" 
}

variable "region" {
  type = string
  default = "eu-west-1"
}
