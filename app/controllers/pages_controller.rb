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
  	@ip_addresses = [] #IP addresses container.
  	@shell = nil #User's shell type.
  	@submitted = false #Used for dynamic content.
  end

  def generate_file
  	@submitted = true 
  	if @shell.nil?
  		write_installer(@ip_addresses)
  	else
  		write_installer(@ip_addresses, @shell)
  	end

  	#redirect_to ????
  end

end
