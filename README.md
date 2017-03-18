# Sutakku (スタック)

      ______                   _     _                =====
     / _____)        _        | |   | |               =   =
    ( (____  _   _ _| |_ _____| |  _| |  _ _   _      =====
     \____ \| | | (_   _|____ | |_/ ) |_/ ) | | |     ===== =====
     _____) ) |_| | | |_/ ___ |  _ (|  _ (| |_| |     =   = =   =
    (______/|____/   \__)_____|_| \_)_| \_)____/      ===== =====
     ====================-------------------------------------------------

> NOTE: **This is a personal time project and NOT officially affiliated
> or supported in any way!**

## What?

Sutakku is an Ansible meta role that creates a *HashiStack* made of the
following technologies:

- [Consul](https://www.consul.io/) 3 server cluster
- [Nomad](https://www.nomadproject.io/) cluster (optionally with Docker)
- [Vault](https://www.vaultproject.io/) cluster with Consul HA back-end

## Why?

For examining, integrating, learning, reproductions, testing...

## Requirements

- A minimum of 3 systems with specs like:
 - 2 CPU cores
 - 1GB RAM
 - 2 network interfaces (optional)
- Debian or RHEL based OS
- sshd enabled with key based logins (for Ansible)
- GNU `tar` / `gtar` in your management system's PATH (for Ansible)

The VMs used by the `Vagrantfile` in this role meet the above requirements.

## Role Variables

The role specifies the following variables in `defaults/main.yml`:

| Name           | Default Value | Description                        |
| -------------- | ------------- | -----------------------------------|
| `sutakku_bin_path` | `./bin` | Path for local binaries |
| `sutakku_user` | vagrant | Remote username |
| `sutakku_bin_path` | path | Relative path to install local binaries into |
| `sutakku_consul_version` | version string | Consul version |
| `sutakku_consul_linux_zip_url` | URL | Consul zip URL |
| `sutakku_consul_macos_zip_url` | URL |  Consul zip URL |
| `sutakku_consul_checksum_file_url` | URL | URL to checksums |
| `sutakku_nomad_version` | version string | Nomad version |
| `sutakku_nomad_linux_zip_url` | URL | Nomad zip URL |
| `sutakku_nomad_macos_zip_url` | URL |  Nomad zip URL |
| `sutakku_nomad_checksum_file_url` | URL | URL to checksums |
| `sutakku_vault_version` | version string | Vault version |
| `sutakku_vault_linux_zip_url` | URL | Vault zip URL |
| `sutakku_vault_macos_zip_url` | URL |  Vault zip URL |
| `sutakku_vault_checksum_file_url` | URL | URL to checksums |
| `sutakku_consul_template_version` | version string | Consul template version |
| `sutakku_envconsul_version` | version string | envconsul version |
| `sutakku_consul_template_checksum_file_url` | URL | URL to checksums |
| `sutakku_envconsul_checksum_file_url` | URL | URL to checksums |

The other variables generally do not need overriding unless you want to
change the installed versions.

## Dependencies

This role depends on these roles:

- [brianshumate.consul](https://galaxy.ansible.com/brianshumate/consul/)
- [brianshumate.nomad](https://galaxy.ansible.com/brianshumate/nomad/)
- [brianshumate.vault](https://galaxy.ansible.com/brianshumate/vault/)

### Vagrant Mini Environment

You can use this role to stand up a complete HashiStack mini environment!

If you wish to use the Vagrant and VirtualBox mini environment
(for development/evaluation), then the following prerequisites are required:

- VirtualBox (version 5.1.14 known to work)
- Vagrant (version 1.9.1 known to work)
- Vagrant Hosts plugin (version 2.8.0 known to work)

> Each of the virtual machines for this environment are configured with 1GB
> RAM, 2 CPU cores, and 2 network interfaces. The primary interface uses
> NAT and has connection via the host to the outside world. The secondary
> interface is a private network and is used for VM intra-cluster
> communication in addition to access from the host machine's LAN.

#### Step One

To use the Vagrant mini environment, ensure that the requirements above are
installed and the following IP addresses are resolved to the
correct hostnames:

```
10.1.42.101 sutakku1.local sutakku1
10.1.42.102 sutakku2.local sutakku2
10.1.42.103 sutakku3.local sutakku3
```

This can be done with your preferred DNS solution or by adding them to
your system's `/etc/hosts` file; the included `bin/preinstall` script adds
the correct entries to your development system's hosts file file for you.

#### Step Two

Install all of the required Ansible roles from Galaxy:

```
ansible-galaxy install \
brianshumate.consul \
brianshumate.nomad \
brianshumate.vault
```

#### Step Three

From this project's main directory (the one containing `Vagrantfile`),
start the show:

```
vagrant up
```

#### Anything Else?

There are some special environment variables which change the default
installation, and add more functionality. For example, if you want to
forward DNS from port 53 into Consul with DNSMasq on the nodes, set
`CONSUL_DNSMASQ="true"` like so:

```
CONSUL_DNSMASQ_ENABLE="true" vagrant up
```

Similarly, you can pass in a `BOX_NAME` to specify a different Linux
distribution via an alternative box:

```
BOX_NAME="centos/7" CONSUL_DNSMASQ_ENABLE="true" vagrant up
```

Currently documented environment variables:

| Name           | Default Value | Description                        |
| -------------- | ------------- | -----------------------------------| 
| `ANSIBLE_PLAYBOOK` | `site.yml` | Ansible playbook filename |
| `BOX_MEM` | *1536* | Per node RAM |
| `BOX_NAME` | *debian/jessie64* | Vagrant box name |
| `CLUSTER_HOSTS` | `vagrant_hosts` | Inventory filename |
| `CONSUL_DNSMASQ_ENABLE` | *false* | Enable DNSMasq forwarding |
| `CONSUL_LOGLEVEL` | *INFO* | Consul logging level |

##### Local CLI Binaries

This role also installs matching local copies of the tools into the role's 
`bin` directory so that you can access the HashiStack from your host system
using the CLI commands.

It tries to determine your host OS/distribution with Ansible and installs
the correct binaries. For example, if you use a Mac with this mini env
something like this will work when run in the project directory after
completion of all Ansible plays:

```
export NOMAD_ADDR="http://sutakku1.local:4646"
./bin/nomad server-members
```

and it should *just work*.

You can `source bin/sutakkuexports` to have the role's `bin` directory added
to your PATH and some key related environment variables exported:

```
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/bin"
export PATH="$SCRIPT_DIR:$PATH"
export CONSUL_HTTP_ADDR="sutakku1.local:8500"
export CONSUL_RPC_ADDR="sutakku1.local:8400"
export NOMAD_ADDR="http://sutakku3.local:4646"
export VAULT_ADDR="http://sutakku1.local:8200"
```

#### Next Steps

Check the status of your Consul cluster peers:

```
export CONSUL_HTTP_ADDR="sutakku1.local:8500"
./bin/consul operator raft -list-peers
Node  ID                Address           State     Voter
sutakku1  10.1.42.101:8300  10.1.42.101:8300  follower  true
sutakku2  10.1.42.102:8300  10.1.42.102:8300  follower  true
sutakku3  10.1.42.103:8300  10.1.42.103:8300  leader    true
```

Try out the Consul web UI at: http://sutakku1.local:8500/ui/ to see what's going
on with the registered services in your HashiStack.

Check out the Nomad servers:

```
export NOMAD_ADDR="http://sutakku1.local:4646"
./bin/nomad server-members
Name         Address      Port  Status  Leader  Protocol  Build  Datacenter  Region
sutakku1.global  10.1.42.101  4648  alive   true    2         0.4.1  dc1         global
sutakku2.global  10.1.42.102  4648  alive   false   2         0.4.1  dc1         global
sutakku3.global  10.1.42.103  4648  alive   false   2         0.4.1  dc1         global
```

##### Vault

Initialize Vault...

```
export VAULT_ADDR="http://sutakku1.local:8200"
./bin/vault init
Unseal Key 1: IHOBsdPuZ+g6b8oab6NuDnejfnCLYt4cjZ9QvwM3m5YB
Unseal Key 2: KyGe1K/XqeD4o4G2Pbl6qecSnvepoPK1BVPsQNxAnYEC
Unseal Key 3: aQbKwP4wT5Eld2/Q/VRmTAden1ABWTGyTUrFJrMVUToD
Unseal Key 4: 6VLiONKCADEXEebrtGOiFe2BB1gFiAvqBYZ5v7Qw50cE
Unseal Key 5: q3W2LINl5kDKxQiNdI6+8A3NBv+tccjtTZ9Q2dtlK/wF
Initial Root Token: bb4f6b1d-c92f-72eb-3b23-0c9a5483fa4e

Vault initialized with 5 keys and a key threshold of 3. Please
securely distribute the above keys. When the Vault is re-sealed,
restarted, or stopped, you must provide at least 3 of these keys
to unseal it again.

Vault does not store the master key. Without at least 3 keys,
your Vault will remain permanently sealed.
```

then use the unseal keys and initial root token to begin writing/reading
secrets, enabling back-ends, policies, and more!

For example, your can perform a quick unseal of all 3 nodes:

```
for i in {1..3}; do
VAULT_ADDR="http://sutakku${i}.local:8200" \
vault unseal IHOBsdPuZ+g6b8oab6NuDnejfnCLYt4cjZ9QvwM3m5YB && \
VAULT_ADDR="http://sutakku${i}.local:8200" \
vault unseal aQbKwP4wT5Eld2/Q/VRmTAden1ABWTGyTUrFJrMVUToD && \
VAULT_ADDR="http://sutakku${i}.local:8200" \
vault unseal q3W2LINl5kDKxQiNdI6+8A3NBv+tccjtTZ9Q2dtlK/wF;
done
```

Have fun!

#### Extras

> **BUT WAIT — THERE'S MORE!**

In addition to the already great HashiStack mini cluster environment,
this role also installs some neat related open source tools:

- [Consul Template](https://github.com/hashicorp/consul-template)
- [envconsul](https://github.com/hashicorp/envconsul)

You'll find the latest binary versions in `bin` of this role after you have
successfully executed it.
 
## Notes

- This project uses Debian 8 (Jessie) by default, but you can choose another
  OS distribution with the *BOX_NAME* environment variable
- The `bin/preinstall` shell script performs the following actions for you:
  * Adds each node's host information to the host machine's `/etc/hosts`
  * Optionally installs the Vagrant hosts plugin
- If you notice an error like *vm: The '' provisioner could not be found.*
  make sure you have vagrant-hosts plugin installed

Check out each project's getting started guides and documentation for
more details:

### Consul

- [Consul Getting Started](https://www.consul.io/intro/getting-started/install.html)
- [Consul Documentation](https://www.consul.io/docs/index.html)

### Nomad

- [Nomad Getting Started](https://www.nomadproject.io/intro/getting-started/install.html)
- [Nomad Documentation](https://www.nomadproject.io/docs/index.html)

### Vault

- [Vault Getting Started](https://www.vaultproject.io/intro/getting-started/install.html)
- [Vault Documentation](https://www.vaultproject.io/docs/index.html)

## License

BSD

## Author Information

[Brian Shumate](http://brianshumate.com)
