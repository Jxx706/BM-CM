# == Schema Information
#
# Table name: flows
#
#  id              :integer          not null, primary key
#  name            :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  user_id         :integer
#  hash_attributes :text
#  body            :string(255)
#

require 'test_helper'

class FlowTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
