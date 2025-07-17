#!/bin/bash

# 🔍 Diagnóstico del Sistema para Windows
# Este script verifica la compatibilidad y estado del sistema Windows
# antes de ejecutar la instalación completa de Universal Development Setup

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuración de logging para diagnóstico
TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
LOG_DIR="logs"
DIAG_LOG="$LOG_DIR/diagnostic-$TIMESTAMP.log"

# Crear directorio de logs si no existe
mkdir -p "$LOG_DIR"

# Función de logging para diagnóstico
log_diagnostic() {
    local message="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $message" >> "$DIAG_LOG"
}

# Inicializar logging de diagnóstico
initialize_diagnostic_log() {
    echo "=== DIAGNÓSTICO DEL SISTEMA - UNIVERSAL DEVELOPMENT SETUP ===" > "$DIAG_LOG"
    echo "Fecha: $(date)" >> "$DIAG_LOG"
    echo "Sistema: $(uname -a)" >> "$DIAG_LOG"
    echo "Usuario: $(whoami)" >> "$DIAG_LOG"
    echo "====================================================" >> "$DIAG_LOG"
    echo "" >> "$DIAG_LOG"
}

# Finalizar logging de diagnóstico
finalize_diagnostic_log() {
    echo "" >> "$DIAG_LOG"
    echo "====================================================" >> "$DIAG_LOG"
    echo "Diagnóstico completado: $(date)" >> "$DIAG_LOG"
    echo "====================================================" >> "$DIAG_LOG"
}

# Inicializar logging
initialize_diagnostic_log

echo -e "${CYAN}🔍 DIAGNÓSTICO DEL SISTEMA WINDOWS${NC}"
echo "========================================"
echo -e "${BLUE}ℹ️  Este script verifica la compatibilidad de tu sistema Windows${NC}"
echo -e "${BLUE}ℹ️  con Universal Development Setup antes de la instalación${NC}"
echo ""
log_diagnostic "=== INICIANDO DIAGNÓSTICO ==="

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
log_diagnostic "Sistema detectado: $SYSTEM_NAME ($OS_TYPE)"

# Verificar PowerShell
echo -e "\n${YELLOW}Verificando PowerShell:${NC}"
if command -v powershell &> /dev/null; then
    PS_VERSION=$(powershell -Command '$PSVersionTable.PSVersion.Major' 2>/dev/null)
    echo -e "✅ PowerShell Desktop v$PS_VERSION encontrado"
    log_diagnostic "PowerShell Desktop v$PS_VERSION encontrado"
elif command -v pwsh &> /dev/null; then
    PS_VERSION=$(pwsh -Command '$PSVersionTable.PSVersion.Major' 2>/dev/null)
    echo -e "✅ PowerShell Core v$PS_VERSION encontrado"
    log_diagnostic "PowerShell Core v$PS_VERSION encontrado"
else
    echo -e "❌ PowerShell no encontrado"
    log_diagnostic "PowerShell no encontrado"
fi

# Verificar gestores de paquetes
echo -e "\n${YELLOW}Verificando gestores de paquetes:${NC}"
if command -v choco &> /dev/null; then
    CHOCO_VERSION=$(choco --version 2>/dev/null | head -n1)
    echo -e "✅ Chocolatey: $CHOCO_VERSION"
    log_diagnostic "Chocolatey: $CHOCO_VERSION"
else
    echo -e "❌ Chocolatey no instalado (se instalará automáticamente)"
    log_diagnostic "Chocolatey no instalado"
fi

if command -v winget &> /dev/null; then
    WINGET_VERSION=$(winget --version 2>/dev/null)
    echo -e "✅ winget: $WINGET_VERSION"
    log_diagnostic "winget: $WINGET_VERSION"
else
    echo -e "❌ winget no disponible"
    log_diagnostic "winget no disponible"
fi

# Verificar permisos de administrador
echo -e "\n${YELLOW}Verificando permisos:${NC}"
test_file="/c/Windows/Temp/admin_test_$$"
if touch "$test_file" 2>/dev/null; then
    rm -f "$test_file" 2>/dev/null
    echo -e "✅ Permisos de administrador detectados"
    log_diagnostic "Permisos de administrador detectados"
else
    echo -e "⚠️  Ejecutándose sin permisos de administrador"
    echo -e "   ${BLUE}Algunas funciones requerirán elevación${NC}"
    log_diagnostic "Ejecutándose sin permisos de administrador"
fi

# Verificar VS Code
echo -e "\n${YELLOW}Verificando VS Code:${NC}"
if command -v code &> /dev/null; then
    CODE_VERSION=$(code --version 2>/dev/null | head -n1)
    echo -e "✅ VS Code: $CODE_VERSION"
    log_diagnostic "VS Code: $CODE_VERSION"
else
    echo -e "❌ VS Code no encontrado en PATH"
    log_diagnostic "VS Code no encontrado"
fi

# Verificar Git
echo -e "\n${YELLOW}Verificando Git:${NC}"
if command -v git &> /dev/null; then
    GIT_VERSION=$(git --version 2>/dev/null)
    echo -e "✅ $GIT_VERSION"
    log_diagnostic "$GIT_VERSION"
else
    echo -e "❌ Git no instalado"
    log_diagnostic "Git no instalado"
fi

# Verificar Node.js
echo -e "\n${YELLOW}Verificando Node.js:${NC}"
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version 2>/dev/null)
    NPM_VERSION=$(npm --version 2>/dev/null)
    echo -e "✅ Node.js: $NODE_VERSION"
    echo -e "✅ npm: $NPM_VERSION"
    log_diagnostic "Node.js: $NODE_VERSION"
    log_diagnostic "npm: $NPM_VERSION"
else
    echo -e "❌ Node.js no instalado"
    log_diagnostic "Node.js no instalado"
fi

echo -e "\n${CYAN}=== RESUMEN ===${NC}"
log_diagnostic "=== RESUMEN DEL DIAGNÓSTICO ==="
if [[ "$SYSTEM" == "Windows" ]]; then
    echo -e "${GREEN}✅ Sistema Windows nativo detectado correctamente${NC}"
    echo -e "${BLUE}📋 El script de instalación debería funcionar en este sistema${NC}"
    log_diagnostic "Sistema Windows nativo detectado correctamente"
    if [[ ! -f "/c/Windows/Temp/admin_test_$$" ]]; then
        echo -e "${YELLOW}⚠️  Recomendación: Ejecutar como administrador para instalación completa${NC}"
        log_diagnostic "Recomendación: Ejecutar como administrador"
    fi
else
    echo -e "${YELLOW}ℹ️  Sistema $SYSTEM detectado - El script funcionará pero no probará funciones específicas de Windows${NC}"
    log_diagnostic "Sistema $SYSTEM detectado - no Windows nativo"
fi

echo -e "\n${BLUE}🚀 Para ejecutar la instalación completa, usa: ./install.sh${NC}"
echo -e "${CYAN}📋 Diagnóstico guardado en: $DIAG_LOG${NC}"
echo -e "${BLUE}ℹ️  Comparte este log si necesitas soporte técnico${NC}"

# Finalizar logging de diagnóstico
finalize_diagnostic_log
