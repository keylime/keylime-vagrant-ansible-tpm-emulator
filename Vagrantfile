# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'getoptlong'

opts = GetoptLong.new(
  [ '--instances', GetoptLong::OPTIONAL_ARGUMENT ],
  [ '--repo', GetoptLong::OPTIONAL_ARGUMENT ],
  [ '--cpus', GetoptLong::OPTIONAL_ARGUMENT ],
  [ '--memory', GetoptLong::OPTIONAL_ARGUMENT ]
)

# defaults

instances = 1
cpus = 2
memory = 2048


opts.ordering=(GetoptLong::REQUIRE_ORDER)

opts.each do |opt, arg|
  case opt
    when '--instances'
      instances = arg.to_i
    when '--repo'
      repo = arg
    when '--cpus'
      cpus = arg.to_i
    when '--memory'
      memory = arg.to_i
  end
end

Vagrant.configure("2") do |config|
   (1..instances).each do |i|
      config.vm.define "keylime#{i}" do |keylime|
         keylime.vm.box = "fedora/31-cloud-base"
         keylime.vm.network :private_network, ip: "10.0.0.#{i}1"
         if instances == 1
           hostname = "keylime"
         else
           hostname = "keylime#{i}"
         end
         keylime.vm.hostname = "#{hostname}"
         if defined? (repo)
           keylime.vm.synced_folder "#{repo}", "/root/keylime-dev", type: "sshfs"
         end
         keylime.vm.provider "virtualbox" do |v|
          v.memory = "#{memory}"
          v.cpus = "#{cpus}"
         end
         keylime.vm.provider "libvirt" do |vb|
           vb.random :model => 'random'
           vb.memory = "#{memory}"
           vb.cpus = "#{cpus}"
         end
         keylime.vm.provision "ansible_local" do |ansible|
             ansible.playbook = "playbook.yml"
             ansible.extra_vars = {
               ansible_python_interpreter:"/usr/bin/python3",
             }
           end
        end
    end
end