# == Schema Information
#
# Table name: users
#
#  id           :integer          not null, primary key
#  name         :string(255)
#  last_name    :string(255)
#  email        :string(255)
#  password     :string(255)
#  super_admin? :boolean
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
