# Puppet TeamCity module

The TeamCity puppet module installs the latest version of TeamCity from a [yum
repository](https://github.com/haf/puppet-yum) where you have a [package for
TeamCity](https://github.com/haf/fpm-recipes/tree/master/teamcity-server).

Provision a YUM repo with the above module, build the teamcity-server package,
and off you go!

If you don't have a package named 'teamcity-server', this module won't work.

Tested on CentOS 6.x.

## TeamCity::Server - Usage:

If you read the above introduction you know that you need a package for the
server, in order to install it. With a package, a lot of the setup is already
taken care of.

```puppet
class profiles::teamcity_server {
  include teamcity::server
}
```

This stanza does not include a default build agent; see below. Memory options
are configured to be the production values, so you'll need around 750 MiB for
the server's runtime.

## TeamCity::Agent - Usage:

When installing the agent, you first need a TeamCity server up and running, I
run mine at the A-name 'tc'. This is in the defaults of `teamcity::agent`, so if
you have a different name for your TeamCity server, I suggest you override it in
hiera:

```yaml
---
teamcity::agent::server_url:
  http://monkey-tc.local
```

Besides, that, here's a sample configuration profile that uses the TeamCity
Agent class:

```puppet
class profiles::teamcity_agent {
  include teamcity::agent
  include our_buildenv

  # when debugging the agent, I can't live without this
  teamcity::agent::env::bash_profile { 'alias g=git': }
}
```

It's worth noting that if you change the folders in the agent-class to be
outside of their default you're going to have to hack Catalina and a range of
other software you haven't touched before, to make it work. Simply, I couldn't,
despite spending about 3 hours on it, so just go with the default folders.

You'll need about 400 MiB minimum for each agent you want to run on a node.

### License

MIT


#### Good reading

http://plone.lucidsolutions.co.nz/software-development/continuous-integration/teamcity/howto-install-jetbrains-teamcity-v6.5.1-on-centos-v5.x
