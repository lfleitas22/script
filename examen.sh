#!/bin/bash
clear
echo "Introdueix Nom + El Primer Cognom:"
read nom
clear
VERSIO=$(lsb_release -d | grep "Description" | cut -d ' ' -f2-4)
DATA_IN=$(head -1 /var/log/installer/syslog | cut -c 1-12)
DATA_FI=$(tail -1 /var/log/installer/syslog | cut -c 1-12)
RAM=$(vmstat -s -S M | grep "total memory" | cut -c 1-16)
HDD=$(df -h -t ext4 | awk ‘{pront $2}’ | sort -k 2 | head -1)
echo "[*] Nom Alumne: ${nom}"
echo "[*] La versió de Linux és: $VERSIO"
echo "[*] Inici de la instal·lació: $DATA_IN";
echo "[*] Final de la instal·lació: $DATA_FI";
echo "[*] Característiques (RAM / HDD): $RAM / $HDD"
echo
echo "+---------------------------------------------+"

# Apartat a)
# Configuració XARXA NAT
# IP XARXA NAT: 192.168.1.0/24
# Màscara 255.255.255.0
# Renviament de ports : 127.0.0.1 , 8888, 192.168.1.250 , 80
# Adaptador Xarxa NAT
# Modificar l'arxiu:
# nano /etc/network/interfaces
# iface enp0s3 inet static
#       address 192.168.1.250/24
#       gateway 192.168.1.1
# nano /etc/resolv.conf
# #nameserver 192.168.1.1

# Colors 
# Apartat f) g) h)

Purple='\033[0;35m'

Cyan='\033[0;36m'

Yellow='\033[0;32m'

Normal='\033[0;0m'

#Comprovacio usuari root
echo -e " ______ _      _____ _____"
echo -e "/ _____| |    |  __ \_   _|"
echo -e "| | ___| |    | |__) || | "
echo -e "| | |_ | |    |  ___/ | |  "
echo -e "| |__| | |____| |    _| |_ "
echo -e "\______|______|_|   |_____|"
echo -e "\n\n"
#Crear fitxer log
mkdir /var/ 2>/dev/null
mkdir /var/logs/ 2>/dev/null
mkdir /var/logs/registres/ 2>/dev/null
mkdir /var/logs/registres/install/ 2>/dev/null

echo -e "${Purple}Comprovacions preliminars\n${Normal}"
if [ $(whoami) == "root" ]; then
	echo -e "${Cyan}Ets root, seguirem amb l'instalacio${Normal}"
# Apartat b)
	echo "Ets root, seguirem amb l'instalacio" >> /var/logs/registres/install/glpi.log
else
	echo -e "${Yellow}No ets root, resgistret com usuari root i torna a executar el script${Normal}"
# Apartat c)
  echo "No ets root, resgistret com usuari root i torna a executar el script" >> /var/logs/registres/install/errors.log
	exit
fi

cat /etc/network/interfaces

#Comprovacio conexio a internet
apt-get update >/dev/null 2>&1

if [ $? -eq 0 ]; then

	echo -e "${Cyan}Conexio a internet comprobada"
	echo "Conexio a internet comprobada" >>/script/registre.txt
else

	echo -e "${Yellow}No tens conexio a internet, conectat i torna a executar el script"

fi

echo -e "\n\n${Purple}Instalació LAMP\n"
#Instal.lacio apache2
if [ $(dpkg-query -W -f='${Status}' 'apache2' >/dev/null 2>&1 | grep -c "ok installed") -eq 0 ]; then

	echo -e "${Purple}Apache2 no esta instal.lat, procedim amb la descarga"
	apt-get -y install apache2 >/dev/null 2>&1

	if [ $? -eq 0 ]; then

		echo -e "${Cyan}Apache2 instal.at correctament\n"
		echo "Apache2 instal.at correctament" >> /var/logs/registres/install/glpi.log
	else

		echo -e "${Yellow}Apache2 instal.lat incorrectament\n"
		exit
	fi

else

	echo -e "${Green}Apache2 ja esta instal.lat, continuem\n"

fi

