# == Schema Information
#
# Table name: flows
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  file_path  :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Flow < ActiveRecord::Base
  attr_accessible :file_path, :name

  #A path is ok when the file addressed by it exists.
  def path_ok?
  	File.exists?(self.file_path)
  end
end
