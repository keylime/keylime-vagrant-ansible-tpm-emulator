Vagrant.configure("2") do |config|
   
   config.vm.define "keylime1" do |keylime1|
     keylime1.vm.box = "fedora/30-cloud-base"
     
     keylime1.vm.network :private_network, ip: "10.0.0.10"
     keylime1.vm.hostname= "keylime1"
     keylime1.vm.synced_folder "/Users/andrewstoycos/Documents/classes_Fall2019/EC528/keylime_multiVM/keylime1", "/root/keylime-dev", type: "sshfs"
     keylime1.vm.network "forwarded_port", guest: 443, host: 8445
     keylime1.vm.provider "virtualbox" do |v|
     #keylime1.vm.synced_folder ".", "/vagrant"
      v.memory = "2048"
      v.cpus = "2"
     end
     keylime1.vm.provision "ansible_local" do |ansible|
         ansible.playbook = "playbook.yml"
         ansible.extra_vars = {
           ansible_python_interpreter:"/usr/bin/python3",
         }
         
    end
  end
   config.vm.define "keylime2" do |keylime2|
     keylime2.vm.box = "fedora/30-cloud-base"
     
     keylime2.vm.network :private_network, ip: "10.0.0.11"
     keylime2.vm.hostname= "keylime2"
     keylime2.vm.synced_folder "/Users/andrewstoycos/Documents/classes_Fall2019/EC528/keylime_multiVM/keylime2", "/root/keylime-dev", type: "sshfs"
     keylime2.vm.network "forwarded_port", guest: 442, host: 8443
     keylime2.vm.provider "virtualbox" do |v|
     #keylime2.vm.synced_folder ".", "/vagrant"
       v.memory = "2048"
       v.cpus = "2"
     end
     keylime2.vm.provision "ansible_local" do |ansible|
         ansible.playbook = "playbook.yml"
         ansible.extra_vars = {
           ansible_python_interpreter:"/usr/bin/python3",
         }
         
    end
     
  end
end

