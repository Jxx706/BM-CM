# == Schema Information
#
# Table name: nodes
#
#  id             :integer          not null, primary key
#  ip             :string(255)
#  hostname       :string(255)
#  domain         :string(255)
#  fqdn           :string(255)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  user_id        :integer
#  directory_path :string(255)
#

require 'test_helper'

class NodeTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
