# Configure the DigitalOcean Provider
provider "digitalocean" {
}

terraform {
  backend "s3" {}
}

data "template_file" "user_data" {
  template = "${file("${path.module}/user_data.sh.tpl")}"
  vars = {
    hostname = var.hostname
    domain = var.domain
    certbot_email = var.certbot_email
  }
}

resource "digitalocean_droplet" "bookstack_server" {
  image     = "ubuntu-18-04-x64"
  name      = var.hostname
  region    = var.droplet_region
  size      = var.droplet_size
  ssh_keys  = var.ssh_keys
  tags      = var.tags
  user_data = data.template_file.user_data.rendered
}

resource "digitalocean_record" "bookstack_server" {
  domain = var.domain
  name   = var.hostname
  type   = "A"
  value  = digitalocean_droplet.bookstack_server.ipv4_address
}

output "bookstack_server" {
    value = digitalocean_droplet.bookstack_server.ipv4_address
}