#Instal.lacio mariadb-server
if [ $(dpkg-query -W -f='${Status}' 'software-properties-common' >/dev/null 2>&1 | grep -c "ok installed") >/dev/null 2>&1 -eq 0 ]; then

	echo -e "${Purple}Software-properties-common no esta instal.lat, procedim amb la descarga"
	apt-get -y install software-properties-common >/dev/null 2>&1

	if [ $? -eq 0 ]; then

		echo -e "${Cyan}Software-properties-common instal.at correctament\n"
		echo "Software-properties-common instal.at correctament" >>/var/logs/registres/install/glpi.log
	else

		echo -e "${Yellow}Software-properties-common instal.lat incorrectament"
		exit
	fi

else

	echo -e "${Purple}Software-propertes-common ja esta instal.lat, continuem\n"

fi

if [ $(dpkg-query -W -f='${Status}' 'dirmngr' >/dev/null 2>&1 | grep -c "ok installed") >/dev/null 2>&1 -eq 0 ]; then

	echo -e "${Yellow}Dirmngr no esta instal.lat, procedim amb la descarga"
	apt-get -y install dirmngr >/dev/null 2>&1

	if [ $? -eq 0 ]; then

		echo -e "${Green}Dirmngr instal.at correctament\n"
		echo "Dirmngr instal.at correctament" >>/var/logs/registres/install/glpi.log
	else

		echo -e "${Red}Dirmngr instal.lat incorrectament"
		exit
	fi

else

	echo -e "${Green}Dirmngr ja esta instal.lat, continuem\n"

fi

apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 0xF1656F24C74CD1D8 >/dev/null 2>&1
if [ $? -eq 0 ]; then

	echo -e "${White}Treballant..."

else

	echo -e "${Red}Error recv-keys"
	exit
fi

add-apt-repository 'deb [arch=amd64] https://mirror.rackspace.com/mariadb/repo/10.4/debian buster main' >/dev/null 2>&1
if [ $? -eq 0 ]; then

	echo -e "Treballant...\n"

else

	echo -e "${Red}Error apt-repository"
	exit
fi
apt-get update >/dev/null 2>&1




if [ $(dpkg-query -W -f='${Status}' 'mariadb-server' >/dev/null 2>&1 | grep -c "ok installed") >/dev/null 2>&1 -eq 0 ]; then

	echo -e "${Yellow}Mariadb-server no esta instal.lat, procedim amb la descarga"
	apt-get -y install mariadb-server >/dev/null 2>&1

	if [ $? -eq 0 ]; then

		echo -e "${Green}Mariadb-server instal.at correctament\n"
		echo "Mariadb-server instal.at correctament" >>/var/logs/registres/install/glpi.log
	else

		echo -e "${Red}Mariadb-server instal.lat incorrectament"
		exit
	fi

else

	echo -e "${Green}Mariadb-server ja esta instal.lat, continuem\n"

fi




#Instal.lacio php
if [ $(dpkg-query -W -f='${Status}' 'php' >/dev/null 2>&1 | grep -c "ok installed") >/dev/null 2>&1 -eq 0 ]; then

	echo -e "${Yellow}PHP no esta instal.lat, procedim amb la descarga"
	apt-get -y install php >/dev/null 2>&1

	if [ $? -eq 0 ]; then

		echo -e "${Green}PHP instal.at correctament\n"
		echo "PHP instal.at correctament" >>/var/logs/registres/install/glpi.log
	else

		echo -e "${Red}PHP instal.lat incorrectament"
		exit
	fi

else

	echo -e "${Green}PHP ja esta instal.lat, continuem\n"

fi


#Instal.lacio php-mysql
if [ $(dpkg-query -W -f='${Status}' 'php-mysql' >/dev/null 2>&1 | grep -c "ok installed") >/dev/null 2>&1 -eq 0 ]; then

	echo -e "${Yellow}PHP-mysql no esta instal.lat, procedim amb la descarga"
	apt-get -y install php-mysql >/dev/null 2>&1

	if [ $? -eq 0 ]; then

		echo -e "${Green}PHP-mysql instal.at correctament\n"
		echo "PHP-mysql instal.at correctament" >>/var/logs/registres/install/glpi.log
	else

		echo -e "${Red}PHP-mysql instal.lat incorrectament"
		exit
	fi

