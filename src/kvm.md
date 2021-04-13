```
sudo apt update
sudo apt install qemu qemu-kvm libvirt-bin  bridge-utils  virt-manager
```

```
# /etc/netplan/01-network-manager-all.yaml
network:
  version: 2
  ethernets:
    enp24s0f1:
      dhcp4: no
      dhcp6: no
  bridges:
    br0:
      interfaces: [enp24s0f1]
      dhcp4: no
      addresses: [192.168.1.134/24]
      gateway4: 192.168.1.1
      nameservers:
        addresses: [114.114.114.114]

```



安装虚拟机的时候，不要安装在 `/var` , 要安装在 /home 里面

在每台虚拟机里面要配置

```
# /etc/network/interfaces
auto ens3
iface eth0 inet static
address 192.168.1.136/24
gateway 192.168.1.1
```

```
/etc/hostname
watford-1
```





[1] https://linux.cn/article-9707-1.html



```
watford 192.168.1.134
watford-1 192.168.1.135
/usr/bin/autossh -M 5135 -o "ExitOnForwardFailure=yes" -o "ServerAliveInterval 30" -o "ServerAliveCountMax 3" -NR 8135:127.0.0.1:22 root@47.102.216.147 -i /home/user/.ssh/id_rsa
watford-2 192.168.1.136
/usr/bin/autossh -M 5136 -o "ExitOnForwardFailure=yes" -o "ServerAliveInterval 30" -o "ServerAliveCountMax 3" -NR 8136:127.0.0.1:22 root@47.102.216.147 -i /home/user/.ssh/id_rsa
watford-3 192.168.1.137
/usr/bin/autossh -M 5137 -o "ExitOnForwardFailure=yes" -o "ServerAliveInterval 30" -o "ServerAliveCountMax 3" -NR 8137:127.0.0.1:22 root@47.102.216.147 -i /home/user/.ssh/id_rsa
watford-4 192.168.1.138
/usr/bin/autossh -M 5138 -o "ExitOnForwardFailure=yes" -o "ServerAliveInterval 30" -o "ServerAliveCountMax 3" -NR 8138:127.0.0.1:22 root@47.102.216.147 -i /home/user/.ssh/id_rsa

# fail
# disk not found
brentford 192.168.1.139
brentford-1 192.168.1.141
brentford-2 192.168.1.142
brentford-3 192.168.1.143
brentford-4 192.168.1.144
```



```
# 失败的命令
sudo virt-install -n watford-1  --description "Test VM 1"  --os-type=Linux  --os-variant=ubuntu18.04 --disk size=100 --memory 8096  --vcpus 4  --disk path=/home/user/kvmfiles/watford-1.img,bus=virtio,size=10  --network bridge:br0 --graphics none   --cdrom /home/user/iso/ubuntu-18.04.5-live-server-amd64.iso 
```


ssh -p 8135 user@47.102.216.147
ssh -p 8136 user@47.102.216.147
ssh -p 8137 user@47.102.216.147
ssh -p 8138 user@47.102.216.147
