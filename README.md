# Install NIxOS from flakes on HETZNER



## Prep Disk

```sh
lsblk

sgdisk -d 1 /dev/sda
sgdisk -N 1 /dev/sda
partprobe /dev/sda

mkfs.ext4 -F /dev/sda1 # wipes all data!

mount /dev/sda1 /mnt

dd if=/dev/zero of=/mnt/.swapfile bs=1M count=2048 status=progress

chmod 600 /mnt/.swapfile

mkswap /mnt/.swapfile

swapon /mnt/.swapfile

swapon -s
```

## Install system

```sh
nix-shell -p git nixFlakes

git clone https://github.com/EmailDemo/nixmail.git /mnt/etc/nixos

nix --experimental-features 'nix-command flakes' flake update '/etc/nixos/' -v

nixos-install --root /mnt --flake /mnt/etc/nixos#yournixmail --no-root-passwd

reboot

sudo nix flake update /etc/nixos/

sudo nixos-rebuild switch --flake /etc/nixos/#yournixmail
```
# Run as a root
nix-shell -p apacheHttpd --run  'htpasswd -nbB "" "super secret password"' | cut -d: -f2 > /var/vmail/User_Passwd

```
nix-shell -p bind --command "host 10.0.0.1"
nix-shell -p bind --command "host -t mx YouDomain.com"
nix-shell -p bind --command "host -t TXT YouDomain.com"
nix-shell -p bind --command "host -t txt mail._domainkey.YouDomain.com"
nix-shell -p bind --command "host -t TXT _dmarc.YouDomain.com"
```

```
nix-shell -p nmap

nmap -v -sV 10.0.0.1/32
nmap -v -O 10.0.0.1/32
nmap -v -sR 10.0.0.1/32
nmap -v -sW 10.0.0.1/32
nmap -v -sN 10.0.0.1/32
nmap -v -sX 10.0.0.1/32
nmap -v -sF 10.0.0.1/32
nmap -v -sS 10.0.0.1/32
nmap -v -sT 10.0.0.1/32
nmap -v -sV 10.0.0.1/32
nmap -v -sU 10.0.0.1/32
```

```
systemctl list-units --type=service --state=running
systemctl status postfix.service
journalctl -u postfix.service
journalctl -f -u postfix.service

nix-shell -p telnet bind nmap

telnet gmail-smtp-in.l.google.com 25
```