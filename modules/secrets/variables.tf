variable "name" {
  type = string
}

variable "description" {
  type = string
}

variable "secret_string" {
  type = string
  sensitive = true
}

variable "common_tags" {
  type    = map(string)
  default = {}
}
