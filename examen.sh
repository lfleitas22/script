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
