module FlowsHelper
	FIELDS = {
		"port" => "puerto",
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
	}

	def field_translation(field_name)
		FIELDS[field_name]
	end
end
