node 'jesus.master.com' {

couchbase::bucket {"couchbase":
	type => memcached,}

tomcat::instance {"instancia":
	ensure => present,
	sample => true,}


}
