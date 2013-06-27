class InstallersController < ApplicationController

  #Generates installer file.
  def create
  	ips = []
  	shell = ""

  	params[:installer].each do |k, v|
  		case k
  		when "shell"
  			shell = v
  		else
  			ips.push(v)
  		end
  	end

  	user = User.find_by_email(params[:user_email])
  	installer_name = user.directory_path << "\\installer.sh"
  	file = File.new(installer_name, "w+")
  	file.write(write_installer(ips, shell))
  	file.close

  end

  def download
  	#send_file(current_user.directory_path << "\\installer.sh")
  end


  private
  	#Given a L sized array filled with 
	#IP addresses associated with a group 
	#of nodes of a production enviroment,
	#it writes the shell script Puppet installer
	#contents.
	def write_installer(ip_addresses, shell = "bash")
		file_content = "!/bin/#{shell}" #Shell type.

	

		#STORING IP ADDRESSES IN DIFFERENT VARIABLES.
		file_content += nl + "NODES=\""
		
		ip_addresses.each do |ip| 
			file_content += "#{ip} "
		end

		file_content += "\""

	    #ARE THE GIVEN ADDRESSES REACHABLE?
		file_content += nl + echo("Se probaran las direcciones IP proveidas. Espere...")
		file_content += nl + "sleep 2"
		file_content += nl + "for i in $NODES"
		file_content += nl + "do"
		file_content += nl + tab + "if [[`ping -q -c 2 $i`]]"
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
		file_content += nl

		#STABLISHING SSH CONNECTIONS WITH EVERY NODE AND ATTEMPTING TO INSTALL PUPPET ON THEM.		
		file_content += nl + "for n in $NODES" 
		file_content += nl + "do"
		file_content += nl + tab + echo("Iniciando conexion SSH con el nodo. Ingrese su contrasena de ROOT!")
		file_content += nl + tab + "ssh -l root $n \"apt-get install puppet\"" 
		file_content += nl + "done"

		#SIGNING THE CERTIFICATES 
		file_content += nl + echo("Se firmaran los siguientes certificados: ")
		file_content += nl + "puppet cert list " + comment("Muestra las peticiones de firma de certificados de los nodos donde fue instalado Puppet.")
	    file_content += nl + "sleep 3 " + comment("Tiempo suficiente para que puedas leer la lista.")
		file_content += nl + "puppet cert sign --all " + comment("Firma todos los certificados.")

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