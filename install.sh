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

# Configuración de logging
TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
LOG_DIR="logs"
LOG_FILE="$LOG_DIR/installation-$TIMESTAMP.log"
ERROR_LOG="$LOG_DIR/errors-$TIMESTAMP.log"

# Crear directorio de logs si no existe
mkdir -p "$LOG_DIR"

# Funciones de logging
log_message() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
}

log_error() {
    local message="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [ERROR] $message" >> "$ERROR_LOG"
    echo "[$timestamp] [ERROR] $message" >> "$LOG_FILE"
}

log_success() {
    log_message "SUCCESS" "$1"
}

log_info() {
    log_message "INFO" "$1"
}

log_warning() {
    log_message "WARNING" "$1"
}

# Función de compatibilidad para head -n -1 (eliminar última línea)
remove_last_line() {
    local file="$1"
    local temp_file="$2"

    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS: usar sed
        sed '$d' "$file" > "$temp_file"
    else
        # Linux: usar head
        head -n -1 "$file" > "$temp_file"
    fi
}

# Inicializar logging
initialize_logging() {
    local start_time=$(date)
    echo "=== UNIVERSAL DEVELOPMENT SETUP - LOG DE INSTALACIÓN ===" > "$LOG_FILE"
    echo "Fecha de inicio: $start_time" >> "$LOG_FILE"
    echo "Sistema operativo: $(uname -a)" >> "$LOG_FILE"
    echo "Usuario: $(whoami)" >> "$LOG_FILE"
    echo "Directorio de trabajo: $(pwd)" >> "$LOG_FILE"
    echo "Versión del script: 3.0" >> "$LOG_FILE"
    echo "====================================================" >> "$LOG_FILE"
    echo "" >> "$LOG_FILE"

    # Log de errores separado
    echo "=== LOG DE ERRORES - UNIVERSAL DEVELOPMENT SETUP ===" > "$ERROR_LOG"
    echo "Fecha de inicio: $start_time" >> "$ERROR_LOG"
    echo "====================================================" >> "$ERROR_LOG"
    echo "" >> "$ERROR_LOG"

    # Guardar tiempo de inicio para calcular duración
    export start_time
}

# Funciones de utilidad mejoradas con logging
show_header() {
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║            🌍 UNIVERSAL DEVELOPMENT SETUP 3.0               ║"
    echo "║                                                              ║"
    echo "║     Configuración automática para entornos de desarrollo    ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

show_status() {
    echo -e "${GREEN}✅ $1${NC}"
    log_success "$1"
}
show_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
    log_warning "$1"
}
show_error() {
    echo -e "${RED}❌ $1${NC}"
    log_error "$1"
}
show_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
    log_info "$1"
}
show_step() {
    echo -e "${PURPLE}🔧 $1${NC}"
    log_info "STEP: $1"
}

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
        # Usar comando alternativo para evitar caracteres corruptos
        WSL_VERSION=$(wsl.exe --version 2>/dev/null | grep -E "Versión|Version" | head -1 | tr -cd '[:print:]' || echo 'N/A')
        echo -e "   Versión WSL: ${WSL_VERSION:-N/A}"
    fi

    if [[ "$SYSTEM" == "Linux" ]]; then
        if command -v lsb_release &> /dev/null; then
            echo -e "   Distribución: $(lsb_release -d | cut -f2)"
        elif [[ -f "/etc/os-release" ]]; then
            echo -e "   Distribución: $(grep PRETTY_NAME /etc/os-release | cut -d'=' -f2 | tr -d '\"')"
        fi
    fi

    # Mostrar información específica de Windows
    if [[ "$SYSTEM" == "Windows" ]]; then
        show_windows_info
    fi

    echo ""
}

