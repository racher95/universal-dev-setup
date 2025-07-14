#!/bin/bash

# 🌍 Universal Development Setup
# Configuración automática y universal para entornos de desarrollo
# Compatible con: macOS, Linux, WSL, Windows
# Versión: 3.0 - Detección inteligente multi-plataforma

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Funciones de utilidad
show_header() {
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║            🌍 UNIVERSAL DEVELOPMENT SETUP 3.0               ║"
    echo "║                                                              ║"
    echo "║     Configuración automática para entornos de desarrollo    ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

show_status() { echo -e "${GREEN}✅ $1${NC}"; }
show_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
show_error() { echo -e "${RED}❌ $1${NC}"; }
show_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
show_step() { echo -e "${PURPLE}🔧 $1${NC}"; }

# Función para detectar el sistema operativo
detect_system() {
    OS_TYPE="$(uname -s)"
    
    case "$OS_TYPE" in
        "Darwin")
            SYSTEM="macOS"
            SYSTEM_NAME="macOS (nativo)"
            SYSTEM_ICON="🍎"
            ;;
        "Linux")
            if detect_wsl; then
                SYSTEM="WSL"
                DISTRO_NAME="${WSL_DISTRO_NAME:-WSL}"
                SYSTEM_NAME="Linux WSL ($DISTRO_NAME)"
                SYSTEM_ICON="🐧"
            else
                SYSTEM="Linux"
                SYSTEM_NAME="Linux (nativo)"
                SYSTEM_ICON="🐧"
            fi
            ;;
        "CYGWIN"*|"MINGW"*|"MSYS"*)
            SYSTEM="Windows"
            SYSTEM_NAME="Windows (nativo)"
            SYSTEM_ICON="🪟"
            ;;
        *)
            show_error "Sistema operativo no soportado: $OS_TYPE"
            echo "Sistemas soportados: macOS, Linux, WSL, Windows"
            exit 1
            ;;
    esac
    
    echo -e "${SYSTEM_ICON} Sistema detectado: ${CYAN}$SYSTEM_NAME${NC}"
}

# Función para detectar WSL con múltiples métodos
detect_wsl() {
    # Método 1: Variable de entorno WSL_DISTRO_NAME
    if [[ -n "${WSL_DISTRO_NAME}" ]]; then
        return 0
    fi
    
    # Método 2: Variable WSLENV existe
    if [[ -n "${WSLENV}" ]]; then
        return 0
    fi
    
    # Método 3: /proc/version contiene "microsoft" o "WSL"
    if [[ -f "/proc/version" ]] && grep -qi "microsoft\|wsl" /proc/version; then
        return 0
    fi
    
    # Método 4: /proc/sys/kernel/osrelease contiene "microsoft" o "WSL"
    if [[ -f "/proc/sys/kernel/osrelease" ]] && grep -qi "microsoft\|wsl" /proc/sys/kernel/osrelease; then
        return 0
    fi
    
    # Método 5: Directorio /mnt/c existe (típico en WSL)
    if [[ -d "/mnt/c" ]]; then
        return 0
    fi
    
    return 1
}

# Función para configurar rutas según el sistema
setup_paths() {
    case "$SYSTEM" in
        "macOS")
            VSCODE_SETTINGS_DIR="$HOME/Library/Application Support/Code/User"
            FONT_DIR="$HOME/Library/Fonts"
            PACKAGE_MANAGER="brew"
            ;;
        "WSL")
            # Detectar usuario de Windows
            if command -v cmd.exe &> /dev/null; then
                WINDOWS_USER=$(cmd.exe /C "echo %USERNAME%" 2>/dev/null | tr -d '\r\n')
                VSCODE_SETTINGS_DIR="/mnt/c/Users/${WINDOWS_USER}/AppData/Roaming/Code/User"
            else
                show_warning "No se puede detectar usuario de Windows"
                VSCODE_SETTINGS_DIR="$HOME/.vscode-server/data/User"
            fi
            FONT_DIR="/usr/local/share/fonts"
            PACKAGE_MANAGER="apt"
            ;;
        "Linux")
            VSCODE_SETTINGS_DIR="$HOME/.config/Code/User"
            FONT_DIR="/usr/local/share/fonts"
            PACKAGE_MANAGER="apt"
            ;;
        "Windows")
            # Para Windows nativo (Git Bash, MSYS2, etc.)
            VSCODE_SETTINGS_DIR="$APPDATA/Code/User"
            FONT_DIR="/c/Windows/Fonts"
            PACKAGE_MANAGER="choco"  # Assumimos Chocolatey
            ;;
    esac
    
    show_info "Configuración para: $SYSTEM_NAME"
    show_info "VS Code Settings: $VSCODE_SETTINGS_DIR"
    show_info "Directorio de fuentes: $FONT_DIR"
    show_info "Gestor de paquetes: $PACKAGE_MANAGER"
}

