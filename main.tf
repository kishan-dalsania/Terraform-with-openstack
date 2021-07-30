terraform {
  required_version = ">= 0.14.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.35.0"
    }
  }
}

# Configure the OpenStack Provider
provider "openstack" {
  //use_octavia = true
  # endpoint_overrides = {
  #   "network"  = "http://172.31.28.43:9696/v2.0/"
  #   # "volumev2" = var.volume_v2_url
  #   # "volumev3" = var.volume_v3_url
  #   # "image"    = var.image_url
  #   # "compute"  = var.compute_url
  # }
}

resource "openstack_compute_keypair_v2" "terraform" {
  name       = "terraform"
  public_key = file("${var.ssh_key_file}")
}

resource "openstack_networking_network_v2" "terraform" {
  name           = "terraform"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "terraform" {
  name            = "terraform"
  network_id      = openstack_networking_network_v2.terraform.id
  cidr            = "10.0.0.0/24"
  ip_version      = 4
  dns_nameservers = ["8.8.8.8", "8.8.4.4"]
}

resource "openstack_networking_router_v2" "terraform" {
  name                = "terraform"
  admin_state_up      = "true"
  external_network_id = var.external_gateway
}

resource "openstack_networking_router_interface_v2" "terraform" {
  router_id = openstack_networking_router_v2.terraform.id
  subnet_id = openstack_networking_subnet_v2.terraform.id
}

resource "openstack_networking_secgroup_v2" "terraform" {
  name        = "terraform"
  description = "Security group for the Terraform example instances"
  rule {
    from_port   = 22
    to_port     = 22
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = 80
    to_port     = 80
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = -1
    to_port     = -1
    ip_protocol = "icmp"
    cidr        = "0.0.0.0/0"
  }
}

resource "openstack_networking_floatingip_v2" "terraform" {
  pool = var.pool
}

resource "openstack_compute_instance_v2" "terraform" {
  name            = "terraform"
  image_name      = var.image
  flavor_name     = var.flavor
  key_pair        = openstack_compute_keypair_v2.terraform.name
  security_groups = ["${openstack_networking_secgroup_v2.terraform.name}"]
  floating_ip     = openstack_networking_floatingip_v2.terraform.address
  network {
    uuid = openstack_networking_network_v2.terraform.id
  }

  # provisioner "remote-exec" {
  # connection {
  # user = "${var.ssh_user_name}"
  # key_file = "${var.ssh_key_file}"
  # }

  # inline = [
  # "sudo apt-get -y update",
  # "sudo apt-get -y install nginx",
  # "sudo service nginx start"
  # ]
  # }
}

output "address" {
  value = openstack_networking_floatingip_v2.terraform.address
}
