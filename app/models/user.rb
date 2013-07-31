# == Schema Information
#
# Table name: users
#
#  id              :integer          not null, primary key
#  name            :string(255)
#  last_name       :string(255)
#  email           :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  password_digest :string(255)
#  remember_token  :string(255)
#  super_admin     :boolean
#  directory_path  :string(255)
#

#ATTENTION: In the model only the password_digest is saved. Password and password_confirmation are virtual attributes;
#Their use is for validations before saving the digest on persistent storage.

class User < ActiveRecord::Base
	attr_accessible :email, #For login purposes
   				        :last_name, :name, #Self explanatory 
   				        :password, :password_confirmation #Virtual
   		     		    :super_admin #True if he is; false otherwise.
                  :directory_path

    #Downcase the email so we can check uniqueness without worrying 
    #about case sensitive validations
    has_secure_password #Adds methods to set and authenticate against a BCrypt password. This mechanism requires you to have a password_digest attribute.
   	before_save { |user| user.email = email.downcase }
   	before_save :create_remember_token
    before_save :create_directory

	  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

   	validates :name, :presence => true,
                     :length => { :maximum => 50 }
   	validates :email, :presence => true,
                      :format => { :with => VALID_EMAIL_REGEX},
                      :uniqueness => { :case_sensitive => :false }
    validates :password, :presence => true, 
    					 :length => { :minimum => 6 }
    validates :password_confirmation, :presence => true

    has_many :flows, :dependent => :destroy, #If the user is destroyed, all his flows are gone too.
                     :order => 'updated_at'
    has_many :nodes, :dependent => :destroy,
                     :order => 'hostname'

  	private
  		def create_remember_token
  			self.remember_token = SecureRandom.urlsafe_base64
  		end

      def create_directory
        #self.directory_path = "C:\\Users\\Jxx706\\Documents\\GitHub\\BM-CM\\users_files\\#{self.email}"
        self.directory_path = "C:\\Users\\jesus\\Desktop\\Pasantia\\Proyecto\\bancaplus-postventa\\BM-CM\\users_files\\#{self.email}"

        #The user's directory is created if isn't existed before.
        unless Dir.exists?(self.directory_path) then
          Dir.mkdir(self.directory_path)
        end
      end
end
