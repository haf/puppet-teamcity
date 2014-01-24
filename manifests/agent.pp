class teamcity::agent(
  $user            = 'teamcity-agent',
  $server_url      = 'http://tc-server-01:8111',
  $agent_name      = $::hostname,
  $own_port        = 9090,
  $own_address     = '',         # default to empty string to let build agent detect it
  $home            = '/opt/teamcity-agent',
  $agent_opts      = '',         # TODO: expose in teamcity-agent.erb
  $agent_mem_opts  = '-Xmx384m', # TODO: expose in teamcity-agent.erb
  $properties      = {},
  $manage_firewall = hiera('manage_firewall', false)
) {
  $service         = 'teamcity-agent'
  $bin_dir         = "$home/bin"
  $work_dir        = "$home/work"
  $temp_dir        = "$home/temp"
  $system_dir      = "$home/system"
  $conf_dir        = "$home/conf"
  $plugins_dir     = "$home/plugins"
  $lib_dir         = "$home/lib"
  $launcher_dir    = "$home/launcher"
  $contrib_dir     = "$home/contrib"

  anchor { 'teamcity::agent::start': }

  include teamcity::common
  include teamcity::agent::install
  include teamcity::agent::env

  user { $user:
    ensure  => present,
    system  => true,
    home    => $home,
    gid     => $teamcity::common::group,
    require => Anchor['teamcity::agent::start'],
    before  => Anchor['teamcity::agent::end'],
  }

  teamcity::agent::env::bash_profile { 'env:WORK_DIR':
    content => "export AGENT_WORK_DIR=\"$work_dir\""
  }

  $has_done_chown = '/etc/teamcity-agent.chown'

  # change the permissions of the agent installation.
  exec { 'teamcity::agent chown':
    command     => "/bin/chown -R ${user}:${teamcity::common::group} ${home}* && /bin/touch $has_done_chown",
    creates     => $has_done_chown,
    subscribe   => Class['teamcity::agent::install'],
    require     => [
      Anchor['teamcity::agent::start'],
      User[$user],
      File[$home]
    ],
    before  => Anchor['teamcity::agent::end'],
  }

  file { "$home/conf/buildAgent.properties":
    ensure  => present,
    replace => false,
    content => template('teamcity/buildAgent.properties.erb'),
    owner   => $user,
    group   => $teamcity::common::group,
    mode    => '0644',
    require => [
      Anchor['teamcity::agent::start'],
      Exec['teamcity::agent chown']
    ],
    before  => Anchor['teamcity::agent::end'],
  }

  file { "$home/bin/agent.sh":
    mode    => '0755',
    require => [
      Anchor['teamcity::agent::start'],
      File[$home],
      Class['teamcity::agent::install']
    ],
    before  => Anchor['teamcity::agent::end'],
  }

  file { "/etc/init.d/$service":
    ensure  => present,
    content => template('teamcity/teamcity-agent.erb'),
    mode    => '0755',
    require => Anchor['teamcity::agent::start'],
    before  => Anchor['teamcity::agent::end'],
  }

  service { $service:
    ensure     => running,
    enable     => true,
    status     => 'ps aux | grep /usr/bin/java | grep AgentMain',
    hasstatus  => false,
    hasrestart => true,
    require    => [
      Anchor['teamcity::agent::start'],
      Class['java'],
      Class['teamcity::common'],
      File["$home/bin/agent.sh"],
      File["/etc/init.d/$service"]
    ],
    before     => Anchor['teamcity::agent::end'],
  }

  if $manage_firewall {
    firewall { "101 allow agent-connections:$own_port":
      proto   => 'tcp',
      state   => ['NEW'],
      dport   => $own_port,
      action  => 'accept',
      require => Anchor['teamcity::agent::start'],
      before  => Anchor['teamcity::agent::end'],
    } 
  }

  anchor { 'teamcity::agent::end': }
}
