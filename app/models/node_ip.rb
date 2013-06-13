#This class is only useful when creating an installer.
#I'm aware that it is not a good solution, but it makes a lot
#easier to generate a dynamic form.

#This wouldn't be necessary if these objects were present in the DB.

class NodeIp < TablelessModel

	column :ip_address, :string
	column :installer_type, :string
	column :installer_id, :string

	#############################

	belongs_to :installer
end
