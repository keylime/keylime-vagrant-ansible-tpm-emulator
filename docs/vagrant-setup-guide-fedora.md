# End-to-end setup guide

This document aims to provide a step-by-step guide to set up Keylime running in Vagrant, for development purposes.

This guide assumes you're running a recent version of Fedora (35+). Earlier versions _may_ work, though the setup has been tested on 35+.

## Set up Vagrant

We will use Vagrant as a means to easily deploy a single VM with a TPM emulator already installed and running.

On your local machine (this assumes  Fedora as your OS), install Vagrant following [this guide](https://developer.fedoraproject.org/tools/vagrant/vagrant-libvirt.html). Once complete, run the following commands to install necessary Vagrant plugins and clone the repo.

```shell
[localhost]$ vagrant plugin install vagrant-sshfs
[localhost]$ vagrant plugin install vagrant-libvirt
[localhost]$ git clone https://github.com/keylime/keylime-vagrant-ansible-tpm-emulator
[localhost]$ cd keylime-vagrant-ansible-tpm-emulator
```

### Provisioning

With either option below, you only need to run the `--provision` flag the first time you create a new Vagrant machine. If you halt it and restart it later you don’t need to re-provision. However, if you destroy and recreate the machine(s) (or add new instances) you will need to use the `--provision` flag again.

#### Option 1: Flags

```shell
[localhost]$ vagrant --repo=<path to your local keylime/keylime directory> up --provider libvirt --provision
```

Note: you can use flags to increase resources as well (these flags must be provided before the up command, while `--provider` and `--provision` come after):

- `--instances`: The number of Keylime Virtual Machines to create. If not provided, it defaults to 1
- `--repo`: This mounts your local Keylime git repository into the virtual machine (allowing you to test your code within the VM). This is optional. If not provided, it defaults to keylime/keylime-vagrant-ansible-tpm-emulator
- `--cpus`: The amount of CPUs. If not provided, it defaults to 2
- `--memory`: The amount of memory to assign. If not provided, it defaults to 2048

#### Option 2: Config file

Edit the `vagrant_variables.yml.sample` file to point to your local `keylime/keylime` directory and copy it to `vagrant_variables.yml`. For more details, see the [README](https://github.com/keylime/keylime-vagrant-ansible-tpm-emulator).

Example:

```shell
[localhost]$ vim vagrant_variables.yml.sample
```


The file will come up as shown below. Edit the repo: line, then save and execute the commands below.

```vim
# Define defaults to use in the Vagrantfile.

# Number of virtual machine instances.
instances: 1

# The number of CPUs to use.
cpus: 2

# The amount of memory to assign.
memory: 2048

# Location of your local keylime git repository to sync into the virtual   # machine. This allows you to test your code within the VM.
# (edit below)
repo: /home/lily/Repos/keylime

# Set verbosity during Ansible provisioning.
verbose: false
```

Once edited, move the config file and bring the VM up:

```shell
[localhost]$ cp vagrant_variables.yml.sample vagrant_variables.yml
[localhost]$ vagrant up --provider libvirt --provision
```


## Connect to your Keylime VM

When provisioning is complete, log into the VM with the following steps.

### Bring up vagrant machine

```shell
[localhost]$ vagrant up
```

This can also just be `vagrant reload` if you want to refresh things for some reason.

### Connect via ssh

```shell
[localhost]$ vagrant ssh

# do everything as root from here on in (for a dev machine only ofc!)
[vagrant@keylime-fedora ~]$ sudo -i
```

## Ensure TPM is running

```shell
[root@keylime-fedora ~]# tpm2_pcrread

<lots of hashes should return>
```

If you look at the output most of the PCRs (platform configuration registers) will have values of lots of zeros. The main one that will be set is the SHA1 PCR-10 which is being populated by IMA and the IMA emulator which extends the PCR every time a file is accessed.

The Keylime IMA emulator (this replicates IMA which cannot work in a VM as we are running the tpm as a software emulator so it's not early enough in the boot process for IMA to use it) should already be running as it’s a systemd service. But if SHA1 PCR-10 isn’t set you can restart the emulator:

```shell
# (if needed)
[root@keylime-fedora ~]# systemctl restart tpm_emulator
[root@keylime-fedora ~]# systemctl restart ima_emulator
```

## Build Keylime
While still logged into your vagrant machine with ssh, change to your keylime repository folder `/root/keylime-dev/` and run:

```shell
[root@keylime-fedora ~]# cd /root/keylime-dev/
[root@keylime-fedora keylime-dev]# pip3 install -r requirements.txt
[root@keylime-fedora keylime-dev]# python3 setup.py install
```

## Set up an allowlist

Set up an allowlist for the verifier to use to check Quotes from the agent. This may take some time.

```shell
[root@keylime-fedora keylime-dev]# ./scripts/create_allowlist.sh -o ~/allowlist.txt -h sha256sum
```

## Set up an excludes list

The files and directories listed in this file will not be checked for integrity during runtime attestation of the agent. It is a good idea to include directories with frequently changing contents. This file can be called something like `excludes.txt` and can live in the `/root` directory. Example `excludes.txt` file:

```
/tmp/*
/var/log/*
/usr/bin/*
/usr/sbin/*
/usr/local/bin/*
/usr/share/*
/usr/lib/*
/usr/lib64/*
/usr/libexec/*
/etc/*
/root/swtpm.sh
/root/keylime/*
/root/keylime-dev/*
```

## Start Keylime

From your local machine, **open 4 terminals** to run and monitor 4 different processes (verifier, registrar, agent, tenant). After you open each terminal, run the following commands on each one:

```shell
[localhost]$ vagrant ssh
[vagrant@keylime-fedora ~]$ sudo -i
```

## Start each Keylime component

Then start the verifier, registrar and agent, each _in their own terminals_. These are long running processes that are useful to run in non-daemon mode when developing so you can easily start/stop them as well as monitor the logs. A tiling terminal like Tilix is handy for something like this. Else you can just use multiple tabs in your terminal of choice.

```shell
(terminal 1)
[root@keylime-fedora ~]# keylime_verifier
```

```shell
(terminal 2)
[root@keylime-fedora ~]# keylime_registrar
```

```shell
(terminal 3)
[root@keylime-fedora ~]# keylime_agent
```

## Issue a command using the tenant

Finally, it's time to issue a command and see everything working!

```shell
(terminal 4)
[root@keylime-fedora ~]# keylime_tenant -v 127.0.0.1 -t 127.0.0.1 -u d432fbb3-d2f1-4a97-9ef7-75bd81c00000 -f /root/excludes.txt --allowlist /root/allowlist.txt --exclude /root/excludes.txt -c add
```

## Fail the agent

Open a new terminal, ssh into the vagrant machine, and execute a malicious script to trigger failure. This action corresponds to something that would **run on the agent**. Here we are opening a new terminal to run the action since all Keylime components are running on the same machine for demo purposes. However, if you are running each component on a separate machine or instance, you should run this on the agent machine.

```shell
(terminal 5, but representing the agent)
[localhost]$ vagrant ssh
[vagrant@keylime-fedora ~]$ sudo -i
[root@keylime-fedora ~]# cat > bad-script.sh <<EOF
#!/bin/sh

echo -e “Hello Evil!”
EOF

[root@keylime-fedora ~]# chmod +x bad-script.sh
[root@keylime-fedora ~]# ./bad-script.sh
```

## Revocation
In this section, you will set up a custom revocation action on the agent by including a revocation script as part of the payload that is sent from the tenant to the agent. This payload can be decrypted and executed by the agent upon its first successful attestation. After this first successful attestation, if the agent fails an attestation, the revocation actions will be executed.

### Set Up Payload

First, make sure that the `payload_script` in the `[cloud_agent]` section of `/etc/keylime.conf` is set to `autorun.sh`:

```
[cloud_agent]

payload_script=autorun.sh
```

This specifies the script to run on the agent after its first successful attestation.

#### Option 1: Quick and easy payload

Note this example uses the default values for the tenant command, but you may substitute your own:

```shell
[root@keylime-fedora ~]# mkdir /root/payload
[root@keylime-fedora ~]# echo "echo -e 'hello'" > /root/payload/autorun.sh

[root@keylime-fedora ~]# keylime_tenant -v 127.0.0.1 -t 127.0.0.1 --uuid d432fbb3-d2f1-4a97-9ef7-75bd81c00000 --allowlist /root/allowlist.txt --include /root/payload --cert /root/ca --exclude /root/excludes.txt -c add
```

#### Option 2: More realistic payload

For this payload, you will need to use or [generate a key pair](https://www.ssh.com/academy/ssh/keygen) for ssh (the private key will be called `id_rsa` and the public key will be called `id_rsa.pub`).

```shell
[root@keylime-fedora ~]# mkdir /root/payload && cd /root/payload

# set up action_list
[root@keylime-fedora ~]# echo “local_action_remove_ssh” > action_list

# set up autorun.sh
[root@keylime-fedora ~]# cat > autorun.sh <<EOF
> #!/bin/sh
> mkdir -p /root/.ssh/
> cp id_rsa* /root/.ssh/
> chmod 600 /root/.ssh/id_rsa*
> EOF


# set up local_action_remove_ssh.py
[root@keylime-fedora ~]# cat > local_action_remove_ssh.py <<EOF
> import os
> import asyncio
>
> async def execute(revocation):
>	if revocation['type']!='revocation':
>    	return
>	os.remove("/root/.ssh/id_rsa")
>	os.remove("/root/.ssh/id_rsa.pub")
> EOF
```

At this point, the payload directory should look like this:

```shell
[root@keylime-fedora ~]# ls /root/payload

action_list autorun.sh id_rsa id_rsa.pub local_action_remove_ssh.py
```

Now execute the tenant command including the CA:

```shell
[root@keylime-fedora ~]# keylime_tenant -v 127.0.0.1 -t 127.0.0.1 -u d432fbb3-d2f1-4a97-9ef7-75bd81c00000 --cert /root/myca --allowlist /root/allowlist.txt --exclude /root/excludes.txt -f—-include /root/payload -c add
```

Run keylime_ca

```shell
[root@keylime-fedora ~]# keylime_ca -c listen -d /root/myca
```


## Using multiple Vagrant instances together

The Keylime vagrantfile is already set up to easily provision multiple instances of the same VM if desired, and that’s what will be used here.

### Open ports

Before provisioning, some small changes must be made to the Vagrantfile to open up the necessary ports for Keylime's components to talk to each other across VMs. Open up the Vagrantfile and find the section with this comment:

```
# Uncomment the following to forward ports on the VM and
# allow access to Keylime components from the host machine.
```

Uncomment all the ports listed below that comment (for example, `#keylime.vm.network "forwarded_port", guest: 8881, host: "8881"` and similar).

### Provision VMs

Next, provision VMs using `vagrant up --provider libvirt --provision`. If using a `vagrant_variables.yml` file, change `instances` to 2 (or however many are desired). If using command-line options, use `--instances=2`. This step will take some time.

Once up, SSH into both VMs in separate terminals using `vagrant ssh`. Unlike with a single Vagrant box, you’ll need to provide the hostname for each. Fortunately, they are named pretty intuitively - hostnames are assigned according to the pattern `keylime-fedora#`. For example, when provisioning two VMs, their hostnames should be `keylime-fedora1` and `keylime-fedora2`. Just append them to the end of the SSH command like so: `vagrant ssh keylime-fedora1`.

Once logged on as root, install Keylime as normal on both boxes (see #Build Keylime for details).

### Update keylime.conf with correct IPs

At this point, both VMs should have a config file present at `/etc/keylime.conf`. Both need to be updated with the appropriate IP addresses of the different VMs running. To find the IP addresses, run `hostname -I` on both and note which is which.

Next, open `/etc/keylime.conf` in your text editor of choice, find all config options for IP addresses, and change them to match the machines that will be running each Keylime component. For example: say VM #1 has IP 1.1.1.1 and will run the tenant, verifier, and registrar, and VM #2 has IP 2.2.2.2 and will run the agent. Update all config options for `verifier_ip`, `registrar_ip`, and similar with `1.1.1.1` and all config options for `cloud_agent_ip` and similar with `2.2.2.2`. Do this for the config file on both VMs.

### Sharing certificates to all VMs

Finally, the Keylime CA certificate must be identical on all systems in order for mTLS to work. To create a new CA certificate, start `keylime_verifier` on its intended machine; once set up, there should be a certificate present at `/var/lib/keylime/cv_ca.cacert.crt`. This file needs to make its way to the same path on all other VMs.

There are several ways to move the file over, but `scp` is the simplest. The non-root `vagrant` user has a default password of `vagrant`, so this command should work:

```shell
scp /var/lib/keylime/cv_ca/cacert.crt vagrant @<ip address of the other machine>:~
```

Accept the fingerprint and enter the password `vagrant` when prompted.

At this point, the second machine should have the certificate in the `vagrant` home directory at `/home/vagrant/cacert.crt`. The destination directory won’t yet exist, so create it and move the certificate:

```shell
[keylime-fedora2]# mkdir /var/lib/keylime
[keylime-fedora2]# mkdir /ver/lib/keylime/cv_ca
[keylime-fedora2]# mv /home/vagrant/cacert.crt /var/lib/keylime/cv_ca/cacert.crt
```

At this point, things should work! Start up `keylime_registrar` and, finally, `keylime_agent`. If everything worked, the agent should register as normal and commands can be issued to the verifier.


## Troubleshooting

Here are some solutions to possible errors bringing the Vagrant box up encountered on a clean Fedora 36 install.

### `virbr0`: no such device

Error message:

```shell
==> keylime-fedora1: Creating shared folders metadata…
==> keylime-fedora1: Starting domain. /usr/share/gems/gems/fog-libvirt-0.8.0/lib/fog/libvirt/requests/compute/vm_action.rb:7:in 'create': Call to virDomainCreateWithFlags failed: internal error: /usr/libexec/qemu-bridge-helper --use-vnet --br=virbr0 --fd=29: failed to communicate with bridge helper: Transport endpoint is not connected (Libvirt::Error) stderr=failed to get mtu of bridge 'virbr0': No such device
```

This error might have come up because of an incomplete installation of libvirt. Check your firewall zones with this command:

```shell
[localhost ~]$ firewall-cmd --get-active-zones
FedoraWorkstation
  interfaces: wlp0s20f3
docker
  interfaces: docker0
libvirt
  interfaces: virbr0
```

You should see a zone for libvirt present (like above); if not, that’s likely what’s causing the error. A possible fix is enabling/starting or just restarting `libvirtd` (though make sure it’s enabled if restarting):

```shell
[localhost ~]$ sudo systemctl enable libvirtd
[localhost ~]$ sudo systemctl start libvirtd
[localhost ~]$ sudo systemctl restart libvirtd
```

Check firewall zones again. If the libvirt zone is present, the issue should be fixed.

### Call to `virConnectListAllNetworks` failed

```shell
/usr/share/vagrant/gems/gems/vagrant-libvirt-0.7.0/lib/vagrant-libvirt/driver.rb:158:in 'list_all_networks': Call to virConnectListAllNetworks failed: Failed to connect socket to '/var/run/libvirt/virtnetworkd-sock-ro': No such file or directory (Libvirt::RetrieveError)
```

This error could be caused by libvirt networking being offline. Check status of `virtnetworkd`:

```shell
[localhost ~]$ sudo systemctl status virtnetworkd
```

If disabled and inactive, try enabling and starting it, then trying again.

```shell
[localhost ~]$ sudo systemctl enable virtnetworkd
[localhost ~]$ sudo systemctl start virtnetworkd
```