else

	echo -e "${Green}PHP-mysql ja esta instal.lat, continuem\n"

fi
clear

cd /opt/

echo -e "${BBlue}Descarrega i descompresio GLPI\n"
#descarga i descompresio del paquet
wget https://github.com/glpi-project/glpi/releases/download/10.0.7/glpi-10.0.7.tgz >/dev/null 2>&1

if [ $? -eq 0 ]; then

	echo -e "${Green}GLPI descarregat correctament\n"
	echo "GLPI descarregat correctament" >>/var/logs/registres/install/glpi.log
else

	echo -e "${Red}Error al descarregar GLPI"
	exit
fi


echo -e "${White}Descomprimint paquet descarregat..."
tar zxvf glpi-10.0.7.tgz >/dev/null 2>&1
if [ $? -eq 0 ]; then

	echo -e "${Green}Descompresio correcta\n"
	echo "Descompresio correcta" >>/script//var/logs/registres/install/glpi.log
else

	echo -e "${Red}Error de descompresio"
	exit
fi


echo -e "${White}Eliminant fitxer a la carpeta html..."
rm -R /var/www/html/
if [ $? -eq 0 ]; then

	echo -e "${Green}Eliminacio correcte\n"
	echo "Eliminacio correcte" >>/var/logs/registres/install/glpi.log

	echo -e "${Red}Error al eliminar"
	exit
fi

echo -e "${White}Movent arxiu a la cartpeta html..."
mv  glpi /var/www/html/
if [ $? -eq 0 ]; then

	echo -e "${Green}Moviment correcta\n"
	echo "Moviment correcta" >>/var/logs/registres/install/glpi.log
else

	echo -e "${Red}Error al moure"
	exit
fi

chmod 755 -R /var/www/html/
chown -R www-data:www-data /var/www/

clear

echo -e "${BBlue}Instalació php7.4 i activació"
#Instalació paquets php7.4 i activació

if [ $(dpkg-query -W -f='${Status}' 'lsb-release' >/dev/null 2>&1 | grep -c "ok installed") >/dev/null 2>&1 -eq 0 ]; then

	echo -e "${Yellow}lsb-release no esta instal.lat, procedim amb la descarga"
	apt-get -y install lsb-release >/dev/null 2>&1

	if [ $? -eq 0 ]; then

		echo -e "${Green}lsb-release instal.at correctament\n"
		echo "lsb-release instal.at correctament" >>/var/logs/registres/install/glpi.log
	else

		echo -e "${Red}lsb-release instal.lat incorrectament"
		exit
	fi

else

	echo -e "${Green}lsb-release ja esta instal.lat, continuem\n"

fi


if [ $(dpkg-query -W -f='${Status}' 'apt-transport-https' >/dev/null 2>&1 | grep -c "ok installed") >/dev/null 2>&1 -eq 0 ]; then

	echo -e "${Yellow}apt-transport-https no esta instal.lat, procedim amb la descarga"
	apt-get -y install apt-transport-https >/dev/null 2>&1

	if [ $? -eq 0 ]; then

		echo -e "${Green}apt-transport-https instal.at correctament\n"
		echo "apt-transport-https instal.at correctament" >>/var/logs/registres/install/glpi.log
	else

		echo -e "${Red}apt-transport-https instal.lat incorrectament"
		exit
	fi

else

	echo -e "${Green}apt-transport-https ja esta instal.lat, continuem\n"

fi


if [ $(dpkg-query -W -f='${Status}' 'ca-certificates' >/dev/null 2>&1 | grep -c "ok installed") >/dev/null 2>&1 -eq 0 ]; then

	echo -e "${Yellow}ca-certificates no esta instal.lat, procedim amb la descarga"
	apt-get -y install ca-certificates >/dev/null 2>&1

	if [ $? -eq 0 ]; then

		echo -e "${Green}ca-certificates instal.at correctament\n"
		echo "ca-certificates instal.at correctament" >>/var/logs/registres/install/glpi.log
	else

		echo -e "${Red}ca-certificates instal.lat incorrectament"
		exit
	fi

