# opentofu-kvm

KVM Install 

```bash
sudo apt update
sudo apt install -y qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils virt-manager
```

User Group Setting

```bash
sudo usermod -aG libvirt $(whoami)
sudo usermod -aG kvm $(whoami)
```

Libvirt Service
```
sudo systemctl enable --now libvirtd
```