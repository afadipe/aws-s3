variable "env" {
  type    = string
  default = "Dev-Test"
}
#region
variable "region" {
  type    = string
  default = "eu-north-1"
}
#region
variable "aws-destination-region" {
  type    = string
  default = "eu-central-1"
}

#versioning
variable "versioning" {
  type    = string
  default = "Enabled"
}

variable "create_vpc" {
  type    = bool
  default = true
}