# Función para verificar requisitos previos
check_prerequisites() {
    show_step "Verificando requisitos previos..."
    
    case "$SYSTEM" in
        "macOS")
            if ! command -v brew &> /dev/null; then
                show_warning "Homebrew no está instalado"
                show_info "Se instalará automáticamente durante la configuración"
            fi
            ;;
        "WSL"|"Linux")
            if ! command -v apt &> /dev/null; then
                show_error "APT no está disponible"
                exit 1
            fi
            ;;
        "Windows")
            if ! command -v choco &> /dev/null; then
                show_warning "Chocolatey no está instalado"
                show_info "Instálalo desde: https://chocolatey.org/"
                show_info "O usa el gestor de paquetes de Windows"
            fi
            ;;
    esac
    
    # Verificar VS Code
    if ! command -v code &> /dev/null; then
        show_warning "VS Code no está en PATH"
        case "$SYSTEM" in
            "macOS"|"Linux")
                show_info "Instálalo desde: https://code.visualstudio.com/"
                ;;
            "WSL")
                show_info "Instala VS Code en Windows y asegúrate de que esté en PATH"
                ;;
            "Windows")
                show_info "Instala VS Code y asegúrate de agregarlo al PATH"
                ;;
        esac
    else
        show_status "VS Code encontrado"
    fi
    
    # Verificar Node.js
    if command -v node &> /dev/null; then
        show_status "Node.js $(node --version) encontrado"
    else
        show_warning "Node.js no está instalado"
        show_info "Se instalará durante la configuración"
    fi
}

# Función para mostrar información del sistema
show_system_info() {
    echo ""
    echo -e "${CYAN}📋 INFORMACIÓN DEL SISTEMA:${NC}"
    echo -e "   Sistema: $SYSTEM_NAME"
    echo -e "   Arquitectura: $(uname -m)"
    echo -e "   Kernel: $(uname -r)"
    
    if [[ "$SYSTEM" == "WSL" ]]; then
        echo -e "   Distribución WSL: ${WSL_DISTRO_NAME:-N/A}"
        echo -e "   Versión WSL: $(wsl.exe --version 2>/dev/null | head -1 || echo 'N/A')"
    fi
    
    if [[ "$SYSTEM" == "Linux" ]]; then
        if command -v lsb_release &> /dev/null; then
            echo -e "   Distribución: $(lsb_release -d | cut -f2)"
        elif [[ -f "/etc/os-release" ]]; then
            echo -e "   Distribución: $(grep PRETTY_NAME /etc/os-release | cut -d'=' -f2 | tr -d '\"')"
        fi
    fi
    
    echo ""
}

# Función principal
main() {
    show_header
    detect_system
    setup_paths
    check_prerequisites
    show_system_info
    
    # Cargar módulos específicos
    source "$(dirname "$0")/scripts/dependencies.sh"
    source "$(dirname "$0")/scripts/fonts.sh"
    source "$(dirname "$0")/scripts/vscode.sh"
    source "$(dirname "$0")/scripts/npm-tools.sh"
    
    # Mostrar menú
    while true; do
        show_menu
        read -p "Selecciona una opción (1-9): " choice
        
        case $choice in
            1) check_status ;;
            2) full_installation ;;
            3) install_base_dependencies ;;
            4) install_fonts ;;
            5) install_vscode_extensions ;;
            6) configure_vscode_settings ;;
            7) install_npm_tools ;;
            8) show_help ;;
            9) 
                echo -e "${CYAN}👋 ¡Gracias por usar Universal Development Setup!${NC}"
                exit 0
                ;;
            *) 
                show_error "Opción inválida. Selecciona 1-9."
                ;;
        esac
        
        echo ""
        read -p "Presiona Enter para continuar..."
    done
}

