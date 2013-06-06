module FlowsHelper

	#Conjunto de funciones encargadas de traducir un grupo de parámetros de un tipo
	#de recurso dado, en la sintaxis propia del DDL de Puppet.


	#Dado el título y hash con los atributos de un recurso, 
	#genera un recurso con la sintaxis del DSL de Puppet.
	#Ejemplo:
	# package{ 'mysql':
	#    ensure => installed,
	# }
	def write_resource(resource_name, title, attributes = {})
		resource = "#{resource_name} {'#{title}':" 
		attributes.each do |key, value|
			resource += "\n\t#{key} => #{value},"
		end
		resource += "}"
	end

	def write_node(node_name, classes = [])
		node = "node '#{node_name}' {"
		classes.each do |class| 
			node += "\n\tinclude #{class}"
		end
		node += "}"
	end

	#Pending...
	#def write_class
	#end
end