else

	echo -e "${Green}ca-certificates ja esta instal.lat, continuem\n"

fi

wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg >/dev/null 2>&1
if [ $? -eq 0 ]; then

	echo -e "${White}Treballant..."

else

	echo -e "${Red}Error links php"
	exit
fi

echo -e "deb https://packages.sury.org/php/ $( lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list

if [ $? -eq 0 ]; then

	echo -e "${White}Treballant...\n"

else

	echo -e "${Red}Error links echo"
	exit
fi
apt-get update >/dev/null 2>&1

if [ $(dpkg-query -W -f='${Status}' 'php7.4' >/dev/null 2>&1 | grep -c "ok installed") >/dev/null 2>&1 -eq 0 ]; then

	echo -e "${Yellow}PHP7.4 no esta instal.lat, procedim amb la descarga"
	apt-get -y install php7.4 >/dev/null 2>&1

	if [ $? -eq 0 ]; then

		echo -e "${Green}PHP7.4 instal.at correctament\n"
		echo "PHP7.4 instal.at correctament" >>/var/logs/registres/install/glpi.log
	else

		echo -e "${Red}PHP7.4 instal.lat incorrectament"
		exit
	fi

else

	echo -e "${Green}PHP7.4 ja esta instal.lat, continuem\n"

fi

echo -e "${White}Activant php7.4..."

a2dismod php7.3 >/dev/null 2>&1
if [ $? -eq 0 ]; then

	echo -e "${Green}Desactiviacio php7.3 correcte\n"
	echo "Desactiviacio php7.3 correcte" >>/var/logs/registres/install/glpi.log
else

	echo  -e "${Red}Error al desactivar php7.3"
	exit
fi

a2enmod php7.4 >/dev/null 2>&1
if [ $? -eq 0 ]; then

	echo -e "${Green}Activació php7.4 correcte\n"
	echo "Activació php7.4 correcte" >>/var/logs/registres/install/glpi.log
else

	echo -e "${Red}Error al activar php7.4"
	exit
fi

#Intalació tots paquets secundaris
if [ $(dpkg-query -W -f='${Status}' 'php7.4-apcu' >/dev/null 2>&1 | grep -c "ok installed") >/dev/null 2>&1 -eq 0 ]; then

	echo -e "${Yellow}PHP7.4-apcu no esta instal.lat, procedim amb la descarga"
	apt-get -y install php7.4-apcu >/dev/null 2>&1

	if [ $? -eq 0 ]; then

		echo -e "${Green}PHP7.4-apcu instal.at correctament\n"
		echo "PHP7.4-apcu instal.at correctament" >>/var/logs/registres/install/glpi.log
	else

		echo -e "${Red}PHP7.4-apcu instal.lat incorrectament"
		exit
	fi

else

	echo -e "${Green}PHP7.4-apcu ja esta instal.lat, continuem\n"

fi

if [ $(dpkg-query -W -f='${Status}' 'php7.4-bz2' >/dev/null 2>&1 | grep -c "ok installed") >/dev/null 2>&1 -eq 0 ]; then

	echo -e "${Yellow}PHP7.4-bz2 no esta instal.lat, procedim amb la descarga"
	apt-get -y install php7.4-bz2 >/dev/null 2>&1

	if [ $? -eq 0 ]; then

		echo -e "${Green}PHP7.4-bz2 instal.at correctament\n"
		echo "PHP7.4-bz2 instal.at correctament" >>/var/logs/registres/install/glpi.log
	else

		echo -e "${Red}PHP7.4-bz2 instal.lat incorrectament"
		exit
	fi

else

	echo -e "${Green}PHP7.4-bz2 ja esta instal.lat, continuem\n"

fi

if [ $(dpkg-query -W -f='${Status}' 'php7.4-curl' >/dev/null 2>&1 | grep -c "ok installed") >/dev/null 2>&1 -eq 0 ]; then

	echo -e "${Yellow}PHP7.4-curl no esta instal.lat, procedim amb la descarga"
	apt-get -y install php7.4-curl >/dev/null 2>&1

	if [ $? -eq 0 ]; then

		echo -e "${Green}PHP7.4-curl instal.at correctament\n"
		echo "PHP7.4-curl instal.at correctament" >>/var/logs/registres/install/glpi.log
	else

		echo -e "${Red}PHP7.4-curl instal.lat incorrectament"
		exit
	fi

