
variable "ENVIRONMENT" {
    type    = string
    default = "Testing"
}
# Amazon Linux in us-east-1 and ubuntu in others
variable "AMIS" {
    type = map
    default = {
        us-east-1 = "ami-00a929b66ed6e0de6"
        us-east-2 = "ami-00a929b66ed6e0de6"
        eu-west-2 = "ami-084568db4383264d4"
        ap-south-1 = "ami-084568db4383264d4"
    }
}

variable "AWS_REGION" {
default = "us-east-2"
}

variable "INSTANCE_TYPE" {
  default = "t2.micro"
}