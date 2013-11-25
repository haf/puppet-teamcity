class teamcity::agent(
  $user           = 'teamcity-agent',
  $server_url     = 'http://tc:8111',
  $agent_name     = $hostname,
  $own_port       = 9090,
  $own_address    = $hostname,
  $home           = '/opt/teamcity-agent',
  $work_dir       = '/opt/teamcity-agent/work',
  $temp_dir       = '/opt/teamcity-agent/temp',
  $system_dir     = '/opt/teamcity-agent/system',
  $agent_opts     = '',
  $agent_mem_opts = '-Xmx384m',
  $properties  = {}
) {
  $service = 'teamcity-agent'
  $bin_dir = "$home/bin"

  anchor { 'teamcity::agent::start': }

  include teamcity::common
  include teamcity::agent::install

  user { $user:
    ensure  => present,
    system  => true,
    home    => $home,
    gid     => $teamcity::common::group,
    require => Anchor['teamcity::agent::start'],
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
      File[$home],
      Class['teamcity::agent::install'],
      User[$user]
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
    hasstatus  => false,
    status     => 'ps aux | grep /usr/bin/java | grep agent.AgentMain',
    hasrestart => true,
    require    => [
      Anchor['teamcity::agent::start'],
      Class['teamcity::common'],
      File["$home/bin/agent.sh"],
      File["/etc/init.d/$service"]
    ],
    before     => Anchor['teamcity::agent::end'],
  }

  firewall { "101 allow agent-connections:9090":
    proto   => 'tcp',
    state   => ['NEW'],
    dport   => 9090,
    action  => 'accept',
    require => Anchor['teamcity::agent::start'],
    before  => Anchor['teamcity::agent::end'],
  }

  anchor { 'teamcity::agent::end': }
}