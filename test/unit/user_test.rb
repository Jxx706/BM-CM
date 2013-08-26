# == Schema Information
#
# Table name: users
#
#  id                  :integer          not null, primary key
#  name                :string(255)
#  last_name           :string(255)
#  email               :string(255)
#  super_admin         :boolean
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  password_digest     :string(255)
#  remember_token      :string(255)
#  directory_path      :string(255)
#  marked_as_deletable :boolean
#

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
