# helium_ansible

ansible playbooks for managing helium hotspots

## Computer setup to run ansible

### Ubuntu

```
sudo apt-get install ansible sshpass
```

## Miner Setup

Flash this image to a 32GB or larger microSD card.
https://downloads.raspberrypi.org/raspios_lite_arm64/images/raspios_lite_arm64-2021-11-08/

This SD card is recommended: https://amzn.to/340Ut7f

Afer writing out the image, enable ssh access by touching a file named ssh in the root of the SD card. The volume name of the SSD card is 'boot'.
On Mac: touch /Volumes/boot/ssh
On Linux: touch <mount point>/ssh

Copy your ssh key into the pi:  
  
```
ssh-copy-id pi@<that ip>
```  
insert the password from the pi and place the password for yout ssh key, if any.
  
  
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

### Configure host_vars/hotspot.yml

```
target_hostname: "hotspot-animal-name"		# your hotspot name
target_domain: "local"				# 
target_hotspot_vendor: "cotx"			# cotx or pisces or rakv2 or sensecap
target_miner_key: True				# --> True if you want to use the key miner from ECC chip
target_pf_concentrator_interface: "spi"		# usb
target_pf_concentrator_model: "sx1250"		# only sx1250 for now
# Tailscale subnet to subroute traffic https://tailscale.com/kb/1019/subnets/
#tailscale_subnet_cidr: 192.168.0.1/24
```

### Configure OpenVPN (optional)

Turn openvpn on in group_vars/all.yaml
```
enable_openvpn: True # Also need to define openvpn_config
```

### Configure Packet Forward
 
Turn internal Packet Forward on in group_vars/all.yaml
  
```  
#Packet Forwarder
enable_packet_forwarder: True
```  

Use external Paket Forward (i.e. Dragino )
    
```  
#Packet Forwarder
enable_packet_forwarder: False
```  
 
### Configure Tailscale (optional)

If you wish to use tailscale, please install the dependencies:
```
ansible-galaxy install -r requirements.yml
```

Encrypt your API key
```
ansible-vault encrypt_string 'your-tailscale-api-key-goes-here' --name 'tailscale_auth_key'
```

Insert it into group_vars/all.yml

Then change enable_tailscale: True in group_vars/all.yml

## Run ansible

Install everything on your miner
```
ansible-playbook -i hosts.yml rpi.yml
```

## Check if miner is running

This gives a lot of interesting information
```
ssh pi@<ip>
docker exec miner miner info summary
```

If you want specific things you can see a list of options by running
```
$ docker exec miner miner info
Usage: miner info commands

  info height            - Get height of the blockchain for this miner.
  info in_consensus      - Show if this miner is in the consensus_group.
  info name              - Shows the name of this miner.
  info block_age         - Get age of the latest block in the chain, in seconds.
  info p2p_status        - Shows key peer connectivity status of this miner.
  info onboarding        - Get manufacturing and staking details for this miner.
  info summary           - Get a collection of key data points for this miner.
  info region            - Get the operatating region for this miner.
pi@my-hot-spot:~ $ docker exec miner miner info summary

```

## Configure wallet

This will ask you to enter your 12 words and then you can use the cli wallet to manage the hotspot
```
HELIUM_WALLET_PASSWORD='wallet password' helium-wallet create basic --seed mobile -o ~/helium/keys/${hotspot}.key
```

to assert.
```
HELIUM_WALLET_PASSWORD='wallet password' helium-wallet --format json -f ${key_file} hotspots assert --gateway ${hotspot_address} --gain=${gain} --elevation=${elevation} --lat=${lat} --lon=${lon} --commit
```

## Issues

You can join #diy-packet-fowarder on https://discord.com/invite/helium


### Docker gave this error and fidgeting with it fixed it

```
"+ sh -c DEBIAN_FRONTEND=noninteractive apt-get install -y -qq --no-install-recommends  docker-ce-cli docker-ce >/dev/null", "E: Sub-process /usr/bin/dpkg returned an error code (1)"]
```

```
ssh pi@<ip>
sudo systemctl restart systemd-networkd.service
sudo apt remove docker-ce
sudo apt install docker.io
sudo enable docker
sudo reboot now
Run ansible-playbook again
```
