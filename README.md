Ansible Keylime
===============

[![Build Status](https://travis-ci.org/keylime/ansible-keylime-tpm-emulator.svg?branch=master)](https://travis-ci.org/keylime/ansible-keylime-tpm-emulator) [![Gitter chat](https://badges.gitter.im/gitterHQ/gitter.png)](https://gitter.im/keylime-project/community)

Ansible role to deploy [Keylime](https://github.com/keylime/keylime) and a TPM Emulator,
alongside the  [Keylime rust cloud node](https://github.com/keylime/rust-keylime)
on Fedora release 31.

For details on using Keylime, please consult the
[project documentation](http://keylime-docs.rtfd.io/)

Please note that the rust cloud node is still under early stages of Development.
Those wishing to test drive Keylimes functionality should use the existing
python based cloud node `keylime_node` until later notice.

Security Warning
-----------------

This role deploys with a software TPM Emulator.

Do not use a software TPM emulator in a production environment.

SELinux is set to permissive for this role.

This role is solely for the use of development or demonstration purposes.

Usage
-----

Run the example playbook against your target remote node(s).

```
ansible-playbook -i your_hosts playbook.yml
```

TPM Version Control
-------------------

Either TPM version 1.2 or TPM 2.0 support can be configured by simply changing the role in the `playbook.yml` file [here](https://github.com/keylime/ansible-keylime/blob/master/playbook.yml#L11).

For TPM 2.0 use:

```
  - ansible-keylime-tpm20
```

For TPM 1.20 use:

```
  - ansible-keylime-tpm12
```

Both roles will deploy the relevant TPM 1.2 Emulator (tpm4720) or 2.0 Emulator (IBM software TPM).

Vagrant
-------

A `Vagrantfile` is available for provisioning.

Clone the repository and then simply run with the following additional args
added to the `vagrant` command:


* `--instances`: The number of Keylime Virtual Machines to create. If not provided, it defaults to `1`
* `--repo`: This mounts your local Keylime git repository into the virtual machine (allowing you to test your code within the VM). This is optional.
* `--cpus`: The amount of CPU's. If not provided, it defaults to `2`
* `--memory`: The amount of memory to assign.  If not provided, it defaults to `2048`

For example, using libvirt:

```
vagrant --instances=2 --repo=/home/jdoe/keylime --cpus=4 --memory=4096  up --provider libvirt --provision
```

For example, using VirtualBox:

```
vagrant --instances=2 --repo=/home/jdoe/keylime --cpus=4 --memory=4096  up --provider virtualbox --provision
```

| NOTE: Customized args (`--instances`, `--repos` etc), come before the mainvagrant args (such as `up`, `--provider`) |
| --- |

Once the VM is started, vagrant ssh into the VM and run `sudo su -` to
become root.

The TPM emulator will be running.

You can then start the various components using commands:

```
keylime_verifier

keylime_registrar

keylime_node
```

WebApp
------

The web application can be started with the command `keylime_webapp`. If using
Vagrant, port 443 will be forwarded from the guest to port 8443 on the host.

This will result in the web application being available on url:

https://localhost:8443/webapp/


IMA Policy
----------

This role deploys a basic ima-policy into `/etc/ima/ima-policy` so that IMA
runtime integrity can be used. For this to activate, you must reboot the
machine first.

Should you rboot the machine, you will need to start the emulator again:

`/usr/local/bin/tpm_serverd`

`systemctl restart tpm2-abrmd`

License
-------

Apache 2.0

Contribute
----------

Please do! Pull requests are welcome.

Please ensure CI tests pass!

Contributors
------------

* Luke Hinds (lhinds@redhat.com)
* Leo Jia (ljia@redhat.com )
