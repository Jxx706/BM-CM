class InstallerController < ApplicationController
 

  def new
  	@title = "Nuevo Instalador"
  	@installer = Installer.new
  	@installer.node_ips.build
  end

  #Generates installer file.
  def create
  	@installer = Installer.new(params[:installer])

  	if params[:add_node]
  		@installer.node_ips.build
  	elsif params[:remove_node]
  	end

  	render :action => 'new'
  			
  end

  def update
  	@installer = Installer.find(params[:id])

  	if params[:add_node]
  		unless params[:installer][:node_ips_attributes].blank?
  			for att in params[:installer][:node_ips_attributes]
  				@installer.node_ips.build(att.last.except(:_destroy)) unless att.last.has_key?(:id)
  			end
  		end

  		@installer.node_ips.build
  	elsif params[:remove_node]
  		for att in params[:installer][:node_ips_attributes]
  			@installer.node_ips.build(att.last.except(:_destroy)) if (!att.last.has_key?(:id) && att.last[:_destroy].to_i == 0)
  		end
  	end
  end

  private

end
