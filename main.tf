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

resource "libvirt_volume" "base_image" {
  name   = "ubuntu_vm_base.img"
  pool   = "default"
  source = "/var/lib/libvirt/images/jammy-server-cloudimg-amd64.img"
  format = "qcow2"
}

resource "libvirt_volume" "vm_disks" {
  for_each = var.vms

  name           = "${each.value.name}-disk.img"
  pool           = "default"
  base_volume_id = libvirt_volume.base_image.id
  format         = "qcow2"
  size           = each.value.disk_size_gb * 1024 * 1024 * 1024
}

resource "libvirt_cloudinit_disk" "vm_cloudinit" {
  for_each = var.vms

  name           = "${each.value.name}-commoninit"
  pool           = "default"
  user_data      = data.template_cloudinit_config.vm_cloudinit[each.key].rendered
  network_config = templatefile("${path.module}/network_config.yml", { ip_address = each.value.ip_address })
}

data "template_cloudinit_config" "vm_cloudinit" {
  for_each = var.vms

  gzip          = false
  base64_encode = false

  part {
    content_type = "text/cloud-config"
    content      = templatefile("${path.module}/cloud_init.cfg", {})
  }
}

resource "libvirt_domain" "vms" {
  for_each = var.vms

  name   = each.value.name
  memory = 2048
  vcpu   = 2

  cloudinit = libvirt_cloudinit_disk.vm_cloudinit[each.key].id

  disk {
    volume_id = libvirt_volume.vm_disks[each.key].id
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

