
variable "ami" {

}
variable "instance_type" {

}
variable "private_subnets" { 
    type = list(string)

}
variable "target_group_arn" {

}   

variable "alb_sg_id" {
  type        = string
}

variable "vpc_id" {
  type        = string
}
