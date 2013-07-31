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

require 'test_helper'

class ConfigurationTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
