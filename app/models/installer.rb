# == Schema Information
#
# Table name: tableless_models
#
#  ip_addresses :text
#  shell        :string
#

class Installer < TablelessModel

	column :shell, :string #Type of shell needed by the user. 

	####################### END OF TABLELESS CHEAT COLUMNS DEFINITION ###################
	has_many :node_ip
	accepts_nested_attributes_for :node_ip, :allow_destroy => true
end
