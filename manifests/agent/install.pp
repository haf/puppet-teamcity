class teamcity::agent::install {
  include wget

  wget::fetch { 'download':
    source      => "$teamcity::agent::server_url/update/buildAgent.zip",
    destination => "/tmp/buildAgent.zip",
    timeout     => 0,
    verbose     => false,
  }

  exec { 'unzip':
    command => "/usr/bin/unzip buildAgent.zip -d ${teamcity::agent::home}",
    cwd     => '/tmp',
    creates => $teamcity::agent::home,
    require => [
      User[$teamcity::agent::user],
      Wget::Fetch['download']
    ],
    user    => 'root',
  }

  file { $teamcity::agent::home:
    ensure  => directory,
    owner   => $teamcity::agent::user,
    group   => $teamcity::common::group,
    mode    => '0644',
    replace => false,
    require => Exec['unzip'],
  }
}