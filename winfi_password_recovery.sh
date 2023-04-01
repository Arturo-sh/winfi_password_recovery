#!/bin/env bash

# Programa para obtener las contraseñas almacenadas en equipos Windows

# Colores
red="\e[1;31m"
green="\e[1;32m"
yellow="\e[1;33m"
cyan="\e[1;36m"
reset="\e[0m"

if [[ -f $(pwd)/passwords.txt ]]; then
    echo -e -n "${red}Ya existe un fichero de contraseñas, desea sobreescribirlo (s/N)?:${reset} "
    read rewrite
    if [[ ${rewrite} == "s" ]] || [[ ${rewrite} == "S" ]]; then
        rm passwords.txt
    else
        exit 1
    fi
fi

echo -e "\n${yellow}Creando archivos temporales...${reset}"
netsh wlan show profile | sed -e "s/^\([A-Za-z\s\(\)\<\>]\|\s\|\-\)\+//g" -e "s/\://g" | xargs -i echo {} > networks.txt
touch passwords.txt
mapfile -t networks < networks.txt

echo -e "\n${cyan}* Obteniendo contraseñas *${reset}"
for i in $(seq ${#networks[@]}); do
    network=$(awk "NR==${i}" networks.txt)
    netsh wlan show profile name = "${network}" key = clear > raw_data.txt
    grep -i "Nombre de SSID" raw_data.txt >> passwords.txt
    grep -i "Contenido de la clave" raw_data.txt >> passwords.txt
    echo -e "" >> passwords.txt
done

echo "    Total de redes encontradas: ${#networks[@]}" >> passwords.txt

rm {networks.txt,raw_data.txt}

echo -e "\n${green}Contraseñas almacenadas en el fichero passwords.txt${reset}"
