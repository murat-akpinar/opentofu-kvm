variable "vms" {
  type = map(object({
    name         = string
    ip_address   = string
    disk_size_gb = number
  }))
  default = {
    "vm1" = {
      name         = "ubuntu_vm_1"
      ip_address   = "192.168.1.15"
      disk_size_gb = 30
    },
    "vm2" = {
      name         = "ubuntu_vm_2"
      ip_address   = "192.168.1.16"
      disk_size_gb = 40
    }
    "vm3" = {
      name         = "ubuntu_vm_3"
      ip_address   = "192.168.1.17"
      disk_size_gb = 40
    }

  }
}

