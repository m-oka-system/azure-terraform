variable "common" {
  type = map(string)
  default = {
    prefix   = "terraform"
    env      = "dev"
    location = "japaneast"
  }
}

