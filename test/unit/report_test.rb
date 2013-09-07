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
#  body       :string(255)
#

require 'test_helper'

class ReportTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
