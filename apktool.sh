#!/bin/bash
function install_apktool() {
    echo "Actualizando repositorios..." | toilet -f term -F border --gay | lolcat
    apt update && apt upgrade
    pkg update && pkg upgrade
    pkg install -y apktool
    echo "apktool instalado correctamente." | toilet -f term -F border --gay | lolcat
}

if ! command -v apktool &> /dev/null; then
    install_apktool
else
    echo "apktool ya está instalado." | toilet -f term -F border --gay | lolcat
fi
