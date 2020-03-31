##############################################################################
# keylime TPM 2.0 Dockerfile
#
# This file is for automatic test running of Keylime.
# It is not recommended for use beyond testing scenarios.
##############################################################################

FROM fedora:31
MAINTAINER Luke Hinds <lhinds@redhat.com>
LABEL version="0.0.1" description="Keylime TPM Emulator"

# Packaged dependencies
RUN dnf -y update
RUN dnf -y install dnf-plugins-core --allowerasing
RUN dnf -y install glib2-devel \
           python3-devel \
           libselinux-python3 \
           selinux-policy \
           selinux-policy-targeted \
           ansible
           
ENV TPM2TOOLS_TCTI=mssim:host=localhost,port=2321 
ENV ansible_python_interpreter=/usr/bin/python3

COPY . .
RUN ansible-playbook --connection=local --inventory 127.0.0.1, playbook.yml
