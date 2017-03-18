# -*- mode: ruby -*-
# vi: set ft=ruby :
#
# Vagrantfile for bootstrapping a Sutakku cluster with
# VirtualBox provider and Ansible provisioner
#
# This inline script is called with a script provisioner on each box
# to do utility work for handling corner cases in different boxes and
# operating systems, such as installing Python on official FreeBSD boxes, etc.
#
$script = <<SCRIPT
check_os () {
  PLATFORM="unknown"
  UNAMESTR="$(uname)"
    if test "$UNAMESTR" = "Linux"; then
      PLATFORM="linux"
    elif test "$UNAMESTR" = "FreeBSD"; then
      PLATFORM="freebsd"
    fi
}

## Install Python on FreeBSD
check_os

if test "$PLATFORM" = "freebsd"; then
  echo "FreeBSD guest detected: installing Python ..."
    if pkg install -y python > /dev/null 2>&1; then
      echo "Done!"
    else
      echo >2 "Problem installing Python!"
    fi
  echo "Linking Python ..."
    if ln -s /usr/local/bin/python /usr/bin/python; then
      echo "Done!"
    else
      echo 2> "Problem linking Python!"
    fi
fi
SCRIPT

ANSIBLE_PLAYBOOK = ENV['ANSIBLE_PLAYBOOK'] || "sutakku.yml"
BOX_MEM = ENV['BOX_MEM'] || "1024"
BOX_NAME =  ENV['BOX_NAME'] || "debian/jessie64"
CLUSTER_HOSTS = ENV['CLUSTER_HOSTS'] || "vagrant_hosts"
CONSUL_DNSMASQ_ENABLE = ENV['CONSUL_DNSMASQ_ENABLE'] || "false"
CONSUL_LOGLEVEL = ENV['CONSUL_LOGLEVEL'] || "INFO"
VAGRANTFILE_API_VERSION = "2"

Vagrant.require_version ">= 1.8.0"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  if BOX_NAME.include? "freebsd"
    CONSUL_IFACE = "em1"
  else
    CONSUL_IFACE = ENV['CONSUL_IFACE'] || "eth1"
  end
  # Configure 3 nodes
  config.vm.define :sutakku1 do |sutakku1_config|
    sutakku1_config.vm.box = BOX_NAME
    # FreeBSD needs a MAC, disabled synced folder, and explicit shell
    sutakku1_config.vm.base_mac = "080027D47374"
    sutakku1_config.vm.synced_folder ".", "/vagrant", disabled: true
    sutakku1_config.ssh.shell = "/bin/sh"
    sutakku1_config.vm.network :private_network, ip: "10.1.42.101"
    sutakku1_config.vm.hostname = "sutakku1.local"
    sutakku1_config.ssh.forward_agent = true
    sutakku1_config.vm.provider "virtualbox" do |v|
      v.name = "sutakku-node1"
      v.customize ["modifyvm", :id, "--memory", BOX_MEM]
      v.customize ["modifyvm", :id, "--ioapic", "on"]
      v.customize ["modifyvm", :id, "--cpus", "2"]
      v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      v.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
    sutakku1_config.vm.post_up_message = "Sutakku spun up!"
    end
    if ENV['NOMAD_DOCKER_ENABLE'] == "true"
      sutakku1_config.vm.provision "docker"
    end
    sutakku1_config.vm.provision :hosts do |provisioner|
        provisioner.add_host '10.1.42.101', ['sutakku1.local']
        provisioner.add_host '10.1.42.102', ['sutakku2.local']
        provisioner.add_host '10.1.42.103', ['sutakku3.local']
    end
    sutakku1_config.vm.provision "shell", inline: $script
  end
  config.vm.define :sutakku2 do |sutakku2_config|
    sutakku2_config.vm.box = BOX_NAME
    # FreeBSD needs a MAC, disabled synced folder, and explicit shell
    sutakku2_config.vm.base_mac = "080027D57374"
    sutakku2_config.vm.synced_folder ".", "/vagrant", disabled: true
    sutakku2_config.ssh.shell = "/bin/sh"
    sutakku2_config.vm.network :private_network, ip: "10.1.42.102"
    sutakku2_config.vm.hostname = "sutakku2.local"
    sutakku2_config.ssh.forward_agent = true
    sutakku2_config.vm.provider "virtualbox" do |v|
      v.name = "sutakku-node2"
      v.customize ["modifyvm", :id, "--memory", BOX_MEM]
      v.customize ["modifyvm", :id, "--ioapic", "on"]
      v.customize ["modifyvm", :id, "--cpus", "2"]
      v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      v.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
    sutakku2_config.vm.post_up_message = "Sutakku spun up!"
    end
    if ENV['NOMAD_DOCKER_ENABLE'] == "true"
      sutakku2_config.vm.provision "docker"
    end
    sutakku2_config.vm.provision :hosts do |provisioner|
        provisioner.add_host '10.1.42.101', ['sutakku1.local']
        provisioner.add_host '10.1.42.102', ['sutakku2.local']
        provisioner.add_host '10.1.42.103', ['sutakku3.local']
    end
    sutakku2_config.vm.provision "shell", inline: $script
  end
  config.vm.define :sutakku3 do |sutakku3_config|
    sutakku3_config.vm.box = BOX_NAME
    # FreeBSD needs a MAC, disabled synced folder, and explicit shell
    sutakku3_config.vm.base_mac = "080027D67374"
    sutakku3_config.vm.synced_folder ".", "/vagrant", disabled: true
    sutakku3_config.ssh.shell = "/bin/sh"
    sutakku3_config.vm.network :private_network, ip: "10.1.42.103"
    sutakku3_config.vm.hostname = "sutakku3.local"
    sutakku3_config.ssh.forward_agent = true
    sutakku3_config.vm.provider "virtualbox" do |v|
      v.name = "sutakku-node3"
      v.customize ["modifyvm", :id, "--memory", BOX_MEM]
      v.customize ["modifyvm", :id, "--ioapic", "on"]
      v.customize ["modifyvm", :id, "--cpus", "2"]
      v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      v.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
    sutakku3_config.vm.post_up_message = "Sutakku spun up!\n\n`source bin/sutakku_exports` to rock on with local CLI tools!"
    end
    if ENV['NOMAD_DOCKER_ENABLE'] == "true"
      sutakku3_config.vm.provision "docker"
    end
    sutakku3_config.vm.provision :hosts do |provisioner|
        provisioner.add_host '10.1.42.101', ['sutakku1.local']
        provisioner.add_host '10.1.42.102', ['sutakku2.local']
        provisioner.add_host '10.1.42.103', ['sutakku3.local']
    end
    sutakku3_config.vm.provision "shell", inline: $script
    sutakku3_config.vm.provision :ansible do |ansible|
      ansible.inventory_path = CLUSTER_HOSTS
      # As if variable related things in Ansible couldn't be more exciting,
      # extra Ansible variables can be defined here as well. Wheeee!
      #
      ansible.extra_vars = {
        consul_dnsmasq: CONSUL_DNSMASQ_ENABLE,
        consul_log_level: CONSUL_LOGLEVEL
      }
      ansible.playbook = ANSIBLE_PLAYBOOK
      ansible.limit = "all"
    end
  end
end