# Función para mostrar información del sistema Windows
show_windows_info() {
    echo -e "\n${BLUE}=== INFORMACIÓN DEL SISTEMA WINDOWS ===${NC}"

    # Verificar tipo de entorno Windows
    if [[ -n "$WSLENV" ]]; then
        echo -e "🔹 Entorno: ${YELLOW}WSL (Windows Subsystem for Linux)${NC}"
        echo -e "🔹 Distribución: ${WSL_DISTRO_NAME:-Ubuntu}"
    elif [[ "$OSTYPE" == "cygwin" ]]; then
        echo -e "🔹 Entorno: ${YELLOW}Cygwin${NC}"
    elif [[ "$OSTYPE" == "msys" ]]; then
        echo -e "🔹 Entorno: ${YELLOW}MSYS2/MinGW${NC}"
    else
        echo -e "🔹 Entorno: ${YELLOW}Windows Nativo${NC}"
    fi

    # Verificar PowerShell
    if command -v powershell &> /dev/null; then
        local ps_version=$(powershell -Command '$PSVersionTable.PSVersion.Major' 2>/dev/null)
        echo -e "🔹 PowerShell: ${GREEN}Disponible v$ps_version${NC}"
    elif command -v pwsh &> /dev/null; then
        local ps_version=$(pwsh -Command '$PSVersionTable.PSVersion.Major' 2>/dev/null)
        echo -e "🔹 PowerShell Core: ${GREEN}Disponible v$ps_version${NC}"
    else
        echo -e "🔹 PowerShell: ${RED}No disponible${NC}"
    fi

    # Verificar gestores de paquetes
    if command -v choco &> /dev/null; then
        local choco_version=$(choco --version 2>/dev/null | head -n1)
        echo -e "🔹 Chocolatey: ${GREEN}Instalado ($choco_version)${NC}"
    else
        echo -e "🔹 Chocolatey: ${YELLOW}No instalado (se instalará automáticamente)${NC}"
    fi

    if command -v winget &> /dev/null; then
        local winget_version=$(winget --version 2>/dev/null)
        echo -e "🔹 winget: ${GREEN}Disponible ($winget_version)${NC}"
    else
        echo -e "🔹 winget: ${YELLOW}No disponible${NC}"
    fi

    # Verificar permisos de administrador
    if check_admin_windows; then
        echo -e "🔹 Permisos: ${GREEN}Administrador${NC}"
    else
        echo -e "🔹 Permisos: ${YELLOW}Usuario estándar${NC}"
        echo -e "  ${YELLOW}Nota: Algunos componentes requieren permisos de administrador${NC}"
    fi

    echo ""
}

# Verificar permisos de administrador en Windows
check_admin_windows() {
    # Intentar escribir en directorio del sistema
    local test_file="/c/Windows/Temp/admin_test_$$"
    if touch "$test_file" 2>/dev/null; then
        rm -f "$test_file" 2>/dev/null
        return 0
    fi
    return 1
}

# Función para finalizar el logging con estadísticas de tiempo y estado
finalize_logging() {
    local end_time=$(date)
    local start_timestamp
    local current_timestamp=$(date +%s)

    # Compatibilidad macOS vs Linux para conversión de fecha
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS usa date -jf
        start_timestamp=$(date -jf "%a %b %d %H:%M:%S %Z %Y" "$start_time" +%s 2>/dev/null || echo 0)
    else
        # Linux usa date -d
        start_timestamp=$(date -d "$start_time" +%s 2>/dev/null || echo 0)
    fi

    local duration=$((current_timestamp - start_timestamp))

    echo "" >> "$LOG_FILE"
    echo "====================================================" >> "$LOG_FILE"
    echo "Instalación finalizada: $end_time" >> "$LOG_FILE"
    if [[ $duration -gt 0 ]]; then
        echo "Duración total: ${duration}s" >> "$LOG_FILE"
    fi
    echo "Estado final: COMPLETADO" >> "$LOG_FILE"
    echo "====================================================" >> "$LOG_FILE"

    # Resumen en log de errores si hay errores
    if [[ -s "$ERROR_LOG" ]]; then
        echo "" >> "$ERROR_LOG"
        echo "====================================================" >> "$ERROR_LOG"
        echo "Instalación completada con errores: $end_time" >> "$ERROR_LOG"
        echo "====================================================" >> "$ERROR_LOG"
    fi
}

