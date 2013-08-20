# == Schema Information
#
# Table name: nodes
#
#  id             :integer          not null, primary key
#  ip             :string(255)
#  hostname       :string(255)
#  domain         :string(255)
#  fqdn           :string(255)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  user_id        :integer
#  directory_path :string(255)
#

class Node < ActiveRecord::Base
  attr_accessible :domain, :fqdn, :hostname, :ip
  before_save :create_fqdn

  VALID_IP_ADDRESS = /^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$/
  validates :hostname, :presence => { :message => "El hostname es obligatorio."}
  validates :ip, :presence => { :message => "La direccion IP es obligatoria." },
  		    	 :format   => { :with => VALID_IP_ADDRESS, :message => "Direccion IP no cumple formato valido." }
  has_many :reports, :dependent => :destroy,
  					 :order => 'created_at'
  belongs_to :user
  has_many :configurations
  has_many :flows, :through => :configurations
  has_many :reports

  private
  	def create_fqdn
  		self.fqdn = "#{self.hostname}.#{self.domain}" unless self.domain.nil? || self.domain.blank?
  	end

    def create_directory
      self.directory_path = "C:\\Users\\Jxx706\\Documents\\GitHub\\BM-CM\\node_reports\\#{self.fqdn}"
      #self.directory_path = "C:\\Users\\jesus\\Desktop\\Pasantia\\Proyecto\\bancaplus-postventa\\BM-CM\\nodes_reports\\#{self.fqdn}"

      #The node's directory is created if isn't existed before.
      unless Dir.exists?(self.directory_path) then
        Dir.mkdir(self.directory_path)
      end
    end
end
