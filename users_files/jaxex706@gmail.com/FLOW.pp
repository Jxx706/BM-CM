class {'mysql::server':
	package_ensure => 5.6,
	config_hash => {"port"=>"3306", "root_group"=>"", "root_password"=>"UNSET", "bind_address"=>"127.0.0.1", "max_allowed_packet"=>"16M", "basedir"=>"/usr", "datadir"=>"/var/lib/mysql", "tmpdir"=>"/tmp"},}
