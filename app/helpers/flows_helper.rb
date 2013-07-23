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

	# EXPLANATION_MESSAGES = {
	# 	1 => "Estos datos contendran los datos basicos del flujo: Nombre y nodo. Todo flujo debe tener un identificador unico y ha de pertenecer a uno o varios nodos.",
	# 	2 => "Los flujos de instalacion, tal como lo indica su denominacion, sirven para instalar (de manera personalizada) herramientas de deasrrollo en los nodos.",
	# 	3 => "En esta seccion debes proveer la informacion ",
	# 	4 => "",
	# 	5 => "",
	# 	6 => ""
	# }

	# HELP_MESSAGES = {
	# 	1 => "",
	# 	2 => "",
	# 	3 => "",
	# 	4 => "",
	# 	5 => "",
	# 	6 => ""
	# }

	def field_translation(tool, field_name)
		FIELDS[tool][field_name]
	end

	# def form_help(form_number)
	# 	HELP_MESSAGES[form_number]
	# end

	# def form_explanation(form_number)
	# 	EXPLANATION_MESSAGES[form_number]
	# end
end
