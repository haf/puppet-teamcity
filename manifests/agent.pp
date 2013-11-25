class teamcity::agent(
  $user        = 'teamcity-agent',
  $server_url  = 'http://tc',
  $name        = $hostname,
  $own_port    = 9090,
  $own_address = 'localhost',
  $home        = '/opt/teamcity-agent',
  $work_dir    = '/opt/teamcity-agent/work',
  $temp_dir    = '/opt/teamcity-agent/temp',
  $system_dir  = '/opt/teamcity-agent/system',
  $properties  = {}
) {
  $service = 'teamcity-agent'

  anchor { 'teamcity::agent::start': }

  include teamcity::common
  include teamcity::agent::install

  user { $user:
    ensure => present,
    system => true,
    home   => $home,
    gid    => $teamcity::common::group,
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
      Class['teamcity::agent::install'],
      User[$user]
    ],
    before  => Anchor['teamcity::agent::end'],
  }

  file { "$home/bin/agent.sh":
    mode    => '0755',
    require => [
      Anchor['teamcity::agent::start'],
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
    hasstatus  => true,
    hasrestart => true,
    require    => [
      Anchor['teamcity::agent::start'],
      Class['teamcity::common'],
      File["/etc/init.d/$service"]
    ],
    before     => Anchor['teamcity::agent::end'],
  }

  anchor { 'teamcity::agent::start': }
}