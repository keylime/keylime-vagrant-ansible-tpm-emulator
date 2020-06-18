Ansible Keylime
===============

[![Build Status](https://travis-ci.org/keylime/ansible-keylime-tpm-emulator.svg?branch=master)](https://travis-ci.org/keylime/ansible-keylime-tpm-emulator) [![Gitter chat](https://badges.gitter.im/gitterHQ/gitter.png)](https://gitter.im/keylime-project/community)

Ansible role to deploy [Keylime](https://github.com/keylime/keylime) with a
pre-configured and ready to use TPM Emulator.

For details on using Keylime, please consult the
[project documentation](http://keylime-docs.rtfd.io/)

Security Warning
-----------------
Do not use a software TPM emulator in a production environment.

SELinux is set to permissive for this role.

This role is designed to enable development environment provisioning or to
a sandbox environment for anyone who would like to test drive Keylime.

Should you want to deploy with a hardware TPM, use the [anisble-keylime role](https://github.com/keylime/ansible-keylime)

Usage
-----

Run the example playbook against your target remote node(s).

```
ansible-playbook -i your_hosts playbook.yml
```

TPM Version Control
-------------------

Either TPM version 1.2 or TPM 2.0 support can be configured by simply changing
the role in the `playbook.yml` file [here](https://github.com/keylime/ansible-keylime-tpm-emulator/blob/master/playbook.yml#L14).

For TPM 2.0 use:

```
  - ansible-keylime-tpm20
```

For TPM 1.2 use:

```
  - ansible-keylime-tpm12
```

Both roles will deploy the relevant TPM 1.2 Emulator (tpm4720) or 2.0 Emulator
(IBM software TPM).

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

| NOTE: Customized args (`--instances`, `--repos` etc), come before the mainvagrant args (such as `up`, `status`, `--provider`). Example: To `ssh` into the second machine instance, keylime2, use the vagrant command as such : `vagrant --instances=2 ssh keylime2` |
| --- |

Once the VM is started, vagrant ssh into the VM and run `sudo su -` to
become root.

The TPM emulator will be running.

You can then start the various components using commands:

```
keylime_verifier

keylime_registrar

keylime_agent

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
run time integrity may be used. For this to activate, you must reboot the
machine first (if you're using vagrant, perform `vagrant reload`)

Should you reboot the machine, you will need to start the emulator again:

`/usr/local/bin/tpm_serverd`

`systemctl restart tpm2-abrmd`

Once the `tpm2-abrmd` service is running, start the IMA component using the command:

`keylime_ima_emulator`

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
* Andrew Stoycos (astoycos@bu.edu)
* Amy Pattanasethanon (raynecarnes@gmail.com)