#!/bin/bash
# argosfetch-wsl.sh - Info visual para WSL/Linux, usando facha para imágenes

set -e

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

# Mostrar info básica del sistema
neofetch --ascii_distro Ubuntu --disable resolution wm theme icons font

# Mostrar imagen con facha si está disponible
echo
if command -v facha &>/dev/null && [ -f "$SAFE_IMG" ]; then
    facha "$SAFE_IMG"
else
    echo "[INFO] facha no está instalado o la imagen no está disponible. Ejecuta: pip install facha"
fi

echo
# Mostrar info de red y disco
ip -4 addr show | grep inet | grep -v 127.0.0.1
free -h

echo
# Mensaje final
printf "\e[1;32mListo para programar en WSL!\e[0m\n"
