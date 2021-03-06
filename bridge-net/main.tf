# libvirt.tf

terraform {
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
      version = "0.6.3"
    }
  }
}

# add the provider
provider "libvirt" {
 uri = "qemu:///system"
}


resource "libvirt_network" "woodez_net" {
  name = "woodez_net"
  mode = "bridge"
  bridge = "br0"
  autostart = "true"
}
