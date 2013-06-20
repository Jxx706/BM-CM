!/bin/
NODES=""
echo "Se probaran las direcciones IP proveidas. Espere..."
sleep 2
for i in $NODES
do
	if [[`ping -q -c 2 $i`]]
	then
		echo "Conexion exitosa con el nodo."
	else
		echo "No se ha podido establecer conexion con el nodo. El programa abortara."
	fi
done
echo "Privilegios de root requeridos. Introduzca contrasena: "
su
echo "Instalando el Puppet Master"
apt-get install puppetmaster#Instalar el Puppet Master

for n in $NODES
do
	echo "Iniciando conexion SSH con el nodo. Ingrese su contrasena de ROOT!"
	ssh -l root $n "apt-get install puppet"
done
echo "Se firmaran los siguientes certificados: "
puppet cert list #Muestra las peticiones de firma de certificados de los nodos donde fue instalado Puppet.
sleep 3 #Tiempo suficiente para que puedas leer la lista.
puppet cert sign --all #Firma todos los certificados.