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
Purple='\033[0;35m'#Informació
Cyan='\033[0;36m'#Correcte
Yellow='\033[0;32m'#Errors

#Comprovacio usuari root
echo -e " ______ _      _____ _____"
echo -e "/ _____| |    |  __ \_   _|"
echo -e "| | ___| |    | |__) || | "
echo -e "| | |_ | |    |  ___/ | |  "
echo -e "| |__| | |____| |    _| |_ "
echo -e "\______|______|_|   |_____|"
echo -e "\n\n"

echo -e "${Purple}Comprovacions preliminars\n"
if [ $(whoami) == "root" ]; then
	echo -e "${Cyan}Ets root, seguirem amb l'instalacio"
# Apartat b)
	echo "Ets root, seguirem amb l'instalacio" >> /var/logs/registres/install/glpi.log
else
	echo -e "${Yellow}No ets root, resgistret com usuari root i torna a executar el script"
# Apartat c)
  echo "No ets root, resgistret com usuari root i torna a executar el script" >> /var/logs/registres/install/errors.log
	exit
fi

