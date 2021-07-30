variable "image" {
  default = "cirros-0.5.2-x86_64-disk"
}

variable "flavor" {
  default = "m1.small"
}

variable "ssh_key_file" {
  default = ".ssh/id_rsa.terraform.pub"
}

variable "ssh_user_name" {
  default = "ubuntu"
}

variable "external_gateway" {
    default = "49d1c133-9a0c-4344-9453-d27a7264e1b6"
}

variable "pool" {
  default = "public"
}
