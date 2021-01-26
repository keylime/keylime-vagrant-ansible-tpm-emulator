# Vagrant Ansible Keylime TPM Emulator

[![Build Status](https://travis-ci.org/keylime/ansible-keylime-tpm-emulator.svg?branch=master)](https://travis-ci.org/keylime/ansible-keylime-tpm-emulator) [![Slack chat](https://img.shields.io/badge/Chat-CNCF%20Slack-informational)](https://join.slack.com/t/cloud-native/shared_invite/zt-fyy3b8up-qHeDNVqbz1j8HDY6g1cY4w)

Ansible role to deploy [Keylime](https://github.com/keylime/keylime) with a
pre-configured and ready to use swtpm and Vagrant file to easily bring up
a test environment.

For details on using Keylime, please consult the general
[project documentation](https://keylime-docs.readthedocs.io/)

## Security Warning
⚠ **Do not use a software TPM emulator in a production environment.** ⚠

SELinux is set to *permissive* for this role.

This role is designed to enable development environment provisioning or to set
up a sandbox environment to test drive Keylime.

Should you want to deploy with a hardware TPM, use the [anisble-keylime role](https://github.com/keylime/ansible-keylime)

## Usage: Ansible role

Run the example playbook against your target remote node(s).

```
ansible-playbook -i your_hosts playbook.yml
```

## Usage: Vagrant

A `Vagrantfile` is available for provisioning virtual machines for local
testing..

Clone the repository and then simply run with the following additional args
added to the `vagrant` command:


* `--instances`: The number of Keylime Virtual Machines to create. If not provided, it defaults to `1`
* `--repo`: This mounts your local Keylime git repository into the virtual machine (allowing you to test your code within the VM). This is optional.
* `--cpus`: The amount of CPU's. If not provided, it defaults to `2`
* `--memory`: The amount of memory to assign.  If not provided, it defaults to `2048`
* `--qualityoflife`: Adds a few extras, such as the Powerline improved bash shell
   prompt as well as an ls alias (ll for ls -lAh). This is optional.

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

The swtpm will be running.

You can then start the various components using commands:

```
keylime_verifier

keylime_registrar

keylime_agent

keylime_node
```

## WebApp

The web application can be started with the command `keylime_webapp`. If using
Vagrant, port 443 will be forwarded from the guest to port 8443 on the host.

This will result in the web application being available on url:

https://localhost:8443/webapp/

## IMA Policy

This role deploys a basic ima-policy into `/etc/ima/ima-policy` so that IMA
run time integrity may be used. For this to activate, you must reboot the
machine first (if you're using vagrant, perform `vagrant reload`)

Should you reboot the machine, you will need to start the emulator again:

`/usr/local/bin/tpm_serverd`

`systemctl restart tpm2-abrmd`

Once the `tpm2-abrmd` service is running, start the IMA component using the command:

`keylime_ima_emulator`

## Management of the SWTPM

Upon first run of this role a swtpm will be made available in `/tpm/swtpm`

A reboot will lose this instance. Should you need a new tpm, then you can create
one with the included script `/root/swtpm.sh`

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