else

	echo -e "${Green}PHP7.4-curl ja esta instal.lat, continuem\n"

fi

if [ $(dpkg-query -W -f='${Status}' 'php7.4-gd' >/dev/null 2>&1 | grep -c "ok installed") >/dev/null 2>&1 -eq 0 ]; then

	echo -e "${Yellow}PHP7.4-gd no esta instal.lat, procedim amb la descarga"
	apt-get -y install php7.4-gd >/dev/null 2>&1

	if [ $? -eq 0 ]; then

		echo -e "${Green}PHP7.4-gd instal.at correctament\n"
		echo "PHP7.4-gd instal.at correctament" >>/var/logs/registres/install/glpi.log
	else

		echo -e "${Red}PHP7.4-gd instal.lat incorrectament"
		exit
	fi

else

	echo -e "${Green}PHP7.4-gd ja esta instal.lat, continuem\n"

fi

if [ $(dpkg-query -W -f='${Status}' 'php7.4-intl' >/dev/null 2>&1 | grep -c "ok installed") >/dev/null 2>&1 -eq 0 ]; then

	echo -e "${Yellow}PHP7.4-intl no esta instal.lat, procedim amb la descarga"
	apt-get -y install php7.4-intl >/dev/null 2>&1

	if [ $? -eq 0 ]; then

		echo -e "${Green}PHP7.4-intl instal.at correctament\n"
		echo "PHP7.4-intl instal.at correctament" >>/var/logs/registres/install/glpi.log
	else

		echo -e "${Red}.4-intl instal.lat incorrectament"
		exit
	fi

else

	echo -e "${Green}PHP7.4-intl ja esta instal.lat, continuem\n"

fi

if [ $(dpkg-query -W -f='${Status}' 'php7.4-ldap' >/dev/null 2>&1 | grep -c "ok installed") >/dev/null 2>&1 -eq 0 ]; then

	echo -e "${Yellow}PHP7.4-ldap no esta instal.lat, procedim amb la descarga"
	apt-get -y install php7.4-ldap >/dev/null 2>&1

	if [ $? -eq 0 ]; then

		echo -e "${Green}PHP7.4-ldap instal.at correctament\n"
		echo "PHP7.4-ldap instal.at correctament" >>/var/logs/registres/install/glpi.log
	else

		echo -e "${Red}PHP7.4-ldap instal.lat incorrectament"
		exit
	fi

else

	echo -e "${Green}PHP7.4-ldap ja esta instal.lat, continuem\n"

fi

if [ $(dpkg-query -W -f='${Status}' 'php7.4-mbstring' >/dev/null 2>&1 | grep -c "ok installed") >/dev/null 2>&1 -eq 0 ]; then

	echo -e "${Yellow}PHP7.4-mbstring no esta instal.lat, procedim amb la descarga"
	apt-get -y install php7.4-mbstring >/dev/null 2>&1

	if [ $? -eq 0 ]; then

		echo -e "${Green}PHP7.4-mbstring instal.at correctament\n"
		echo "PHP7.4-mbstring instal.at correctament" >>/var/logs/registres/install/glpi.log
	else

		echo -e "${Red}PHP7.4-mbstring instal.lat incorrectament"
		exit
	fi

else

	echo -e "${Green}PHP7.4-mbstring ja esta instal.lat, continuem\n"

fi

if [ $(dpkg-query -W -f='${Status}' 'php7.4-xml' >/dev/null 2>&1 | grep -c "ok installed") >/dev/null 2>&1 -eq 0 ]; then

	echo -e "${Yellow}PHP7.4-xml no esta instal.lat, procedim amb la descarga"
	apt-get -y install php7.4-xml >/dev/null 2>&1

	if [ $? -eq 0 ]; then

		echo -e "${Green}PHP7.4-xml instal.at correctament\n"
		echo "PHP7.4-xml instal.at correctament" >>/var/logs/registres/install/glpi.log
	else

		echo -e "${Red}PHP7.4-xml instal.lat incorrectament"
		exit
	fi

