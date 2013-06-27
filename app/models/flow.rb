# == Schema Information
#
# Table name: flows
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  file_path  :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  node_name  :string(255)
#

class Flow < ActiveRecord::Base

  	attr_accessible :file_path, #Path where the flow is stored
  					:name, #Name of this flow
  					:node_name #Name of the node that owns this flow
  					:parameters #Hash of attributes
  	belongs_to :user
  	before_save :path_ok?
  	
  	#A path is ok when the file addressed by it exists.
  	private
  		def path_ok?
  			File.exists?(self.file_path)
  		end
end
