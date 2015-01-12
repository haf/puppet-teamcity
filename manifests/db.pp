 # Configures the teamcity database
class teamcity::db(
  $manage_repos = true,
  $username     = 'teamcity_server',
  $password     = 'CHANGEME',
  $host         = 'localhost',
  $port         = 5432,
  $db_name      = 'teamcity_server'
){
  $db_file = "${teamcity::server::data_dir}/config/database.properties"

  case $teamcity::server::db_type {
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
      $jdbc_out = "${teamcity::server::data_dir}/lib/jdbc/postgresql-9.3-1101.jdbc41.jar"
      exec { 'download-jdbc41':
        command => "curl http://jdbc.postgresql.org/download/postgresql-9.3-1101.jdbc41.jar --output ${jdbc_out}",
        creates => $jdbc_out,
      }

      # configure TC to use the database
      file { $db_file:
        ensure  => present,
        owner   => $teamcity::server::user,
        group   => $teamcity::common::group,
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
    # also see https://http://dev.mysql.com/doc/mysql-repo-excerpt/5.6/en/linux-installation-yum-repo.html
    'mysql': {
      if $manage_repos {
        # mysql 5.6 is current RDS version
        yumrepo { 'mysql56':
          baseurl  => 'http://mysql-community-release-el$releasever.noarch.rpm',
          descr    => 'MySQL 5.6 $releasever',
          enabled  => 1,
          gpgcheck => 0,
          tag      => 'prereq',
        }
      }
      # yum repo for mysql client
      package { 'mysql':
        ensure => present,
      }

      # see http://confluence.jetbrains.com/display/TCD8/Setting+up+an+External+Database#SettingupanExternalDatabase-SelectingExternalDatabaseEngine
      $mysql_connector = 'mysql-connector-java-5.1.33'
      exec { "download-${mysql_connector}":
        command => "curl http://ftp.jaist.ac.jp/pub/mysql/Downloads/Connector-J/${mysql_connector}.tar.gz | tar -xvz   ${mysql_connector}/${mysql_connector}-bin.jar",
        cwd     => '/tmp',
        creates => "/tmp/${mysql_connector}/${mysql_connector}-bin.jar",
      }

      $jdbc_out = "${teamcity::server::data_dir}/lib/jdbc/${mysql_connector}-bin.jar"
      file { $jdbc_out:
        ensure  => present,
        owner   => $teamcity::server::user,
        group   => $teamcity::common::group,
        source  => "/tmp/${mysql_connector}/${mysql_connector}-bin.jar" ,
        require => Exec["download-${mysql_connector}"]
      }  

      # configure TC to use the database
      file { $db_file:
        ensure  => present,
        owner   => $teamcity::server::user,
        group   => $teamcity::common::group,
        content => "
# This file is managed by puppet, do not change manually!
# MySQL configured

connectionUrl=jdbc:mysql://${host}:${port}/${db_name}
connectionProperties.user=${username}
connectionProperties.password=${password}
maxConnections=50
testOnBorrow=false
",
      }
    } # end of mysql case

    

    # add support for more DBs here

    'hsqldb', default: {}
  }
}
