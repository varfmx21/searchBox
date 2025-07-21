#!/bin/bash

# Catppuccin Mocha Colours (ANSI 256)
greenColour="\e[38;5;114m\033[1m"     # Catppuccin Green (#a6e3a1)
endColour="\033[0m\e[0m"
redColour="\e[38;5;203m\033[1m"       # Catppuccin Red (#f38ba8)
blueColour="\e[38;5;75m\033[1m"       # Catppuccin Blue (#89b4fa)
yellowColour="\e[38;5;221m\033[1m"    # Catppuccin Yellow (#f9e2af)
purpleColour="\e[38;5;141m\033[1m"    # Catppuccin Mauve (#cba6f7)
turquoiseColour="\e[38;5;110m\033[1m" # Catppuccin Sky (#89dceb)
grayColour="\e[38;5;103m\033[1m"      # Catppuccin Subtext1 (#a6adc8)

function ctrl_c() {
  echo -e "\n\n${redColour}[!] Saliendo...${endColour}\n"
  tput cnorm; exit 1
}

# Ctrl+C 
trap ctrl_c INT

# Variables globales
main_url="https://htbmachines.github.io/bundle.js"

function helpPanel() {
  echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Uso:${endColour}"
  echo -e "\t${purpleColour}u)${endColour} ${grayColour}Descargar o actualizar archivos necesarios${endColour}"
  echo -e "\t${purpleColour}m)${endColour} ${grayColour}Buscar por un nombre de maquina${endColour}"
  echo -e "\t${purpleColour}i)${endColour} ${grayColour}Buscar por direcciòn IP${endColour}"
  echo -e "\t${purpleColour}t)${endColour} ${grayColour}Mostrar este panel de ayuda${endColour}"
}

function updateFiles() {

  if [ ! -f bundle.js ]; then
    tput civis
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Descargando archivos necesarios...${endColour}"
    curl -s $main_url > bundle.js
    js-beautify bundle.js | sponge bundle.js
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Todos los archivos han sido descargados${endColour}"
    tput cnorm
  else
    tput civis
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Comprobando si hay actualizaciones pendientes...${endColour}"
    curl -s $main_url > bundle_temp.js 
    js-beautify bundle_temp.js | sponge bundle_temp.js
    md5_temp_value=$(md5sum bundle_temp.js | awk '{print $1}')
    md5_original_value=$(md5sum bundle.js | awk '{print $1}')
    
    if [ "$md5_temp_value" == "$md5_original_value" ]; then
      echo -e "\n${yellowColour}[+]${endColour} ${grayColour}No hay actualizaciones, todo al dia${endColour}"
      rm bundle_temp.js
    else
      echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Se han encontrado actualizaciones...${endColour}"
      sleep 1 

      rm bundle.js && mv bundle_temp.js bundle.js
      echo "\n${yellowColour}[+]${endColour} ${grayColour}Los archivos se han actualizado${endColour}"
    fi
    tput cnorm
  fi
}

function searchMachine() {
  machineName="$1"

  echo -e "${yellowColour}[+]${endColour} ${grayColour}Listando las propiedades de la màquina${endColour} ${purpleColour}$machineName${endColour}${grayColour}:${endColour}\n"
  
  cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta:" | tr -d '"' | tr -d ',' | sed 's/^ *//'
}

function searchIP() {
  ipAddress="$1"

  machineName="$(cat bundle.js | grep "ip: \"$ipAddress\"" -B 5 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',')"

  echo -e "\n${yellowColour}[+]${endColour} ${grayColour}La maquina de la IP${endColour} ${blueColour}$ipAddress${endColour} es ${purpleColour}$machineName${endColour}\n"
}

# Indicadores
declare -i parameterCounter=0 
 
while getopts "i:m:hu" arg; do 
  case $arg in 
   m) machineName=$OPTARG; let parameterCounter+=1;;
   u) let parameterCounter+=2;;
   i) ipAddress=$OPTARG; let parameterCounter+=3;;
   h) ;;
  esac
done

if [ $parameterCounter -eq 1 ]; then
  searchMachine $machineName
elif [ $parameterCounter -eq 2 ]; then
  updateFiles
elif [ $parameterCounter -eq 3 ]; then
  searchIP $ipAddress
else
  helpPanel
fi
