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
    show_step "Instalando dependencias en Windows..."

    # Verificar permisos de administrador
    if ! check_admin_privileges; then
        show_error "Este script requiere permisos de administrador en Windows"
        show_info "Ejecuta PowerShell como administrador y vuelve a intentar"
        return 1
    fi

    # Verificar e instalar gestor de paquetes
    if ! ensure_package_manager; then
        show_error "No se pudo configurar un gestor de paquetes"
        return 1
    fi

    # Lista de dependencias esenciales
    local dependencies=(
        "git"
        "nodejs" 
        "curl"
        "wget"
        "python3"
        "7zip"
    )

    # Instalar dependencias según el gestor disponible
    if command -v choco &> /dev/null; then
        install_with_chocolatey "${dependencies[@]}"
    elif command -v winget &> /dev/null; then
        install_with_winget "${dependencies[@]}"
    else
        show_error "No se encontró gestor de paquetes válido"
        return 1
    fi

    # Verificar instalaciones
    verify_windows_dependencies
}

# Verificar permisos de administrador en Windows
check_admin_privileges() {
    show_info "Verificando permisos de administrador..."
    
    # Método 1: Intentar escribir en directorio del sistema (más compatible con Git Bash)
    local test_file="/c/Windows/Temp/admin_test_$$"
    if touch "$test_file" 2>/dev/null; then
        rm -f "$test_file" 2>/dev/null
        show_status "Permisos de escritura confirmados"
        return 0
    fi
    
    # Método 2: Usar PowerShell para verificar si está disponible
    if command -v powershell.exe &> /dev/null; then
        if powershell.exe -Command "([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)" 2>/dev/null | grep -q "True"; then
            show_status "Permisos de administrador confirmados via PowerShell"
            return 0
        fi
    fi

    # Método 3: Verificar variable de entorno administrativa
    if [[ "$USERNAME" == "Administrator" ]] || [[ -n "$ADMINISTRATOR" ]]; then
        show_status "Usuario administrador detectado"
        return 0
    fi

    show_warning "No se pudieron verificar permisos de administrador"
    return 1
}

# Asegurar que hay un gestor de paquetes disponible
ensure_package_manager() {
    show_info "Verificando gestores de paquetes..."

    # Verificar si Chocolatey ya está instalado
    if command -v choco &> /dev/null; then
        show_status "Chocolatey ya está instalado"
        choco --version
        return 0
    fi

    # Verificar si winget está disponible
    if command -v winget &> /dev/null; then
        show_status "winget está disponible"
        winget --version
        return 0
    fi

    # Instalar Chocolatey automáticamente
    show_info "Instalando Chocolatey..."
    install_chocolatey
}

# Instalar Chocolatey automáticamente
install_chocolatey() {
    show_step "Instalando Chocolatey Package Manager..."

    # Verificar PowerShell
    if ! command -v powershell &> /dev/null && ! command -v pwsh &> /dev/null; then
        show_error "PowerShell no está disponible"
        return 1
    fi

    # Script de instalación de Chocolatey
    local install_script='
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        iex ((New-Object System.Net.WebClient).DownloadString("https://community.chocolatey.org/install.ps1"))
    '

    show_info "Descargando e instalando Chocolatey..."
    
    # Ejecutar instalación
    if command -v powershell &> /dev/null; then
        echo "$install_script" | powershell -Command -
    elif command -v pwsh &> /dev/null; then
        echo "$install_script" | pwsh -Command -
    fi

    # Verificar instalación
    sleep 3
    if command -v choco &> /dev/null; then
        show_status "Chocolatey instalado correctamente"
        choco --version
        
        # Configurar Chocolatey
        choco feature enable -n allowGlobalConfirmation
        show_info "Chocolatey configurado para confirmación automática"
        return 0
    else
        show_error "Error al instalar Chocolatey"
        show_info "Instalación manual: https://chocolatey.org/install"
        return 1
    fi
}

# Instalar dependencias con Chocolatey
install_with_chocolatey() {
    local packages=("$@")
    show_info "Instalando dependencias con Chocolatey..."

    # Mapa de paquetes para Chocolatey
    declare -A choco_packages=(
        ["git"]="git"
        ["nodejs"]="nodejs"
        ["curl"]="curl"
        ["wget"]="wget"
        ["python3"]="python"
        ["7zip"]="7zip"
    )

    for package in "${packages[@]}"; do
        local choco_name="${choco_packages[$package]}"
        if [[ -n "$choco_name" ]]; then
            # Verificar si ya está instalado
            case "$package" in
                "git")
                    if command -v git &> /dev/null; then
                        show_status "Git ya está instalado ($(git --version | cut -d' ' -f3))"
                        continue
                    fi
                    ;;
                "nodejs")
                    if command -v node &> /dev/null; then
                        show_status "Node.js ya está instalado ($(node --version))"
                        continue
                    fi
                    ;;
                "curl")
                    if command -v curl &> /dev/null; then
                        show_status "cURL ya está instalado"
                        continue
                    fi
                    ;;
                "wget")
                    if command -v wget &> /dev/null; then
                        show_status "wget ya está instalado"
                        continue
                    fi
                    ;;
                "python3")
                    if command -v python &> /dev/null || command -v python3 &> /dev/null; then
                        show_status "Python ya está instalado"
                        continue
                    fi
                    ;;
                "7zip")
                    if command -v 7z &> /dev/null; then
                        show_status "7-Zip ya está instalado"
                        continue
                    fi
                    ;;
            esac
            
            show_info "Instalando $package ($choco_name)..."
            if choco install "$choco_name" -y --no-progress; then
                show_status "$package instalado"
            else
                show_warning "Error instalando $package"
            fi
        fi
    done
}

# Instalar dependencias con winget
install_with_winget() {
    local packages=("$@")
    show_info "Instalando dependencias con winget..."

    # Mapa de paquetes para winget
    declare -A winget_packages=(
        ["git"]="Git.Git"
        ["nodejs"]="OpenJS.NodeJS"
        ["curl"]="cURL.cURL"
        ["wget"]="GNU.Wget"
        ["python3"]="Python.Python.3.12"
        ["7zip"]="7zip.7zip"
    )

    for package in "${packages[@]}"; do
        local winget_name="${winget_packages[$package]}"
        if [[ -n "$winget_name" ]]; then
            show_info "Instalando $package ($winget_name)..."
            if winget install "$winget_name" --silent --accept-package-agreements --accept-source-agreements; then
                show_status "$package instalado"
            else
                show_warning "Error instalando $package"
            fi
        fi
    done
}

# Verificar dependencias instaladas en Windows
verify_windows_dependencies() {
    show_step "Verificando dependencias instaladas..."

    # Lista de comandos a verificar
    local commands=(
        "git:Git"
        "node:Node.js"
        "npm:npm"
        "curl:cURL"
        "python:Python"
    )

    local verified=0
    local total=${#commands[@]}

    for cmd_info in "${commands[@]}"; do
        local cmd="${cmd_info%%:*}"
        local name="${cmd_info##*:}"
        
        if command -v "$cmd" &> /dev/null; then
            local version=$($cmd --version 2>/dev/null | head -n1)
            show_status "$name: $version"
            ((verified++))
        else
            show_warning "$name no encontrado en PATH"
        fi
    done

    show_info "Dependencias verificadas: $verified/$total"
    
    if [[ $verified -eq $total ]]; then
        show_status "Todas las dependencias están instaladas"
        return 0
    else
        show_warning "Algunas dependencias requieren atención"
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
