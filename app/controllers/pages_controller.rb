class PagesController < ApplicationController
  
  #Home page controller
  def home
  	@title = "Home" #Page title
  end

  #Pre-conditions and diverse information page controller
  def get_started
  	@title= "Antes de empezar..." #Page title
  end

  #
  def custom_installer
  	@title = "Personalizar instalador"
  	@ip_addresses = [] #Contenedor de direcciones IP
  	@shell = nil
  end

  def generate_file
  	if @shell.nil?
  		write_installer(@ip_addresses)
  	else
  		write_installer(@ip_addresses, @shell)
  	end
  end

end
