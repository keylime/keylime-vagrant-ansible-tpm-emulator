**ANNOUNCE:** *On 2020-02-10 the ansible-keylime-tpm-emulator repo has been renamed to
keylime-vagrant-ansible-tpm-emulator . If you have a fork you might want to
rename the fork just to keep your sanity (although it's not required). You might
also consider updating your git remotes, although Github redirect for a while*

# Keylime Vagrant Ansible TPM Emulator

[![Build Status](https://travis-ci.org/keylime/ansible-keylime-tpm-emulator.svg?branch=master)](https://travis-ci.org/keylime/ansible-keylime-tpm-emulator) [![Slack chat](https://img.shields.io/badge/Chat-CNCF%20Slack-informational)](https://join.slack.com/t/cloud-native/shared_invite/zt-fyy3b8up-qHeDNVqbz1j8HDY6g1cY4w)

A Vagrant file to easily bring up a test Keylime environment using an Ansible
role to deploy [Keylime](https://github.com/keylime/keylime) with a
pre-configured and ready to use TPM Emulator.

For details on using Keylime, please consult the general
[project documentation](https://keylime-docs.readthedocs.io/)

## Security Warning
⚠ **Do not use a software TPM emulator in a production environment.** ⚠

SELinux is set to *permissive* for this role.

This role is designed to enable development environment provisioning or to set
up a sandbox environment to test drive Keylime.

Should you want to deploy with a hardware TPM, use the [anisble-keylime role](https://github.com/keylime/ansible-keylime)

## Usage: Ansible role
The Ansible role may be used on its own.

Run the example playbook against your target remote node(s). For instance:

```
ansible-playbook -i your_hosts playbook.yml
```

## Usage: Vagrant

A `Vagrantfile` is available for provisioning virtual machines for local
testing.

Clone the repository and then simply run with the following additional args
added to the `vagrant` command:


* `--instances`: The number of Keylime virtual machines to create. If not
  provided, it defaults to `1`
* `--repo`: This is intended to help you hack on Keylime. It mounts a local
Keylime Git repository into the virtual machine, allowing you to test your code
within the VM. This is optional and will mount the repo directory you pass in
at "/root/keylime-dev".
* `--cpus`: The number of CPUs. If not provided, defaults to `2`
* `--memory`: The amount of memory to assign.  If not provided, defaults to
  `2048`
* `--qualityoflife`: Adds a few extras, such as the Powerline improved bash
  shell prompt as well as an ls alias (ll for ls -lAh). This is optional.

Deployment example, using libvirt as the virtualization provider:

```
vagrant --instances=2 --repo=/home/jdoe/keylime --cpus=4 --memory=4096  up --provider libvirt --provision
```

Deployment example, using VirtualBox as the virtualization provider:

```
vagrant --instances=2 --repo=/home/jdoe/keylime --cpus=4 --memory=4096  up --provider virtualbox --provision
```

| NOTE: Customized args (`--instances`, `--repos` etc), come before the main Vagrant args (such as `up`, `status`, `--provider`). Example: To `ssh` into the second machine instance, keylime2, use the Vagrant command as such : `vagrant --instances=2 ssh keylime2`|
| --- |

If you would like to customise these defaults without having to specify them on
the command line each time, you can use a `vagrant_variables.yml` file. The
simplest way to do this is to copy `vagrant_variables.yml.sample` to
`vagrant_variables.yml` and edit it:

```shell
cp vagrant_variables.yml.sample vagrant_variables.yml
```

You can still override the defaults in `vagrant_variables.yml` by using the
command line options.

Once the VM is started, use `vagrant ssh` to ssh into the VM and run `sudo su -`
to become root.

The TPM emulator will be running.

You can then start the various components using commands:

```
keylime_verifier

keylime_registrar

keylime_agent

keylime_node
```

Note: you will most likely need to export the right TPM2TOOLS_TCTI environment
variable before being able to successfully start keylime_agent. To do so:
`export TPM2TOOLS_TCTI="mssim:port=2321"`

### Upgrading VMs

If you just want to upgrade Keylime within your VM(s), running the following as
root, from within `/root/keylime`, should be enough:
`git pull`
`python setup.py install`

To fully rebuild your VM(s), run the following from the directory where you cloned this repo:
`vagrant destroy`
Note: this will delete your Keylime VM(s).

You can then re-deploy the VM(s) by re-running the provisioning step.

Lastly, if you have a VM that was provisioned using an older version of Fedora
(say, 31, while the current Vagrantfile will use Fedora 33), you will need to
remove the Fedora 31 cloudbase image before `vagrant up --provision` will
upgrade you to the new version of Fedora, eg:
`vagrant box remove fedora/31-cloud-base`

## WebApp

The web application can be started with the command `keylime_webapp`. If using
Vagrant, port 443 will be forwarded from the guest to port 8443 on the host.

This will result in the web application being available at the following URL:

https://localhost:8443/webapp/


## IMA Policy

This role deploys a basic ima-policy into `/etc/ima/ima-policy` so that IMA
run time integrity may be used. For this to activate, you must reboot the
machine first (if you're using vagrant, perform `vagrant reload`)

### Obsolete, as we don't use abrmd anymore
Previously, when rebooting the machine, one needed to start the emulator again:

`/usr/local/bin/tpm_serverd`

`systemctl restart tpm2-abrmd`

Once the `tpm2-abrmd` service is running, start the IMA component using the command:

`keylime_ima_emulator`

## Access to Keylime components from the host

To allow direct access to the Keylime components from the host machine, you can
forward the ports for the various Keylime components by uncommenting the
relevant lines in the Vagrantfile.

## License

[Apache
2.0](https://github.com/keylime/ansible-keylime-tpm-emulator/blob/master/LICENSE)

## Contribute

We welcome contributions and pull requests are welcome!

Please ensure CI tests pass!

## Contributors

* Luke Hinds (lhinds@redhat.com)
* Leo Jia (ljia@redhat.com )
* Andrew Stoycos (astoycos@bu.edu)
* Amy Pattanasethanon (raynecarnes@gmail.com)
* axel simon (axel@redhat.com)
