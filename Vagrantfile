# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.

VAGRANT_ROOT = File.dirname(File.expand_path(__FILE__))
ephemeral_disk_controller = File.join(VAGRANT_ROOT, 'controller.vdi')
ephemeral_disk_compute1 = File.join(VAGRANT_ROOT, 'compute1.vdi')

Vagrant.configure("2") do |config|

  config.vm.define "controller" do |controller|
    controller.vm.box = "ubuntu/xenial64"

    # Create a forwarded port mapping which allows access to a specific port
    # within the machine from a port on the host machine. In the example below,
    # accessing "localhost:8080" will access port 80 on the guest machine.
    # NOTE(andreaf) Port 443 is needed by devstack but cannot be forwarded by
    # virtualbox since it's privileged. Use an ssh tunnel instead, e.g.
    #
    # sudo ssh -p 2222 -gNfL 443:localhost:443 ubuntu@localhost -i [path to key]  #

    # Create a private network, which allows host-only access to the machine
    # using a specific IP. Static IP is required to:
    # - avoid overlap with other VMs
    # - use fixed inventory file
    controller.vm.network :private_network, ip: "192.168.56.101"
    controller.vm.network :private_network, ip: "fddd::10"
    controller.vm.hostname = "controller"

    controller.vm.provider "virtualbox" do |vb|
      # Display the VirtualBox GUI when booting the machine
      vb.gui = false

      # Customize the amount of memory and CPU for the VM:
      vb.memory = "8192"
      vb.cpus = "4"

      # Customize the VM name
      vb.name = "controller"

      unless File.exist?(ephemeral_disk_controller)
        vb.customize ['createhd', '--filename', ephemeral_disk_controller, '--size', 9 * 1024]
      end
      vb.customize ['storageattach', :id, '--storagectl', 'SCSI', '--port', 2, '--device', 0, '--type', 'hdd', '--medium', ephemeral_disk_controller]
    end

    # Sync git repos to src in the home of the ssh user.
    # Zuul and other roles expect them in there.
    controller.vm.synced_folder "git", "/opt/git", create: true, owner: "ubuntu", group: "ubuntu"
    controller.vm.synced_folder "cache", "/opt/cache", create: true, owner: "ubuntu", group: "ubuntu"

  end

  config.vm.define "compute1" do |compute1|
    compute1.vm.box = "ubuntu/xenial64"

    # Create a forwarded port mapping which allows access to a specific port
    # within the machine from a port on the host machine. In the example below,
    # accessing "localhost:8080" will access port 80 on the guest machine.
    # NOTE(andreaf) Port 443 is needed by devstack but cannot be forwarded by
    # virtualbox since it's privileged. Use an ssh tunnel instead, e.g.
    #
    # sudo ssh -p 2222 -gNfL 443:localhost:443 ubuntu@localhost -i [path to key]  #

    # Create a private network, which allows host-only access to the machine
    # using a specific IP. Static IP is required to:
    # - avoid overlap with other VMs
    # - use fixed inventory file
    compute1.vm.network :private_network, ip: "192.168.56.102"
    compute1.vm.network :private_network, ip: "fddd::11"
    compute1.vm.hostname = "compute1"

    compute1.vm.provider "virtualbox" do |vb|
      # Display the VirtualBox GUI when booting the machine
      vb.gui = false

      # Customize the amount of memory and CPU for the VM:
      vb.memory = "8192"
      vb.cpus = "4"

      # Customize the VM name
      vb.name = "compute1"

      unless File.exist?(ephemeral_disk_compute1)
        vb.customize ['createhd', '--filename', ephemeral_disk_compute1, '--size', 9 * 1024]
      end
      vb.customize ['storageattach', :id, '--storagectl', 'SCSI', '--port', 2, '--device', 0, '--type', 'hdd', '--medium', ephemeral_disk_compute1]
    end

    # Sync git repos to src in the home of the ssh user.
    # Zuul and other roles expect them in there.
    compute1.vm.synced_folder "git", "/opt/git", create: true, owner: "ubuntu", group: "ubuntu"
    compute1.vm.synced_folder "cache", "/opt/cache", create: true, owner: "ubuntu", group: "ubuntu"

  end

  config.vm.provision "ansible" do |ansible|
    ansible.playbook = "setup.yaml"
    ansible.inventory_path = "inventory.yaml"
  end

end