else

	echo -e "${Green}PHP7.4-xml ja esta instal.lat, continuem\n"

fi

if [ $(dpkg-query -W -f='${Status}' 'php7.4-xmlrpc' >/dev/null 2>&1 | grep -c "ok installed") >/dev/null 2>&1 -eq 0 ]; then

	echo -e "${Yellow}PHP7.4-xmlrpc no esta instal.lat, procedim amb la descarga"
	apt-get -y install php7.4-xmlrpc >/dev/null 2>&1

	if [ $? -eq 0 ]; then

		echo -e "${Green}PHP7.4-xmlrpc instal.at correctament\n"
		echo "PHP7.4-xmlrpc instal.at correctament" >>/var/logs/registres/install/glpi.log
	else

		echo -e "${Red}PHP7.4-xmlrpc instal.lat incorrectament"
		exit
	fi

else

	echo -e "${Green}PHP7.4-xmlrpc ja esta instal.lat, continuem\n"

fi

if [ $(dpkg-query -W -f='${Status}' 'php7.4-zip' >/dev/null 2>&1 | grep -c "ok installed") >/dev/null 2>&1 -eq 0 ]; then

	echo -e "${Yellow}PHP7.4-zip no esta instal.lat, procedim amb la descarga"
	apt-get -y install php7.4-zip >/dev/null 2>&1

	if [ $? -eq 0 ]; then

		echo -e "${Green}PHP7.4-zip instal.at correctament\n"
		echo "PHP7.4-zip instal.at correctament" >>/var/logs/registres/install/glpi.log
	else

		echo -e "${Red}PHP7.4-zip instal.lat incorrectament"
		exit
	fi

else

	echo -e "${Green}PHP7.4-zip ja esta instal.lat, continuem\n"

fi

if [ $(dpkg-query -W -f='${Status}' 'php7.4-mysql' >/dev/null 2>&1 | grep -c "ok installed") >/dev/null 2>&1 -eq 0 ]; then

	echo -e "${Yellow}PHP7.4-mysql no esta instal.lat, procedim amb la descarga"
	apt-get -y install php7.4-mysql >/dev/null 2>&1

	if [ $? -eq 0 ]; then

		echo -e "${Green}PHP7.4-mysql instal.at correctament\n"
		echo "PHP7.4-mysql instal.at correctament" >>/var/logs/registres/install/glpi.log
	else

		echo -e "${Red}PHP7.4-mysql instal.lat incorrectament"
		exit
	fi

else

	echo -e "${Green}PHP7.4-mysql ja esta instal.lat, continuem\n"

fi

systemctl restart apache2 >/dev/null 2>&1
if [ $? -eq 0 ]; then

	echo -e "${Green}Apache reiniciat correctament"
	echo "Apache reiniciat correctament" >>/var/logs/registres/install/glpi.log
else

	echo -e "${Red}Error al reiniciar apache"
	exit
fi

clear
echo -e "${BBlue}Creacio base de dades\n"
#Creacio base dades
dbname="glpi"
if [ -d "/var/lib/mysql/$dbname" ]; then

	echo -e "${Green}La base de dades existeix"
else
	echo -e "${Yellow}La base de dades no exiteix, creant base de dades"
	mysql -u root -e "CREATE DATABASE glpi;"
	mysql -u root -e "CREATE USER 'glpi'@'localhost' IDENTIFIED BY 'glpi';"
	mysql -u root -e "GRANT ALL PRIVILEGES ON glpi .* TO 'glpi'@'localhost';"
	mysql -u root -e "FLUSH PRIVILEGES;"
	mysql -u root -e "exit"
	echo -e "${Green}Base de dades creada correctament\n"
	echo "Base de dades creada correctament" >>/var/logs/registres/install/glpi.log
fi
echo "INSTALACIO DE GLPI FETA CORRECTAMENT" >>/var/logs/registres/install/glpi.log
echo -e "${BBlue}INSTALACIO DE GLPI FETA CORRECTAMENT\n"
echo -e "${White}"
