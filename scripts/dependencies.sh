#!/bin/bash

# Módulo de instalación de dependencias base
# Compatible con macOS, Linux, WSL, Windows

install_base_dependencies() {
    show_step "Instalando dependencias base para $SYSTEM..."
    
    case "$SYSTEM" in
        "macOS")
            install_macos_dependencies
            ;;
        "WSL"|"Linux")
            install_linux_dependencies
            ;;
        "Windows")
            install_windows_dependencies
            ;;
    esac
    
    show_status "Dependencias base instaladas"
}

install_macos_dependencies() {
    # Verificar e instalar Homebrew
    if ! command -v brew &> /dev/null; then
        show_info "Instalando Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Agregar Homebrew al PATH
        eval "$(/opt/homebrew/bin/brew shellenv)" 2>/dev/null || eval "$(/usr/local/bin/brew shellenv)"
    fi
    
    # Actualizar Homebrew
    brew update
    
    # Instalar herramientas base
    brew install git curl wget
    
    # Instalar Node.js si no está instalado
    if ! command -v node &> /dev/null; then
        show_info "Instalando Node.js..."
        brew install node
    fi
    
    # Herramientas adicionales útiles
    brew install tree jq
}

install_linux_dependencies() {
    # Actualizar repositorios
    sudo apt update && sudo apt upgrade -y
    
    # Instalar herramientas base
    sudo apt install -y \
        git \
        curl \
        wget \
        build-essential \
        fontconfig \
        unzip \
        tree \
        jq \
        apt-transport-https \
        ca-certificates \
        software-properties-common
    
    # Instalar Node.js via NodeSource si no está instalado
    if ! command -v node &> /dev/null; then
        show_info "Instalando Node.js (LTS)..."
        curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
        sudo apt install -y nodejs
    fi
    
    # Verificar instalación
    if command -v node &> /dev/null; then
        show_info "Node.js $(node --version) instalado"
        show_info "npm $(npm --version) instalado"
    fi
}

install_windows_dependencies() {
    show_warning "Instalación en Windows nativo requiere configuración manual"
    
    if command -v choco &> /dev/null; then
        show_info "Usando Chocolatey para instalar dependencias..."
        choco install -y git nodejs curl wget
    elif command -v winget &> /dev/null; then
        show_info "Usando winget para instalar dependencias..."
        winget install Git.Git
        winget install OpenJS.NodeJS
        winget install cURL.cURL
        winget install GNU.Wget
    else
        show_error "No se encontró gestor de paquetes (Chocolatey o winget)"
        show_info "Instala manualmente:"
        echo "• Git: https://git-scm.com/download/win"
        echo "• Node.js: https://nodejs.org/en/download/"
        echo "• Chocolatey: https://chocolatey.org/install"
        return 1
    fi
}

# Función para verificar dependencias específicas
check_dependency() {
    local dep="$1"
    local install_cmd="$2"
    
    if ! command -v "$dep" &> /dev/null; then
        show_warning "$dep no está instalado"
        if [[ -n "$install_cmd" ]]; then
            show_info "Instalando $dep..."
            eval "$install_cmd"
        fi
        return 1
    else
        show_status "$dep encontrado"
        return 0
    fi
}

# Función para instalar herramientas de desarrollo adicionales
install_dev_tools() {
    show_step "Instalando herramientas de desarrollo adicionales..."
    
    case "$SYSTEM" in
        "macOS")
            brew install --quiet \
                bat \
                fd \
                ripgrep \
                fzf \
                exa \
                htop \
                neofetch 2>/dev/null || true
            ;;
        "WSL"|"Linux")
            sudo apt install -y \
                bat \
                fd-find \
                ripgrep \
                fzf \
                exa \
                htop \
                neofetch 2>/dev/null || true
            
            # Crear enlaces simbólicos si es necesario
            if [[ ! -f "/usr/local/bin/bat" ]] && [[ -f "/usr/bin/batcat" ]]; then
                sudo ln -sf /usr/bin/batcat /usr/local/bin/bat
            fi
            
            if [[ ! -f "/usr/local/bin/fd" ]] && [[ -f "/usr/bin/fdfind" ]]; then
                sudo ln -sf /usr/bin/fdfind /usr/local/bin/fd
            fi
            ;;
    esac
    
    show_status "Herramientas de desarrollo instaladas"
}
