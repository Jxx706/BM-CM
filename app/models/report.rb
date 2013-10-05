# == Schema Information
#
# Table name: reports
#
#  id         :integer          not null, primary key
#  file_path  :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  node_id    :integer
#  name       :string(255)
#  body       :text
#

class Report < ActiveRecord::Base
	attr_accessible :file_path, :name, :body #This is what gets saved on the record
	serialize :body, Hash
	belongs_to :node
end
