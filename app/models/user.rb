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

class User < ActiveRecord::Base
  attr_accessible :email, #For login purposes
   				  :last_name, :name, :password, #Self explanatory 
   				  :super_admin? #True if he is; false otherwise.

  has_many :flows, :dependent => :destroy #If the user is destroyed, all his flows are gone too.
end
