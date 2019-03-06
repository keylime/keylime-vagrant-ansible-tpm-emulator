Ansible Keylime
===============

[![Build Status](https://travis-ci.org/keylime/ansible-keylime.svg?branch=master)](https://travis-ci.org/keylime/ansible-keylime)

##### *Note: This playbook is still under early Development.*

Ansible role to deploy [MIT's Python Keylime](https://github.com/mit-ll/python-keylime),
it's [IBM emulator port](https://github.com/mit-ll/tpm4720-keylime)
and the [Keylime rust cloud node](https://github.com/redhat-university-partnerships/keylime)
on Fedora release 28 (at present, plans to extend).

For details on using Python Keylime, please consult the
[project documentation](https://github.com/mit-ll/python-keylime/blob/master/README.md)

Please note that the rust cloud node is still under early stages of Development.
Those wishing to test drive keylimes functionality should use the existing
python based cloud node `keylime_node`

Usage
-----

Run the example playbook against your target remote node(s).

```
ansible-playbook -i your_hosts playbook.yml
```

#### Vagrant

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

#### TPM Version Control

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

Author Information
------------------

Luke Hinds (lhinds@redhat.com)
