#!/bin/bash

# Script de prueba rápida para Windows
# Este script verifica las funciones básicas antes de la instalación completa

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}🔍 PRUEBA RÁPIDA PARA WINDOWS${NC}"
echo "========================================"

# Detectar sistema operativo
OS_TYPE=$(uname -s)
case "$OS_TYPE" in
    "Linux")
        if [[ -n "${WSL_DISTRO_NAME}" ]] || [[ -n "${WSLENV}" ]] || [[ "$(uname -r)" == *microsoft* ]]; then
            SYSTEM="WSL"
            SYSTEM_NAME="WSL (Windows Subsystem for Linux)"
        else
            SYSTEM="Linux"
            SYSTEM_NAME="Linux"
        fi
        ;;
    "Darwin")
        SYSTEM="macOS"
        SYSTEM_NAME="macOS"
        ;;
    "CYGWIN"*|"MINGW"*|"MSYS"*)
        SYSTEM="Windows"
        SYSTEM_NAME="Windows (nativo)"
        ;;
    *)
        SYSTEM="Unknown"
        SYSTEM_NAME="Sistema desconocido"
        ;;
esac

echo -e "Sistema detectado: ${GREEN}$SYSTEM_NAME${NC}"
echo -e "Tipo de OS: ${BLUE}$OS_TYPE${NC}"

# Verificar PowerShell
echo -e "\n${YELLOW}Verificando PowerShell:${NC}"
if command -v powershell &> /dev/null; then
    PS_VERSION=$(powershell -Command '$PSVersionTable.PSVersion.Major' 2>/dev/null)
    echo -e "✅ PowerShell Desktop v$PS_VERSION encontrado"
elif command -v pwsh &> /dev/null; then
    PS_VERSION=$(pwsh -Command '$PSVersionTable.PSVersion.Major' 2>/dev/null)
    echo -e "✅ PowerShell Core v$PS_VERSION encontrado"
else
    echo -e "❌ PowerShell no encontrado"
fi

# Verificar gestores de paquetes
echo -e "\n${YELLOW}Verificando gestores de paquetes:${NC}"
if command -v choco &> /dev/null; then
    CHOCO_VERSION=$(choco --version 2>/dev/null | head -n1)
    echo -e "✅ Chocolatey: $CHOCO_VERSION"
else
    echo -e "❌ Chocolatey no instalado (se instalará automáticamente)"
fi

if command -v winget &> /dev/null; then
    WINGET_VERSION=$(winget --version 2>/dev/null)
    echo -e "✅ winget: $WINGET_VERSION"
else
    echo -e "❌ winget no disponible"
fi

# Verificar permisos de administrador
echo -e "\n${YELLOW}Verificando permisos:${NC}"
test_file="/c/Windows/Temp/admin_test_$$"
if touch "$test_file" 2>/dev/null; then
    rm -f "$test_file" 2>/dev/null
    echo -e "✅ Permisos de administrador detectados"
else
    echo -e "⚠️  Ejecutándose sin permisos de administrador"
    echo -e "   ${BLUE}Algunas funciones requerirán elevación${NC}"
fi

# Verificar VS Code
echo -e "\n${YELLOW}Verificando VS Code:${NC}"
if command -v code &> /dev/null; then
    CODE_VERSION=$(code --version 2>/dev/null | head -n1)
    echo -e "✅ VS Code: $CODE_VERSION"
else
    echo -e "❌ VS Code no encontrado en PATH"
fi

# Verificar Git
echo -e "\n${YELLOW}Verificando Git:${NC}"
if command -v git &> /dev/null; then
    GIT_VERSION=$(git --version 2>/dev/null)
    echo -e "✅ $GIT_VERSION"
else
    echo -e "❌ Git no instalado"
fi

# Verificar Node.js
echo -e "\n${YELLOW}Verificando Node.js:${NC}"
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version 2>/dev/null)
    NPM_VERSION=$(npm --version 2>/dev/null)
    echo -e "✅ Node.js: $NODE_VERSION"
    echo -e "✅ npm: $NPM_VERSION"
else
    echo -e "❌ Node.js no instalado"
fi

echo -e "\n${CYAN}=== RESUMEN ===${NC}"
if [[ "$SYSTEM" == "Windows" ]]; then
    echo -e "${GREEN}✅ Sistema Windows nativo detectado correctamente${NC}"
    echo -e "${BLUE}📋 El script de instalación debería funcionar en este sistema${NC}"
    if [[ ! -f "/c/Windows/Temp/admin_test_$$" ]]; then
        echo -e "${YELLOW}⚠️  Recomendación: Ejecutar como administrador para instalación completa${NC}"
    fi
else
    echo -e "${YELLOW}ℹ️  Sistema $SYSTEM detectado - El script funcionará pero no probará funciones específicas de Windows${NC}"
fi

echo -e "\n${BLUE}🚀 Para ejecutar la instalación completa, usa: ./install.sh${NC}"
