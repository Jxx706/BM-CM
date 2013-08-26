node 'champagne.pug.net' {

mysql::db {'mysql':
	user => usuario,
	password => 1234567,
	grant => ["all"],}


}
