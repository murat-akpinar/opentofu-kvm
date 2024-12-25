variable "vms" {
  type = map(object({
    name         = string
    ip_address   = string
    disk_size_gb = number
    memory       = number
    vcpu         = number
    ssh_key      = string
    user_name    = string
    password     = string
  }))
  default = {
    "vm1" = {
      name         = "ubuntu_vm_1"
      ip_address   = "192.168.1.15"
      disk_size_gb = 60
      memory       = 4096
      vcpu         = 4
      ssh_key      = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDePiBj1GQhJICWdez6MPydRH/MzM01D2SG6Chz/tn9RSOqvE7ve7tA49RHg4W7FQM9SAhXmozqojq0PJUIgqPIIK6ljlE90bL6WZ0OaSRNTBWX/szYHp82WSfnnU8FidCE8fqYBHvBlIqgRfW4rvbDvwRobDNOPPPU23S7yu1mD6rChnOMAJ8KnGooEZueBdDqrFvPQ49kYkir/ieuGFMk0ykLWQgs8UZjHR0aylQFyecBasGZlUkPvtapv2LxcndD2IX1qh8392uxf4mgUqh1qMfrQmRgwDc69s+6+OWBYFDuyWCki/yO2VoVMtr7W85N1Ct8b+l49VnyRulEx5w3 shyuuhei@FoxHound"
      user_name    = "murat"
      password     = "$6$FDy3tNnSg4Ge/cHD$IuKxFFvW77QAOULVp1ody3ExjIEoWmdSFmCkrl8CoMfvNBdW.snT44BoJFf0SNg9z80toTt82z44rs5URe71b."
    },
    "vm2" = {
      name         = "ubuntu_vm_2"
      ip_address   = "192.168.1.16"
      disk_size_gb = 60
      memory       = 4096
      vcpu         = 4
      ssh_key      = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDePiBj1GQhJICWdez6MPydRH/MzM01D2SG6Chz/tn9RSOqvE7ve7tA49RHg4W7FQM9SAhXmozqojq0PJUIgqPIIK6ljlE90bL6WZ0OaSRNTBWX/szYHp82WSfnnU8FidCE8fqYBHvBlIqgRfW4rvbDvwRobDNOPPPU23S7yu1mD6rChnOMAJ8KnGooEZueBdDqrFvPQ49kYkir/ieuGFMk0ykLWQgs8UZjHR0aylQFyecBasGZlUkPvtapv2LxcndD2IX1qh8392uxf4mgUqh1qMfrQmRgwDc69s+6+OWBYFDuyWCki/yO2VoVMtr7W85N1Ct8b+l49VnyRulEx5w3 shyuuhei@FoxHound"
      user_name    = "murat"
      password     = "$6$FDy3tNnSg4Ge/cHD$IuKxFFvW77QAOULVp1ody3ExjIEoWmdSFmCkrl8CoMfvNBdW.snT44BoJFf0SNg9z80toTt82z44rs5URe71b."
    }
  }
}