# Función para configurar terminal
configure_terminal() {
    show_step "Configurando terminal (Zsh + Oh My Zsh + Powerlevel10k)..."

    local terminal_script="$(dirname "$0")/scripts/terminal-setup.sh"

    if [[ -f "$terminal_script" ]]; then
        echo -e "${BLUE}ℹ️  Ejecutando configuración completa del terminal...${NC}"
        echo -e "${YELLOW}⚠️  Esto configurará Zsh, Oh My Zsh y Powerlevel10k${NC}"
        echo ""

        # Ejecutar script de terminal
        if bash "$terminal_script"; then
            show_status "Terminal configurado exitosamente"
            echo -e "${GREEN}✅ Zsh + Oh My Zsh + Powerlevel10k instalado${NC}"
            echo -e "${BLUE}ℹ️  Reinicia tu terminal para aplicar los cambios${NC}"
        else
            show_error "Error al configurar terminal"
            return 1
        fi
    else
        show_error "Script de terminal no encontrado: $terminal_script"
        return 1
    fi
}

# Función principal
main() {
    # Inicializar logging
    initialize_logging

    # Verificar si se pasa el argumento --auto para instalación automática
    if [[ "$1" == "--auto" ]] || [[ "$AUTO_INSTALL" == "true" ]]; then
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
        source "$(dirname "$0")/scripts/git-config.sh"

        # Ejecutar instalación completa automáticamente
        echo -e "${CYAN}🚀 INICIANDO INSTALACIÓN AUTOMÁTICA COMPLETA...${NC}"
        echo ""
        full_installation

        echo ""
        echo -e "${GREEN}🎉 ¡Instalación automática completada!${NC}"
        echo -e "${BLUE}ℹ️  Para más opciones, ejecuta: ./install.sh${NC}"
        return 0
    fi

    # Modo interactivo normal
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
    source "$(dirname "$0")/scripts/git-config.sh"

    # Mostrar menú
    while true; do
        show_menu
        read -p "Selecciona una opción (1-11): " choice

        case $choice in
            1) check_status ;;
            2) full_installation ;;
            3) install_base_dependencies ;;
            4) install_fonts ;;
            5) configure_terminal ;;
            6) install_vscode_extensions ;;
            7) configure_vscode_settings ;;
            8) install_npm_tools ;;
            9) configure_git ;;
            10) show_help ;;
            11)
                echo -e "${CYAN}👋 ¡Gracias por usar Universal Development Setup!${NC}"
                exit 0
                ;;
            *)
                show_error "Opción inválida. Selecciona 1-11."
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
    echo "5. 🖥️  Solo configuración de terminal"
    echo "6. 🔌 Solo extensiones VS Code"
    echo "7. ⚙️  Solo configuración VS Code"
    echo "8. 🛠️  Solo herramientas npm"
    echo "9. 🔧 Configurar Git (usuario/email)"
    echo "10. 📚 Ayuda y documentación"
    echo "11. ❌ Salir"

    # Mostrar advertencias específicas para Windows
    if [[ "$SYSTEM" == "Windows" ]]; then
        echo ""
        echo -e "${YELLOW}⚠️  NOTA PARA WINDOWS:${NC}"
        if ! check_admin_windows; then
            echo -e "   ${YELLOW}• Ejecuta como administrador para instalación completa${NC}"
            echo -e "   ${YELLOW}• Algunas funciones requieren permisos elevados${NC}"
        fi
        if ! command -v choco &> /dev/null && ! command -v winget &> /dev/null; then
            echo -e "   ${YELLOW}• Chocolatey se instalará automáticamente si es necesario${NC}"
        fi
        echo -e "   ${BLUE}• PowerShell es requerido para instalación completa${NC}"
    fi
    echo ""
}

