Linode Vagrant Provider
==============================
`vagrant-linode` is a provider plugin for Vagrant that supports the
management of [Linode](https://www.linode.com/) linodes
(instances).

**NOTE:** The Chef provisioner is no longer supported by default (as of 0.2.0).
Please use the `vagrant-omnibus` plugin to install Chef on Vagrant-managed
machines. This plugin provides control over the specific version of Chef
to install.

Current features include:
- create and destroy linodes
- power on and off linodes
- rebuild a linode
- provision a linode with the shell or Chef provisioners
- setup a SSH public key for authentication
- create a new user account during linode creation

The provider has been tested with Vagrant 1.1.5+ using Ubuntu 12.04 and
CentOS 6.3 guest operating systems.

Install
-------
Installation of the provider requires two steps:

1. Install the provider plugin using the Vagrant command-line interface:

        $ vagrant plugin install vagrant-linode


**NOTE:** If you are using a Mac, and this plugin would not work caused by SSL certificate problem,
You may need to specify certificate path explicitly.  
You can verify actual certificate path by running:

```bash
ruby -ropenssl -e "p OpenSSL::X509::DEFAULT_CERT_FILE"
```

Then, add the following environment variable to your
`.bash_profile` script and `source` it:

```bash
export SSL_CERT_FILE=/usr/local/etc/openssl/cert.pem
```

Configure
---------
Once the provider has been installed, you will need to configure your project
to use it. The most basic `Vagrantfile` to create a linode on Linode
is shown below:

```ruby
Vagrant.configure('2') do |config|

  config.vm.provider :linode do |provider, override|
    override.ssh.private_key_path = '~/.ssh/id_rsa'
    override.vm.box = 'linode'
    override.vm.box_url = "https://github.com/displague/vagrant-linode/raw/master/box/linode.box"

    provider.token = 'YOUR TOKEN'
    provider.image = 'Ubuntu 14.04 x64'
    provider.datacenter = 'newark'
    provider.plan = '1024'
  end
end
```

Please note the following:
- You *must* specify the `override.ssh.private_key_path` to enable authentication
  with the linode. The provider will create a new Linode SSH key using
  your public key which is assumed to be the `private_key_path` with a *.pub*
  extension.
- You *must* specify your Linode Personal Access Token. This may be
  found on the control panel within the *Apps &amp; API* section.

**Supported Configuration Attributes**

The following attributes are available to further configure the provider:
- `provider.image` - A string representing the image to use when creating a
   new linode (e.g. `Debian 6.0 x64`). The available options may
   be found on Linode's new linode [form](https://cloud.linode.com/linodes/new).
   It defaults to `Ubuntu 14.04 x64`.
- `provider.region` - A string representing the region to create the new
   linode in. It defaults to `nyc2`.
- `provider.size` - A string representing the size to use when creating a
  new linode (e.g. `1gb`). It defaults to `512mb`.
- `provider.private_networking` - A boolean flag indicating whether to enable
  a private network interface (if the region supports private networking). It
  defaults to `false`.
- `provider.backups_enabled` - A boolean flag indicating whether to enable backups for
   the linode. It defaults to `false`.
- `provider.ssh_key_name` - A string representing the name to use when creating
  a Linode SSH key for linode authentication. It defaults to `Vagrant`.
- `provider.setup` - A boolean flag indicating whether to setup a new user
  account and modify sudo to disable tty requirement. It defaults to `true`.
  If you are using a tool like [packer](https://packer.io) to create
  reusable snapshots with user accounts already provisioned, set to `false`.

The provider will create a new user account with the specified SSH key for
authorization if `config.ssh.username` is set and the `provider.setup`
attribute is `true`.

### provider.region slug

Each region has been specify with slug name.  
Current Region-slug table is:

| slug    | Region Name         |
|:----    |:--------------------|
| dallas  | Dallas, TX, USA     |
| fremont | Fremont, CA, USA    |
| atlanta | Atlanta, GA, USA    |
| newark  | Newark, NJ, USA     |
| london  | London, England, UK |
| tokyo   | Tokyo, JP           |

You can find latest region slug name using Linode API V2 call.

- example call.

```
curl -X POST "https://api.linode.com/?api_action=avail.datacenters" \
     --data-ascii api_key="$LINODE_API_KEY" \
     2>/dev/null | jq '.DATA [] | .ABBR,.LOCATION'
```

More detail: [Linode API - Datacenters](https://www.linode.com/api/utility/avail.datacenters)

Run
---
After creating your project's `Vagrantfile` with the required configuration
attributes described above, you may create a new linode with the following
command:

    $ vagrant up --provider=linode

This command will create a new linode, setup your SSH key for authentication,
create a new user account, and run the provisioners you have configured.

**Supported Commands**

The provider supports the following Vagrant sub-commands:
- `vagrant destroy` - Destroys the linode instance.
- `vagrant ssh` - Logs into the linode instance using the configured user
  account.
- `vagrant halt` - Powers off the linode instance.
- `vagrant provision` - Runs the configured provisioners and rsyncs any
  specified `config.vm.synced_folder`.
- `vagrant reload` - Reboots the linode instance.
- `vagrant rebuild` - Destroys the linode instance and recreates it with the
  same IP address which was previously assigned.
- `vagrant status` - Outputs the status (active, off, not created) for the
  linode instance.

Contribute
----------
To contribute, clone the repository, and use [Bundler](http://gembundler.com)
to install dependencies:

    $ bundle

To run the provider's tests:

    $ bundle exec rake test

You can now make modifications. Running `vagrant` within the Bundler
environment will ensure that plugins installed in your Vagrant
environment are not loaded.
