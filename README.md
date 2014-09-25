# Puppet TeamCity module

The TeamCity puppet module downloads and installs the latest version of TeamCity.
Also allows plugins to be installed. 

Tested on CentOS 6.x.

## TeamCity::Server - Usage:


```puppet
 class { 'oraclejava::jdk7_rpm': }
 
 class { 'teamcity::server':
    require => Class['oraclejava::jdk7_rpm'],
 }

 class { 'teamcity::server::plugin':
    plugin_url       => 'http://teamcity.jetbrains.com/guestAuth/repository/download/bt434/.lastSuccessful/jonnyzzz.node.zip',
    plugin_zip_file  => 'jonnyzzz.node.zip',
    require          => Class['teamcity::server'],
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
teamcity::agent::server_url: http://192.168.33.31:8111
```

Besides, that, here's a sample configuration profile that uses the TeamCity
Agent class:

```puppet
 class { 'oraclejava::jdk7_rpm': }
 
 class { 'teamcity::agent':
    require => Class['oraclejava::jdk7_rpm'],
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