# Función para preguntar sobre configuración de terminal
ask_terminal_configuration() {
    echo ""
    echo -e "${CYAN}🖥️  CONFIGURACIÓN DE TERMINAL${NC}"
    echo "═══════════════════════════════════════════════════════════════"
    echo -e "${BLUE}¿Deseas configurar el terminal con Zsh + Oh My Zsh + Powerlevel10k?${NC}"
    echo ""
    echo -e "${YELLOW}Esto incluye:${NC}"
    echo "• Zsh como shell por defecto"
    echo "• Oh My Zsh con plugins esenciales"
    echo "• Tema Powerlevel10k personalizado"
    echo "• Fuentes Nerd Font para iconos"
    echo ""

    while true; do
        read -p "¿Configurar terminal? (s/n): " terminal_choice
        case $terminal_choice in
            [Ss]|[Yy]|[Ss][Ii]|[Yy][Ee][Ss])
                echo ""
                echo -e "${CYAN}🚀 Iniciando configuración del terminal...${NC}"
                echo ""
                # Ejecutar directamente el script de terminal
                if bash "$(dirname "$0")/scripts/terminal-setup.sh"; then
                    echo ""
                    echo -e "${GREEN}✅ ¡Terminal configurado exitosamente!${NC}"
                    echo -e "${BLUE}ℹ️  Reinicia tu terminal para aplicar todos los cambios${NC}"
                else
                    echo ""
                    echo -e "${YELLOW}⚠️  Hubo algunos problemas con la configuración del terminal${NC}"
                    echo -e "${BLUE}ℹ️  Puedes ejecutar manualmente: ./scripts/terminal-setup.sh${NC}"
                fi
                break
                ;;
            [Nn]|[Nn][Oo])
                echo ""
                echo -e "${BLUE}ℹ️  Configuración de terminal omitida${NC}"
                echo -e "${CYAN}💡 Puedes configurarlo más tarde ejecutando: ./install.sh (opción 5)${NC}"
                break
                ;;
            *)
                echo -e "${RED}❌ Respuesta inválida. Por favor responde 's' o 'n'${NC}"
                ;;
        esac
    done
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

    # Finalizar logging
    finalize_logging

    # Mostrar información específica de VS Code
    show_vscode_post_install_info

    echo -e "${BLUE}ℹ️  Reinicia VS Code para aplicar todas las configuraciones${NC}"
    echo -e "${CYAN}📋 Los logs se guardaron en: $LOG_FILE${NC}"
    if [[ -s "$ERROR_LOG" ]]; then
        echo -e "${YELLOW}⚠️  Errores encontrados guardados en: $ERROR_LOG${NC}"
    fi

    # Preguntar sobre configuración del terminal
    ask_terminal_configuration
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

    # Verificar configuración Git
    if command -v git &> /dev/null; then
        git_name=$(git config --global user.name 2>/dev/null)
        git_email=$(git config --global user.email 2>/dev/null)
        if [[ -n "$git_name" && -n "$git_email" ]]; then
            show_status "Git configurado ($git_name)"
        else
            show_warning "Git no configurado"
        fi
    else
        show_warning "Git no instalado"
    fi

    # Verificar configuración de terminal
    if command -v zsh &> /dev/null; then
        show_status "Zsh instalado"
        if [[ -d "$HOME/.oh-my-zsh" ]]; then
            show_status "Oh My Zsh instalado"
        else
            show_warning "Oh My Zsh no instalado"
        fi

        if [[ -f "$HOME/.p10k.zsh" ]]; then
            show_status "Powerlevel10k configurado"
        else
            show_warning "Powerlevel10k no configurado"
        fi
    else
        show_warning "Zsh no instalado"
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
    echo "• La configuración de terminal requiere reinicio del terminal"
    echo "• Zsh se configurará como shell por defecto automáticamente"
    echo ""
    echo -e "${YELLOW}📁 ARCHIVOS DE CONFIGURACIÓN:${NC}"
    echo "• VS Code: $VSCODE_SETTINGS_DIR/settings.json"
    echo "• Fuentes: $FONT_DIR"
    echo "• Terminal: ~/.zshrc, ~/.p10k.zsh, ~/.oh-my-zsh/"
    echo "• Backups: $VSCODE_SETTINGS_DIR/settings.json.backup.*"
    echo ""
    echo -e "${YELLOW}🖥️ CONFIGURACIÓN DE TERMINAL:${NC}"
    echo "• Instala Zsh como shell por defecto"
    echo "• Configura Oh My Zsh con plugins esenciales"
    echo "• Instala tema Powerlevel10k con configuración personalizada"
    echo "• Incluye fuentes Nerd Font para iconos"
    echo "• Compatible con macOS, Linux y WSL"
    echo ""
    echo -e "${YELLOW}🌐 RECURSOS ADICIONALES:${NC}"
    echo "• Documentación: https://github.com/tu-usuario/universal-dev-setup"
    echo "• Issues: https://github.com/tu-usuario/universal-dev-setup/issues"
    echo "• VS Code: https://code.visualstudio.com/"
    echo "• Oh My Zsh: https://ohmyz.sh/"
    echo "• Powerlevel10k: https://github.com/romkatv/powerlevel10k"
    echo ""
}

# Ejecutar script principal solo si se ejecuta directamente (no con source)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
