Vagrant.configure("2") do |config|
   
   (1..2).each do |i|
      config.vm.define "keylime#{i}" do |keylime|
         keylime.vm.box = "fedora/30-cloud-base"
         keylime.vm.network :private_network, ip: "10.0.0.#{i}1"
         keylime.vm.hostname= "keylime#{i}"
         keylime.vm.synced_folder "/Users/andrewstoycos/Documents/classes_Fall2019/EC528/keylime_multiVM/keylime1", "/root/keylime-dev", type: "sshfs"
         keylime.vm.provider "virtualbox" do |v|
          v.memory = "2048"
          v.cpus = "2"
         end
         config.vm.provider "libvirt" do |vb|
           vb.random :model => 'random'
           vb.memory = "4096"
           vb.cpus = "4"
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

