#!/bin/bash

# Script épico minimalista: Imagen del lobo + ARGOS ASCII
# Portabilidad total para WSL y cualquier usuario

# Limpiar pantalla completamente
clear
sleep 0.1
clear

# Definir ruta segura para la imagen
SAFE_IMG_DIR="$HOME/.local/share/argosfetch"
SAFE_IMG="$SAFE_IMG_DIR/lobo_logo.png"
ORIG_IMG="$HOME/universal-dev-setup/configs/lobo_logo.png"

# Crear carpeta segura si no existe
mkdir -p "$SAFE_IMG_DIR"

# Copiar la imagen solo si no existe o si la fuente es más nueva
if [ -f "$ORIG_IMG" ] && { [ ! -f "$SAFE_IMG" ] || [ "$ORIG_IMG" -nt "$SAFE_IMG" ]; }; then
    cp "$ORIG_IMG" "$SAFE_IMG"
fi

# Crear arrays para la imagen y el texto ASCII
declare -a wolf_lines
declare -a argos_lines

# Capturar la imagen del lobo (tamaño más pequeño para mejor alineación)
if command -v chafa &>/dev/null && [ -f "$SAFE_IMG" ]; then
    mapfile -t wolf_lines < <(chafa --symbols=block --size=30x18 "$SAFE_IMG")
else
    wolf_lines=("[Imagen no disponible: instala chafa y asegúrate de que $SAFE_IMG existe]")
fi

# ASCII art de ARGOS (más compacto)
argos_lines=(
"    ██████╗ ██████╗  ██████╗  ██████╗ ███████╗"
"   ██╔══██╗██╔══██╗██╔════╝ ██╔═══██╗██╔════╝"
"   ███████║██████╔╝██║  ███╗██║   ██║███████╗"
"   ██╔══██║██╔══██╗██║   ██║██║   ██║╚════██║"
"   ██║  ██║██║  ██║╚██████╔╝╚██████╔╝███████║"
"   ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝  ╚═════╝ ╚══════╝"
"                                               "
"        🐺 W O L F   S Y S T E M 🐺        "
)

# Mostrar la imagen del lobo al lado del texto ARGOS (centrado verticalmente)
echo ""
echo ""

# Calcular líneas para centrar el texto
wolf_lines_count=${#wolf_lines[@]}
argos_lines_count=${#argos_lines[@]}

# Calcular el offset para centrar ARGOS verticalmente
offset=$(( (wolf_lines_count - argos_lines_count) / 2 ))

# Mostrar las líneas combinadas
for ((i=0; i<wolf_lines_count; i++)); do
    wolf_line="${wolf_lines[$i]:-}"
    # Calcular el índice del texto ARGOS considerando el offset
    argos_index=$(( i - offset ))
    if [ $argos_index -ge 0 ] && [ $argos_index -lt $argos_lines_count ]; then
        argos_line="${argos_lines[$argos_index]}"
    else
        argos_line=""
    fi
    # Mostrar línea combinada
    printf "%-35s  %s\n" "$wolf_line" "$argos_line"
done

echo ""
echo ""
