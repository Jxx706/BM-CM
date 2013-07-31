# == Schema Information
#
# Table name: configurations
#
#  id         :integer          not null, primary key
#  node_id    :integer
#  flow_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Configuration < ActiveRecord::Base
  belongs_to :flow
  belongs_to :node
end
