variable "region" {
  description = "define the region"
  type    = string
  default = "us-east-1"
}

variable "instance-type" {
  description = "define the instance type"
  default = "t2.micro"
}