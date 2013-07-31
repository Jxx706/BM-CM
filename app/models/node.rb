# == Schema Information
#
# Table name: nodes
#
#  id         :integer          not null, primary key
#  ip         :string(255)
#  hostname   :string(255)
#  domain     :string(255)
#  fqdn       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :integer
#

class Node < ActiveRecord::Base
  attr_accessible :domain, :fqdn, :hostname, :ip
  before_save :create_fqdn

  VALID_IP_ADDRESS = //
  validates :hostname, :presence => true
  validates :ip, :presence => true,
  		    	 :format   => { :with => VALID_IP_ADDRESS }
  has_many :reports, :dependent => :destroy,
  					 :order => 'created_at'
  belongs_to :user
  has_many :configurations
  has_many :flows, :through => :configurations

  private
  	def create_fqdn
  		self.fqdn = "#{self.hostname}.#{self.domain}"
  	end
end
