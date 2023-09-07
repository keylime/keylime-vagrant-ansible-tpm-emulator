# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'getoptlong'
require 'yaml'

opts = GetoptLong.new(
  [ '--instances', GetoptLong::OPTIONAL_ARGUMENT ],
  [ '--repo', GetoptLong::OPTIONAL_ARGUMENT ],
  [ '--agent-repo', GetoptLong::OPTIONAL_ARGUMENT ],
  [ '--cpus', GetoptLong::OPTIONAL_ARGUMENT ],
  [ '--memory', GetoptLong::OPTIONAL_ARGUMENT ],
  [ '--verbose', GetoptLong::NO_ARGUMENT ],
  [ '--qualityoflife', GetoptLong::NO_ARGUMENT ]
)

config_file = File.expand_path(File.join(File.dirname(__FILE__), 'vagrant_variables.yml'))

settings={}
if File.exist?(config_file)
  settings = YAML.load_file(config_file)
end

# Use defaults defined in vagrant variables file, otherwise set defaults.
instances  = settings['instances']  ? settings['instances']  : 1
cpus       = settings['cpus']       ? settings['cpus']       : 2
memory     = settings['memory']     ? settings['memory']     : 2048
repo       = settings['repo']       ? settings['repo']       : ''
agent_repo = settings['agent-repo'] ? settings['agent-repo'] : ''
verbose    = settings['verbose']    ? settings['verbose']    : false
qualityoflife   = settings['qualityoflife']   ? settings['qualityoflife']   : false

opts.ordering=(GetoptLong::REQUIRE_ORDER)

# Command line options take precedence i.e. override any defaults if command
# line options are provided.
opts.each do |opt, arg|
  case opt
    when '--instances'
      instances = arg.to_i
    when '--repo'
      repo = arg
    when '--agent-repo'
      agent_repo = arg
    when '--cpus'
      cpus = arg.to_i
    when '--memory'
      memory = arg.to_i
    when '--verbose'
      verbose = true
    when '--qualityoflife'
      qualityoflife = true
  end
end

Vagrant.configure("2") do |config|
  (1..instances).each do |i|
    config.vm.define "keylime-fedora#{i}" do |keylime|
      keylime.vm.box = "fedora/38-cloud-base"
      # Should you require machines to share a private network
      # Note, you will need to create the network first within
      # your provider (VirtualBox / Libvirt etc)
      # keylime.vm.network :private_network, ip: "10.0.0.#{i}1"

      # Uncomment the following to forward ports on the VM and
      # allow access to Keylime components from the host machine.
      keylime.vm.network "forwarded_port", guest: 443, host: "844#{i}"
      # Forward Cloud Verifier listen port:
      #keylime.vm.network "forwarded_port", guest: 8881, host: "8881"
      # Forward Cloud Verifier revocation port:
      #keylime.vm.network "forwarded_port", guest: 8892, host: "8892"
      # Forward registrar listen port:
      #keylime.vm.network "forwarded_port", guest: 8890, host: "8890"
      # Forward registrar TLS listen port:
      #keylime.vm.network "forwarded_port", guest: 8891, host: "8891"
      # Forward agent listen port:
      #keylime.vm.network "forwarded_port", guest: 9002, host: "9002"
      if instances == 1
        hostname = "keylime-fedora"
      else
        hostname = "keylime-fedora#{i}"
      end
      keylime.vm.hostname = "#{hostname}"
      if !repo.empty?
        keylime.vm.synced_folder "#{repo}", "/root/keylime-dev", type: "sshfs"
      end
      if !agent_repo.empty?
        keylime.vm.synced_folder "#{agent_repo}", "/root/keylime-rust-dev", type: "sshfs"
      end
      keylime.vm.provider "virtualbox" do |v|
        v.memory = "#{memory}"
        v.cpus = "#{cpus}"
        v.customize ["modifyvm", :id, "--audio", "none"]
      end
      keylime.vm.provider "libvirt" do |vb|
        vb.random :model => 'random'
        vb.memory = "#{memory}"
        vb.cpus = "#{cpus}"
      end

      # remove the last download of ansible-keylime role and
      # download the latest ansible-keylime role from github
      keylime.vm.provision "shell", inline: <<-SHELL
        rm -rf /vagrant/roles/ansible-keylime
        TMP_DIR="/tmp/keylime-vagrant-ansible-install"
        mkdir -p ${TMP_DIR}
        cd $TMP_DIR
        curl -s -L https://github.com/keylime/ansible-keylime/tarball/master -o ansible-keylime.tar.gz
        tar -zxf ansible-keylime.tar.gz
        cd keylime-ansible-keylime-*
        mv roles/ansible-keylime /vagrant/roles/
      SHELL

      keylime.vm.provision "ansible_local" do |ansible|
          ansible.playbook = "playbook.yml"
          ansible.extra_vars = {
            ansible_python_interpreter:"/usr/bin/python3",
          }
          if defined? (verbose) and verbose == true
            ansible.verbose = "vvv"
          end
      end
      if defined? (qualityoflife) and qualityoflife == true
        keylime.vm.provision "ansible_local" do |ansible|
            ansible.playbook = "quality_of_life.yml"
            if defined? (verbose) and verbose == true
              ansible.verbose = "vvv"
            end
        end
      end

      # reboot after provisioning since some setting changes require it
      keylime.vm.provision :shell do |shell|
          shell.privileged = true
          shell.inline = 'echo rebooting'
          shell.reboot = true
      end
    end
  end
end
