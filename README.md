
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

## Depo Genel Bakış

Bu repo, KVM hypervisor üzerinde sanal makineler oluşturmak ve yönetmek için gerekli dosyaları içerir. Temel bileşenler şunlardır:

- **variables.tf**: VM sayısını, IP adreslerini, disk boyutlarını ve diğer parametreleri yapılandırmak için kullanılan değişkenleri tanımlar.
- **network_config.yml**: Cloud-init için ağ yapılandırmasını sağlar.
- **cloud_config.yml**: Oluşturulan sanal makinelerin kullanıcı ve SSH yapılandırmalarını içerir.

## `variables.tf` Dosyasını Anlama
`variables.tf` dosyası, oluşturulacak sanal makineler için dinamik yapılandırma bilgilerini içerir. İşte yapının açıklaması:

```hcl
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
    },
    "vm3" = {
      name         = "ubuntu_vm_3"
      ip_address   = "192.168.1.17"
      disk_size_gb = 40
    }
  }
}
```

### Temel Öğeler
- **variable "vms"**: Sanal makinelerin yapılandırmasını tanımlar.
  - **type**: Değişken türünü belirtir. Burada bir `map` içinde nesneler kullanılır.
  - **name**: Sanal makinenin adı.
  - **ip_address**: Sanal makineye atanacak statik IP adresi.
  - **disk_size_gb**: Sanal makine için ayrılacak disk boyutu (GB).
- **default**: Varsayılan yapılandırmaları tanımlar. Her bir VM için ayrı bir giriş yapılmıştır.
  - **vm1**, **vm2**, **vm3**: Tanımlanan sanal makinelerin anahtarlarıdır.

Bu yapılandırma, oluşturulacak her bir sanal makine için ad, IP adresi ve disk boyutu gibi bilgileri sağlar.

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

### Temel Öğeler
- **version: 2**: Cloud-init'in ağ yapılandırma sürümünü belirtir.
- **ethernets**: Ethernet arabirimlerini tanımlar.
  - **ens3**: Ağ arabirimi adı. Bu, KVM'de kullanılan sanal ağ bağdaştırıcısının adıyla eşleşmelidir.
  - **dhcp4: no**: DHCP'nin devre dışı bırakıldığını belirtir.
  - **addresses**: Sanal makineye atanacak statik IP adreslerini tanımlar.
  - **gateway4**: Varsayılan ağ geçidi IP adresi.
  - **nameservers**: DNS sunucularını belirtir.

## `cloud_config.yml` Dosyasını Anlama
`cloud_config.yml`, oluşturulan sanal makinelerin başlangıç yapılandırmalarını sağlar. Örnek bir dosya aşağıda verilmiştir:

```yaml
#cloud-config
hostname: ubuntu-22-04-vm
manage_etc_hosts: true
users:
  - name: murat
    groups: sudo
    home: /home/murat
    shell: /bin/bash
    lock_passwd: false
    passwd: murat

ssh_pwauth: true
disable_root: false
chpasswd:
  list: |
    murat:murat
  expire: False

final_message: "The system is finally up, after $UPTIME seconds"
```

### Temel Öğeler
- **hostname**: Sanal makinenin hostname bilgisini tanımlar.
- **users**: Kullanıcı bilgilerini içerir. Burada örnek olarak "murat" kullanıcı adı verilmiştir.
  - **groups**: Kullanıcının ait olduğu gruplar.
  - **home**: Kullanıcının home dizini.
  - **passwd**: Kullanıcı şifresi.
- **ssh_pwauth**: SSH şifre doğrulamasını etkinleştirir.
- **disable_root**: Root kullanıcısının SSH erişimini yönetir.
- **final_message**: Sanal makine hazır olduğunda ekranda gösterilecek mesaj.

Bu dosya, sanal makineler oluşturulduktan sonra kullanıcı hesabı, SSH yapılandırması ve diğer başlangıç ayarlarını otomatik olarak uygular.

## Kullanım

### Adım 1: Reponun Klonlanması
```bash
git clone https://github.com/murat-akpinar/opentofu-kvm.git
cd opentofu-kvm
```

### Adım 2: Değişkenlerin Yapılandırılması
`variables.tf` dosyasını düzenleyerek sanal makinelerin sayısını, statik IP adreslerini, disk boyutlarını ve diğer parametreleri tanımlayın.

### Adım 3: OpenTofu Yapılandırmasını Başlatma ve Uygulama
```bash
opentofu init
opentofu apply
```

> **Not:** KVM sunucunuzun belirttiğiniz sayıda VM'i destekleyecek yeterli kaynağa sahip olduğundan emin olun.

## Örnek Çalışma Akışı
1. Gereksinimlerde belirtilen şekilde KVM'yi kurun ve yapılandırın.
2. `variables.tf` dosyasına istediğiniz VM yapılandırmalarını tanımlayın.
3. `cloud_config.yml` ve `network_config.yml` dosyalarını ihtiyacınıza göre düzenleyin.
4. OpenTofu yapılandırmasını uygulayarak VM'leri oluşturun.
5. Belirtilen ağ ve kaynak ayarlarıyla VM'lerin çalışır durumda olduğunu doğrulayın.

## Sorun Giderme
- **İzin Hatası**: Kullanıcınızın `libvirt` ve `kvm` gruplarına eklendiğinden ve oturumu yeniden başlattığınızdan emin olun.
- **Ağ Sorunları**: `network_config.yml` dosyasındaki ağ geçidi ve DNS ayarlarını doğrulayın.
- **Kullanıcı Sorunları**: `cloud_config.yml` dosyasındaki kullanıcı yapılandırmalarını kontrol edin.

