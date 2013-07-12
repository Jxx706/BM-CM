module FlowsHelper
	FIELDS = {
		"mysql" => { "port" => "puerto",
					 "basedir" => "directorio base",
					 "datadir" => "directorio de datos",
					 "type" => "tipo de flujo",
					 "tool" => "herramienta",
					 "client" => "cliente",
					 "tmpdir" => "directorio de temporales",
					 "package_ensure" => "version",
					 "max_allowed_packet" => "tamanio maximo de paquete",
					 "bind_address" => "direccion de vinculacion",
					 "root_group" => "grupo de usuario root",
					 "root_password" => "contrasenia de usuario root"
			  },
		"couchbase" => { "user" => "usuario",
						 "password" => "contrasenia",
						 "version" => "version",
						 "size" => "tamanio",
						 "type" => "tipo de flujo",
					 	 "tool" => "herramienta"
			 		   },
		"tomcat" => {}
	}

	def field_translation(tool, field_name)
		FIELDS[tool][field_name]
	end
end
