# Configures the teamcity database
class teamcity::db(
  $manage_repos = true,
  $username     = 'teamcity_server',
  $password     = 'CHANGEME',
  $host         = 'localhost',
  $port         = 5432,
  $db_name      = 'teamcity_server'
){
  $db_file = "${teamcity::data_dir}/config/database.properties"

  case $teamcity::db_type {
    # also see https://github.com/foxsoft/puppet-postgresql/blob/master/manifests/classes/postgresql-centos-v9-0.pp
    'postgresql': {
      if $manage_repos {
        # pgsql 9.3 is current RDS version
        yumrepo { 'pgdg93':
          baseurl  => 'http://yum.postgresql.org/9.3/redhat/rhel-$releasever-$basearch',
          descr    => 'PostgreSQL 9.3 $releasever - $basearch',
          enabled  => 1,
          gpgcheck => 0,
          tag      => 'prereq',
        }
      }
      # https://wiki.postgresql.org/wiki/YUM_Installation
      package { 'postgresql93':
        ensure => present,
      }

      # see http://confluence.jetbrains.com/display/TCD8/Setting+up+an+External+Database#SettingupanExternalDatabase-SelectingExternalDatabaseEngine
      $jdbc_out = "${teamcity::data_dir}/lib/jdbc/postgresql-9.3-1101.jdbc41.jar"
      exec { 'download-jdbc41':
        command => "curl http://jdbc.postgresql.org/download/postgresql-9.3-1101.jdbc41.jar --output ${jdbc_out}",
        creates => $jdbc_out,
      }

      # configure TC to use the database
      file { $db_file:
        ensure  => present,
        owner   => $teamcity::user,
        group   => $teamcity::group,
        content => "
# This file is managed by puppet, do not change manually!
# PostgreSQL configured

connectionUrl=jdbc:postgresql://${host}:${port}/${db_name}
connectionProperties.user=${username}
connectionProperties.password=${password}
maxConnections=50
testOnBorrow=false
",
      }
    } # end of postgresql case

    # add support for more DBs here

    'hsqldb', default: {}
  }
}
