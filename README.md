
# OpenTofu-KVM

OpenTofu-KVM, OpenTofu (Terraform alternatifi) kullanarak KVM üzerinde sanal makinelerin (VM) oluşturulmasını ve yönetimini otomatikleştiren bir repodur. Bu rehber, projeyi nasıl kuracağınızı ve kullanacağınızı açıklar.

## Gereksinimler

Bu repoyu kullanmadan önce, aşağıdaki yazılımların kurulu olduğu bir KVM sunucusuna sahip olduğunuzdan emin olun:

### KVM ve Gerekli Araçların Kurulumu

```bash
sudo apt update
sudo apt install -y qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils virt-manager genisoimage
```

### Kullanıcıyı Gerekli Gruplara Ekleme

```bash
sudo usermod -aG libvirt $(whoami)
sudo usermod -aG kvm $(whoami)
```

> **Not:** Bu komutları çalıştırdıktan sonra, değişikliklerin etkili olması için oturumu kapatıp tekrar açmanız gerekir.

### Libvirt Servisini Etkinleştirme ve Başlatma

```bash
sudo systemctl enable --now libvirtd
```

---

## Depo Genel Bakış

Bu repo, KVM hypervisor üzerinde sanal makineler oluşturmak ve yönetmek için gerekli dosyaları içerir. Temel bileşenler şunlardır:

- **variables.tf**: VM sayısını, IP adreslerini, disk boyutlarını ve diğer parametreleri yapılandırmak için kullanılan değişkenleri tanımlar.
- **network_config.yml**: Cloud-init için ağ yapılandırmasını sağlar.
- **cloud_init.cfg**: Oluşturulan sanal makinelerin kullanıcı, parola ve SSH yapılandırmalarını içerir.

---

## `variables.tf` Dosyasını Anlama

`variables.tf` dosyası, oluşturulacak sanal makineler için dinamik yapılandırma bilgilerini içerir. İşte yapının açıklaması:

```hcl
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
      ssh_key      = "ssh-rsa AAAAB3...YourKeyHere"
      user_name    = "murat"
      password     = "$6$random-salt$hashed-password"
    },
    "vm2" = {
      name         = "ubuntu_vm_2"
      ip_address   = "192.168.1.16"
      disk_size_gb = 60
      memory       = 4096
      vcpu         = 4
      ssh_key      = "ssh-rsa AAAAB3...YourKeyHere"
      user_name    = "murat"
      password     = "$6$random-salt$hashed-password"
    }
  }
}
```

### Temel Öğeler

- **name**: Sanal makinenin adı.
- **ip_address**: Sanal makineye atanacak statik IP adresi.
- **disk_size_gb**: Sanal makine için ayrılacak disk boyutu (GB).
- **memory**: Sanal makine belleği (MB).
- **vcpu**: Sanal makine işlemci sayısı.
- **ssh_key**: SSH public anahtar.
- **user_name**: Kullanıcı adı.
- **password**: Kullanıcı parolasısını `openssl passwd -6` komutu ile oluşturup ekleyebilirsiniz


---

## `network_config.yml` Dosyasını Anlama

`network_config.yml` dosyası, sanal makineler için ağ yapılandırmasını tanımlar. Örnek bir dosya aşağıda verilmiştir:

```yaml
version: 2
ethernets:
  ens3:
    dhcp4: no
    addresses:
      - ${ip_address}/24
    gateway4: 192.168.1.1
    nameservers:
      addresses:
        - 8.8.8.8
        - 8.8.4.4
```

---

## `cloud_init.cfg` Dosyasını Anlama

`cloud_init.cfg`, sanal makineler için kullanıcı ve SSH yapılandırmalarını sağlar. Örnek bir dosya aşağıda verilmiştir:

```yaml
#cloud-config
preserve_hostname: true
hostname: ${name}

users:
  - name: ${user_name}
    sudo: ALL=(ALL) NOPASSWD:ALL
    groups: sudo
    home: /home/${user_name}
    shell: /bin/bash
    lock_passwd: false
    passwd: ${password}
    ssh_authorized_keys:
      - ${ssh_key}
  - name: root
    ssh_authorized_keys:
      - ${ssh_key}
    lock_passwd: false
    passwd: ${password}

ssh_pwauth: true
disable_root: false

network:
  version: 2
  ethernets:
    ens3:
      dhcp4: false
      addresses:
        - ${ip_address}/24
      gateway4: 192.168.1.1
      nameservers:
        addresses:
          - 8.8.8.8
          - 8.8.4.4
```

---

## Parola Hashleme

Cloud-Init yapılandırmasında kullanılan parolaların güvenli bir şekilde hashlenmesi gerekir. Parolanızı hashlemek için aşağıdaki komutu kullanabilirsiniz:

```bash
openssl passwd -6
```

Bu komut, SHA-512 ile hashlenmiş bir parola üretir. Çıktıyı `variables.tf` dosyasındaki `password` alanına ekleyebilirsiniz.

---

## Kullanım

### Adım 1: Reponun Klonlanması

```bash
git clone https://github.com/murat-akpinar/opentofu-kvm.git
cd opentofu-kvm
```

### Adım 2: Değişkenlerin Yapılandırılması

`variables.tf` dosyasını düzenleyerek VM sayısını, IP adreslerini, disk boyutlarını, bellek ve CPU gibi parametreleri tanımlayın.

### Adım 3: OpenTofu Yapılandırmasını Başlatma ve Uygulama

```bash
opentofu init
opentofu apply
```

> **Not:** KVM sunucunuzun belirtilen VM sayısını destekleyecek yeterli kaynağa sahip olduğundan emin olun.

---

## Örnek Çalışma Akışı

1. **KVM Kurulumu**: Gerekli yazılımları yükleyin ve libvirt servisini etkinleştirin.
2. **Konfigürasyon**: `variables.tf`, `cloud_init.cfg`, ve `network_config.yml` dosyalarını ihtiyacınıza göre düzenleyin.
3. **OpenTofu Çalıştırma**: OpenTofu ile VM'leri oluşturun.
4. **Doğrulama**: VM'lerin yapılandırılan ağ ve kullanıcı ayarlarıyla çalışır durumda olduğunu kontrol edin.

---

## Sorun Giderme

- **SSH Erişim Sorunları**: `ssh_key` veya `user_name` ayarlarını kontrol edin.
- **Ağ Sorunları**: `network_config.yml` dosyasındaki ağ geçidi ve DNS ayarlarını doğrulayın.
- **Parola Sorunları**: `password` alanının SHA-512 formatında hashlenmiş olduğundan emin olun.

Bu rehber ile OpenTofu-KVM kullanarak sanal makinelerinizi kolayca oluşturabilir ve yönetebilirsiniz. 😊
