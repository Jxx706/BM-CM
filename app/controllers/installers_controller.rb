class InstallersController < ApplicationController

  
  skip_before_filter :verify_authenticity_token, :only => [:create]
 
  #Generates installer file.
  def create
  	ips = current_user.nodes.map { |n| n.ip if n.fqdn != params[:master_node] }
  	shell = params[:shell]

  	installer_name = current_user.directory_path << "\\installer.sh"
  	file = File.new(installer_name, "w+")
  	@installer_content = write_installer(ips, shell)
  	file.write(@installer_content)
  	file.close

  end

  def download
  	send_file(current_user.directory_path << "\\installer.sh")
  end

  def destroy
  	File.delete(current_user.directory_path << "\\installer.sh")
  	redirect_to root_path
  end


  private
  	#Given a L sized array filled with 
	#IP addresses associated with a group 
	#of nodes of a production enviroment,
	#it writes the shell script Puppet installer
	#contents.
	def write_installer(ip_addresses, shell = "bash")
		file_content = "#!/bin/#{shell}" #Shell type.

	

		#STORING IP ADDRESSES IN DIFFERENT VARIABLES.
		file_content += nl + "NODES=\""
		
		ip_addresses.each do |ip| 
			file_content += "#{ip} "
		end

		file_content += "\""

	    #ARE THE GIVEN ADDRESSES REACHABLE?
		file_content += nl + echo("Se probaran las direcciones IP proveidas. Espere...")
		file_content += nl + "sleep 2"
		file_content += nl + "for i in $NODES;"
		file_content += nl + "do"
		file_content += nl + tab + "if [[`ping -q -c 2 $i`]];"
	    file_content += nl + tab + "then"
		file_content += nl + (tab * 2) + echo("Conexion exitosa con el nodo.")
		file_content += nl + tab + "else"
		file_content += nl + (tab * 2) + echo("No se ha podido establecer conexion con el nodo. El programa abortara.")
		file_content += nl + tab + "fi"
		file_content += nl + "done"


		file_content += nl + echo("Privilegios de root requeridos. Introduzca contrasena: ")
		file_content += nl + "su"

		#INSTALLING THE PUPPET MASTER
		file_content += nl + echo("Instalando el Puppet Master")
		file_content += nl + "apt-get install puppetmaster " + comment("Instalar el Puppet Master") 
		file_content += nl + "puppet master --reports=http" + comment("Los reportes se enviaran remotamente a BM+CM")
		file_content += nl + "puppet master --reporturl=ALGO"
		file_content += nl

		#STABLISHING SSH CONNECTIONS WITH EVERY NODE AND ATTEMPTING TO INSTALL PUPPET ON THEM.
		#ENABLING THE REPORTS AS WELL.		
		file_content += nl + "for n in $NODES;" 
		file_content += nl + "do"
		file_content += nl + tab + echo("Iniciando conexion SSH con el nodo. Ingrese su contrasena de ROOT!")
		file_content += nl + tab + "ssh -l root $n \"apt-get install puppet\"" 
		file_content += nl + tab + "puppet agent --reports"

		file_content += nl + "done"

		#SIGNING THE CERTIFICATES 
		file_content += nl + echo("Se firmaran los siguientes certificados: ")
		file_content += nl + "puppet cert list " + comment("Muestra las peticiones de firma de certificados de los nodos donde fue instalado Puppet.")
	    file_content += nl + "sleep 3 " + comment("Tiempo suficiente para que puedas leer la lista.")
		file_content += nl + "puppet cert sign --all " + comment("Firma todos los certificados.")

		#INSTALLING DEPENDENCIES
		file_content += (nl * 2) + echo("Se instalaran las dependencias...")
		file_content += nl + "puppet module puppetlabs-mysql" #For handle MySQL
		file_content += nl + "puppet module jlondon-couchbase" #For handle Couchbase
		file_content += nl + "puppet module camptocamp-tomcat" #For handle Tomcat
		file_content += nl + "puppet module puppetlabs-stdlib" #For handle file edition

		return file_content
	end

	def echo(message)
		"echo \"#{message}\""
	end

	def comment(text)
		text.prepend('#')
	end

	def nl
		"\n"
	end

	def tab
		"\t"
	end

end