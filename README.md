Ansible Keylime
===============

[![Build Status](https://travis-ci.org/keylime/ansible-keylime-soft-tpm.svg?branch=master)](https://travis-ci.org/keylime/ansible-keylime-soft-tpm) [![Gitter chat](https://badges.gitter.im/gitterHQ/gitter.png)](https://gitter.im/keylime-project/community)

Ansible role to deploy [Python Keylime](https://github.com/keylime/python-keylime) and a TPM Emulator,
alongside the  [Keylime rust cloud node](https://github.com/keylime/rust-keylime)
on Fedora release 29.

For details on using Keylime, please consult the
[project documentation](http://keylime-docs.rtfd.io/)

Please note that the rust cloud node is still under early stages of Development.
Those wishing to test drive keylimes functionality should use the existing
python based cloud node `keylime_node` until later notice.

Secutrity Warning
-----------------

This role deploys with a software TPM Emulator.

Do not use a software TPM emulator in a production environment.

This role is solely for the use of developement or demonstration purposes.

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

If you prefer, a Vagrantfile is available for provisioning.

Clone the repository and then simply run `vagrant up --provider <provider> --provision`

For example, using libvirt:

```
vagrant up --provider libvirt --provision
```

For example, using VirtualBox:

```
vagrant up --provider virtualbox --provision
```

Once the VM is started, vagrant ssh into the VM and run `sudo su - to
become root.

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

Rust Cloud node
---------------

To start the rust cloud node, navigate to it's repository directory and use
cargo to run:

```
[root@localhost rust-keylime]# RUST_LOG=keylime_node=trace cargo run
    Finished dev [unoptimized + debuginfo] target(s) in 0.28s
     Running `target/debug/keylime_node`
 INFO  keylime_node > Starting server...
 INFO  keylime_node > Listening on http://127.0.0.1:1337
```

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
