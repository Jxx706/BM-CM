class Flow < ActiveRecord::Base
  attr_accessible :file_path, :name

  #A path is ok when the file addressed by it exists.
  def path_ok?
  	File.exists?(self.file_path)
  end
end
