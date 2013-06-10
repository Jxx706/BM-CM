module FlowsHelper

	#Given a hash filled with the attributes of the resource and 
	#the resource name, it generates a well defined resource with 
	#the proper syntax corresponding to the Puppet DDL.t.
	#Example:
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
		classes.each do |c| 
			node += "\n\tinclude #{c}"
		end
		node += "}"
	end

	#Pending...
	#def write_class
	#end
end
