# == Schema Information
#
# Table name: reports
#
#  id         :integer          not null, primary key
#  file_path  :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  node_id    :integer
#

class Report < ActiveRecord::Base
  attr_accessible :file_path

  belongs_to :node 
end
