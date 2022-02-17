# helium_ansible

ansible playbooks for managing helium hotspots

## Computer setup to run ansible

### Ubuntu

sudo apt-get install ansible sshpass

## Miner Setup

Flash this image to a 32GB or larger microSD card.
https://downloads.raspberrypi.org/raspios_lite_arm64/images/raspios_lite_arm64-2021-11-08/

This SD card is recommended: https://amzn.to/340Ut7f

Afer writing out the image, enable ssh access by touching a file named ssh in the root of the SD card. The volume name of the SSD card is 'boot'.
On Mac: touch /Volumes/boot/ssh
On Linux: touch <mount point>/ssh

Connect the miner to your network and get its IP address. Test connectivity. The password is raspberry.
```
ssh pi@<that ip>
```

## Configure ansible

Change the line eu868 to us915 if you are in the US. Enter the ip in to hosts.yml for the ansible_host variable 
```
all:
  children:
    eu868:
      hosts:
        hotspot:
          ansible_host: 192.168.0.12
          ansible_user: pi
          ansible_ssh_pass: raspberry
          ansible_become: true
```



## Run ansible

If you wish to use tailscale, please install the dependencies:
```
ansible-galaxy install -r requirements.yml
```

Then change enable_tailscale: True in group_vars/all.yml

Install everything on your miner
```
ansible-playbook -i hosts.yml rpi.yml
```


## Issues

"+ sh -c DEBIAN_FRONTEND=noninteractive apt-get install -y -qq --no-install-recommends  docker-ce-cli docker-ce >/dev/null", "E: Sub-process /usr/bin/dpkg returned an error code (1)"]

ssh pi@<ip>
sudo systemctl restart systemd-networkd.service
sudo apt remove docker-ce
sudo apt install docker.io
sudo enable docker
sudo reboot now
Run ansible-playbook again