# Función para mostrar el menú
show_menu() {
    echo -e "${CYAN}🎯 MENÚ PRINCIPAL:${NC}"
    echo "═══════════════════════════════════════"
    echo "1. 🔍 Verificar estado actual"
    echo "2. 🚀 Instalación completa"
    echo "3. 📦 Solo dependencias base"
    echo "4. 🔤 Solo fuentes de desarrollo"
    echo "5. 🔌 Solo extensiones VS Code"
    echo "6. ⚙️  Solo configuración VS Code"
    echo "7. 🛠️  Solo herramientas npm"
    echo "8. 📚 Ayuda y documentación"
    echo "9. ❌ Salir"
    echo ""
}

# Función para instalación completa
full_installation() {
    show_step "Iniciando instalación completa..."
    
    install_base_dependencies
    install_fonts
    install_vscode_extensions
    configure_vscode_settings
    install_npm_tools
    
    show_status "¡Instalación completa terminada!"
    echo ""
    echo -e "${GREEN}🎉 ¡Tu entorno de desarrollo está listo!${NC}"
    echo -e "${BLUE}ℹ️  Reinicia VS Code para aplicar todas las configuraciones${NC}"
}

# Función para verificar estado
check_status() {
    show_step "Verificando estado actual del sistema..."
    
    echo ""
    echo -e "${CYAN}📊 ESTADO ACTUAL:${NC}"
    echo "═══════════════════════════════════════"
    
    # Verificar VS Code
    if command -v code &> /dev/null; then
        show_status "VS Code encontrado"
        if [[ -f "$VSCODE_SETTINGS_DIR/settings.json" ]]; then
            show_status "Configuración VS Code existe"
        else
            show_warning "Configuración VS Code no encontrada"
        fi
        
        ext_count=$(code --list-extensions 2>/dev/null | wc -l)
        echo -e "   🔌 Extensiones instaladas: $ext_count"
    else
        show_warning "VS Code no encontrado"
    fi
    
    # Verificar Node.js
    if command -v node &> /dev/null; then
        show_status "Node.js $(node --version)"
        if command -v npm &> /dev/null; then
            show_status "npm $(npm --version)"
        fi
    else
        show_warning "Node.js no instalado"
    fi
    
    # Verificar fuentes
    case "$SYSTEM" in
        "macOS")
            if ls "$FONT_DIR"/*Fira* &> /dev/null; then
                show_status "Fuentes de desarrollo instaladas"
            else
                show_warning "Fuentes de desarrollo no encontradas"
            fi
            ;;
        "WSL"|"Linux")
            if ls "$FONT_DIR"/*Fira* &> /dev/null 2>&1; then
                show_status "Fuentes de desarrollo instaladas"
            else
                show_warning "Fuentes de desarrollo no encontradas"
            fi
            ;;
    esac
    
    # Verificar herramientas npm
    if command -v live-server &> /dev/null; then
        show_status "Herramientas npm instaladas"
    else
        show_warning "Herramientas npm no encontradas"
    fi
}

# Función para mostrar ayuda
show_help() {
    echo -e "${CYAN}📚 AYUDA Y DOCUMENTACIÓN:${NC}"
    echo "═══════════════════════════════════════════════════════════════"
    echo ""
    echo -e "${YELLOW}🔧 SOLUCIÓN DE PROBLEMAS:${NC}"
    echo "• Si VS Code no se encuentra, asegúrate de que esté en PATH"
    echo "• En WSL, VS Code debe estar instalado en Windows"
    echo "• Las fuentes requieren reinicio del terminal/VS Code"
    echo "• Para macOS, Homebrew se instala automáticamente"
    echo ""
    echo -e "${YELLOW}📁 ARCHIVOS DE CONFIGURACIÓN:${NC}"
    echo "• VS Code: $VSCODE_SETTINGS_DIR/settings.json"
    echo "• Fuentes: $FONT_DIR"
    echo "• Backups: $VSCODE_SETTINGS_DIR/settings.json.backup.*"
    echo ""
    echo -e "${YELLOW}🌐 RECURSOS ADICIONALES:${NC}"
    echo "• Documentación: https://github.com/tu-usuario/universal-dev-setup"
    echo "• Issues: https://github.com/tu-usuario/universal-dev-setup/issues"
    echo "• VS Code: https://code.visualstudio.com/"
    echo ""
}

# Ejecutar script principal
main "$@"
