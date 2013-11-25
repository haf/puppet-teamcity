class teamcity::common(
  $group = 'teamcity'
) {
  anchor { 'teamcity::common::start': }

  group { $group:
    ensure => present,
    system => true,
    require => Anchor['teamcity::common::start'],
    before  => Anchor['teamcity::common::end'],
  }

  anchor { 'teamcity::common::end': }
}