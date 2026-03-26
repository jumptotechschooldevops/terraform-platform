variable "name_prefix" {
  type = string
}

variable "ami_id" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "security_group_ids" {
  type = list(string)
}

variable "target_group_arns" {
  type = list(string)
}

variable "desired_capacity" {
  type = number
}

variable "min_size" {
  type = number
}

variable "max_size" {
  type = number
}

variable "key_name" {
  type    = string
  default = null
}

variable "user_data" {
  type = string
}

variable "common_tags" {
  type    = map(string)
  default = {}
}
