class User < ActiveRecord::Base
  attr_accessible :email, #For login purposes
   				  :last_name, :name, :password, #Self explanatory 
   				  :super_admin? #True if he is; false otherwise.
end
