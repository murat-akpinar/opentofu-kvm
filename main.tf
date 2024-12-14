terraform {
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.6.14"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}

# Temel imajı havuza aktar
resource "libvirt_volume" "ubuntu_vm_1_base_image" {
  name   = "ubuntu_vm_1-base.img"
  pool   = "default"
  source = "/var/lib/libvirt/images/jammy-server-cloudimg-amd64.img"
  format = "qcow2"
}

# Yeni bir disk oluştur ve 30 GB olarak ayarla
resource "libvirt_volume" "ubuntu_vm_1_disk" {
  name           = "ubuntu_vm_1-disk.img"
  pool           = "default"
  base_volume_id = libvirt_volume.ubuntu_vm_1_base_image.id
  size           = 30 * 1024 * 1024 * 1024 # 30 GB
  format         = "qcow2"
}

resource "libvirt_cloudinit_disk" "ubuntu_vm_1_commoninit" {
  name           = "ubuntu_vm_1-commoninit"
  pool           = "default"
  user_data      = data.template_cloudinit_config.ubuntu_vm_1_commoninit.rendered
  network_config = file("${path.module}/network_config.yml")
}

data "template_cloudinit_config" "ubuntu_vm_1_commoninit" {
  gzip          = false
  base64_encode = false

  part {
    content_type = "text/cloud-config"
    content      = templatefile("${path.module}/cloud_init.cfg", {})
  }
}

resource "libvirt_domain" "ubuntu_vm_1" {
  name   = "ubuntu_vm_1"
  memory = "2048"
  vcpu   = 2

  cloudinit = libvirt_cloudinit_disk.ubuntu_vm_1_commoninit.id

  disk {
    volume_id = libvirt_volume.ubuntu_vm_1_disk.id
  }

  network_interface {
    bridge = "br0"
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
