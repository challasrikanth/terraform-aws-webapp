variable "public_subnets" {
    type = list 
}
variable "vpc_id" {
    
}


variable "alb_cidr" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}