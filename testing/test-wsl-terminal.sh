#!/bin/bash

# Script para probar configuración de terminal WSL
# Verifica que la configuración de VS Code esté correcta para WSL

echo "🔍 Verificando configuración de terminal WSL..."

# Verificar que estamos en WSL
if [[ -z "$WSL_DISTRO_NAME" ]]; then
    echo "❌ Error: Este script debe ejecutarse desde WSL"
    exit 1
fi

echo "✅ Sistema detectado: WSL ($WSL_DISTRO_NAME)"

# Verificar que VS Code esté instalado
if ! command -v code &> /dev/null; then
    echo "❌ Error: VS Code no está disponible en PATH"
    exit 1
fi

echo "✅ VS Code disponible"

# Verificar directorio de configuración VSCode
VSCODE_CONFIG_DIR="$HOME/.vscode-server/data/Machine"
if [[ ! -d "$VSCODE_CONFIG_DIR" ]]; then
    echo "⚠️  Advertencia: Directorio de configuración no existe: $VSCODE_CONFIG_DIR"
else
    echo "✅ Directorio de configuración encontrado"
fi

# Verificar archivo settings.json
SETTINGS_FILE="$VSCODE_CONFIG_DIR/settings.json"
if [[ ! -f "$SETTINGS_FILE" ]]; then
    echo "⚠️  Advertencia: settings.json no existe"
else
    echo "✅ settings.json encontrado"

    # Verificar configuración de terminal WSL
    if grep -q "Ubuntu (WSL)" "$SETTINGS_FILE"; then
        echo "✅ Configuración de terminal Ubuntu WSL encontrada"
    else
        echo "❌ Error: Configuración de terminal Ubuntu WSL no encontrada"
    fi

    # Verificar configuración predeterminada
    if grep -q '"terminal.integrated.defaultProfile.windows": "Ubuntu (WSL)"' "$SETTINGS_FILE"; then
        echo "✅ Terminal Ubuntu WSL configurada como predeterminada"
    else
        echo "❌ Error: Terminal Ubuntu WSL no está configurada como predeterminada"
    fi
fi

echo ""
echo "🔧 Para solucionar problemas de terminal:"
echo "1. Ejecuta el script de configuración: ./install.sh"
echo "2. Selecciona opción 5 (VS Code)"
echo "3. Reinicia VS Code"
echo "4. Verifica que la terminal predeterminada sea Ubuntu (WSL)"
echo ""
echo "📋 Configuración manual si es necesario:"
echo "1. Abrir VS Code Settings (Ctrl+,)"
echo "2. Buscar 'terminal.integrated.defaultProfile.windows'"
echo "3. Seleccionar 'Ubuntu (WSL)'"
