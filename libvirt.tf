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


# create pool
resource "libvirt_pool" "centos" {
 name = "centos-pool"
 type = "dir"
 path = "/vm/centos-pool/"
}

# create image
resource "libvirt_volume" "image-qcow2" {
 name = "CentOS-7-x86_64-GenericCloud"
 pool = libvirt_pool.centos.name
 source ="${path.module}/downloads/CentOS-7-x86_64-GenericCloud.qcow2"
 format = "qcow2"
}

# add cloudinit disk to pool
resource "libvirt_cloudinit_disk" "commoninit" {
 name = "commoninit.iso"
 pool = libvirt_pool.centos.name
 user_data = data.template_file.user_data.rendered
 meta_data = data.template_file.meta_data.rendered
 network_config = data.template_file.network_config.rendered
}

# read the configuration
data "template_file" "user_data" {
 template = file("${path.module}/user-data.yaml")
}

# read the configuration
data "template_file" "meta_data" {
 template = file("${path.module}/meta-data.yaml")
}

# read the configuration
data "template_file" "network_config" {
 template = file("${path.module}/network-config-v1.yaml")
}

# Define KVM domain to create
resource "libvirt_domain" "test-domain" {
 # name should be unique!
   name = "test-vm-centos"
   memory = "1024"
   vcpu = 1
 # add the cloud init disk to share user data
   cloudinit = libvirt_cloudinit_disk.commoninit.id

 # set to default libvirt network
   network_interface {
   network_name = "default"
   }


   disk {
     volume_id = libvirt_volume.image-qcow2.id
   }

   console {
     type = "pty"
     target_type = "serial"
     target_port = "0"
   }

   graphics {
     type = "spice"
     listen_type = "address"
     autoport = true
   }
}