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

 # if you want debian
# resource "libvirt_volume" "base_image" {
# name   = "debian_vm_base.img"
# pool   = "default"
# source = "/var/lib/libvirt/images/debian-11-genericcloud-amd64-daily-20250222-2031.qcow2"
# format = "qcow2"
# }
 # if you want debian

resource "libvirt_volume" "base_image" {
  name   = "ubuntu_vm_base.img"
  pool   = "default"
  source = "/var/lib/libvirt/images/noble-server-cloudimg-amd64.img"
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
    content      = templatefile("${path.module}/cloud_init.cfg", {
      ip_address = each.value.ip_address,
      ssh_key    = each.value.ssh_key,
      user_name  = each.value.user_name,
      password   = each.value.password,
      name       = each.value.name
    })
  }
}

resource "libvirt_domain" "vms" {
  for_each = var.vms

  name   = each.value.name
  memory = each.value.memory
  vcpu   = each.value.vcpu

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

