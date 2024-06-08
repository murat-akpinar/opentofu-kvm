terraform {
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.6.14"
    }
  }
}

provider "libvirt" {
  uri = "qemu+ssh://murat@192.168.1.105/system"
}

resource "libvirt_volume" "ubuntu_img" {
  name   = "jammy-server-cloudimg-amd64-disk-kvm.img"
  pool   = "default"
  source = "iso/jammy-server-cloudimg-amd64-disk-kvm.img"
  format = "qcow2"
}

resource "libvirt_cloudinit_disk" "commoninit" {
  name           = "commoninit.iso"
  pool           = "default"
  user_data      = data.template_cloudinit_config.commoninit.rendered
  network_config = file("${path.module}/network_config.yml")
}

data "template_cloudinit_config" "commoninit" {
  gzip          = false
  base64_encode = false

  part {
    content_type = "text/cloud-config"
    content      = templatefile("${path.module}/cloud_init.cfg", {})
  }
}

resource "libvirt_domain" "ubuntu_vm" {
  name   = "ubuntu-22.04"
  memory = "2048"
  vcpu   = 2

  cloudinit = libvirt_cloudinit_disk.commoninit.id

  disk {
    volume_id = libvirt_volume.ubuntu_img.id
  }

  network_interface {
    network_name = "default"
  }

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  graphics {
    type = "spice"
  }

  boot_device {
    dev = ["hd"]
  }

  autostart = true
}
