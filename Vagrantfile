Vagrant.configure("2") do |config|
   config.vm.box = "fedora/30-cloud-base"
   config.vm.synced_folder "/home/luke/repos/keylime/keylime", "/root/keylime-dev", type: "sshfs"
   config.vm.provider "libvirt" do |vb|
     vb.random :model => 'random'
     vb.memory = "4096"
     vb.cpus = "4"
   end
   config.vm.provision "ansible_local" do |ansible|
       ansible.playbook = "playbook.yml"
  end
end
