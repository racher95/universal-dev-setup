#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════════
# 🖥️  TERMINAL SETUP UNIVERSAL - ZSH + Oh My Zsh + Powerlevel10k
# ═══════════════════════════════════════════════════════════════════════════════
#
# Configurador universal de terminal que:
# - Instala y configura Zsh como shell por defecto
# - Instala Oh My Zsh y plugins esenciales
# - Instala tema Powerlevel10k
# - Aplica configuraciones personalizadas (.zshrc, .zsh_personal, .p10k.zsh)
# - Instala fuentes Nerd Font necesarias
# - Compatible con WSL (Ubuntu/Debian) y macOS
#
# Autor: Kevin Camara (racher95)
# Versión: 1.0
# Compatible: WSL (Ubuntu/Debian), macOS, Linux nativo
# ═══════════════════════════════════════════════════════════════════════════════

# Configuración de bash
set -e  # Salir si hay errores
set -u  # Salir si hay variables no definidas

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Variables globales
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$(dirname "$SCRIPT_DIR")/configs"
SYSTEM=""
PACKAGE_MANAGER=""

# ═══════════════════════════════════════════════════════════════════════════════
# 🎨 FUNCIONES DE DISPLAY Y LOGGING
# ═══════════════════════════════════════════════════════════════════════════════

show_banner() {
    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║            🖥️  TERMINAL SETUP UNIVERSAL                    ║${NC}"
    echo -e "${CYAN}║                                                              ║${NC}"
    echo -e "${CYAN}║     Configuración completa de Zsh + Oh My Zsh + P10k       ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

show_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

show_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

show_error() {
    echo -e "${RED}❌ $1${NC}"
}

show_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

show_step() {
    echo -e "${PURPLE}🔧 $1${NC}"
}

# ═══════════════════════════════════════════════════════════════════════════════
# �️ FUNCIONES AUXILIARES
# ═══════════════════════════════════════════════════════════════════════════════

# Función eliminada - no era necesaria

# ═══════════════════════════════════════════════════════════════════════════════
# �🔍 FUNCIONES DE DETECCIÓN DEL SISTEMA
# ═══════════════════════════════════════════════════════════════════════════════

detect_system() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        SYSTEM="macOS"
        PACKAGE_MANAGER="brew"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if [[ -n "${WSL_DISTRO_NAME:-}" ]]; then
            SYSTEM="WSL"
        else
            SYSTEM="Linux"
        fi

        # Detectar gestor de paquetes
        if command -v apt &> /dev/null; then
            PACKAGE_MANAGER="apt"
        elif command -v dnf &> /dev/null; then
            PACKAGE_MANAGER="dnf"
        elif command -v yum &> /dev/null; then
            PACKAGE_MANAGER="yum"
        elif command -v pacman &> /dev/null; then
            PACKAGE_MANAGER="pacman"
        else
            PACKAGE_MANAGER="unknown"
        fi
    else
        SYSTEM="Unknown"
        PACKAGE_MANAGER="unknown"
    fi

    show_info "Sistema detectado: $SYSTEM"
    show_info "Gestor de paquetes: $PACKAGE_MANAGER"
}

check_config_files() {
    local missing_files=()

    # Verificar archivos de configuración principales
    if [[ ! -f "$CONFIG_DIR/.zshrc" ]]; then
        missing_files+=(".zshrc")
    fi

    if [[ ! -f "$CONFIG_DIR/.zsh_personal" ]]; then
        missing_files+=(".zsh_personal")
    fi

    if [[ ! -f "$CONFIG_DIR/.p10k.zsh" ]]; then
        missing_files+=(".p10k.zsh")
    fi

    # Verificar archivos de ARGOS
    if [[ ! -f "$CONFIG_DIR/argos-fetch-portable" ]]; then
        missing_files+=("argos-fetch-portable")
    fi

    # Verificar imágenes ARGOS según el sistema
    if [[ ! -f "$CONFIG_DIR/Argos-FetchWU.png" ]]; then
        missing_files+=("Argos-FetchWU.png")
    fi

    if [[ ! -f "$CONFIG_DIR/loboMacOS.png" ]]; then
        missing_files+=("loboMacOS.png")
    fi

    # Verificar archivo de configuración adicional
    if [[ ! -f "$CONFIG_DIR/.gitconfig" ]]; then
        missing_files+=(".gitconfig")
    fi

    if [[ ${#missing_files[@]} -gt 0 ]]; then
        show_error "Archivos de configuración faltantes:"
        for file in "${missing_files[@]}"; do
            show_error "  - $CONFIG_DIR/$file"
        done
        show_info "Por favor, asegúrate de que todos los archivos estén en $CONFIG_DIR"
        return 1
    fi

    show_success "Archivos de configuración encontrados"
    return 0
}

# ═══════════════════════════════════════════════════════════════════════════════
# 📦 FUNCIONES DE INSTALACIÓN DE DEPENDENCIAS
# ═══════════════════════════════════════════════════════════════════════════════

install_dependencies() {
    show_step "Instalando dependencias del sistema..."

    case "$PACKAGE_MANAGER" in
        "apt")
            show_info "Actualizando repositorios apt..."
            sudo apt update

            show_info "Instalando dependencias..."
            sudo apt install -y \
                zsh \
                git \
                curl \
                wget \
                build-essential \
                fontconfig \
                unzip \
                software-properties-common
            ;;
        "brew")
            show_info "Actualizando Homebrew..."
            brew update

            show_info "Instalando dependencias..."
            brew install zsh git curl wget
            ;;
        "dnf")
            show_info "Instalando dependencias con dnf..."
            sudo dnf install -y zsh git curl wget fontconfig unzip
            ;;
        "yum")
            show_info "Instalando dependencias con yum..."
            sudo yum install -y zsh git curl wget fontconfig unzip
            ;;
        *)
            show_error "Gestor de paquetes no soportado: $PACKAGE_MANAGER"
            return 1
            ;;
    esac

    show_success "Dependencias instaladas correctamente"
}

install_fonts() {
    show_step "Instalando fuentes Nerd Font..."

    case "$SYSTEM" in
        "macOS")
            # Instalar fuentes con Homebrew (sin tap deprecado)
            show_info "Instalando fuentes con Homebrew..."

            # Asegurarse de que el tap obsoleto no esté presente, para evitar errores
            if brew tap | grep -q "homebrew/cask-fonts"; then
                show_info "Desvinculando tap obsoleto 'homebrew/cask-fonts'..."
                brew untap homebrew/cask-fonts
            fi

            # Las fuentes Nerd Font ahora están disponibles directamente
            local fonts=(
                "font-meslo-lg-nerd-font"
                "font-fira-code-nerd-font"
                "font-jetbrains-mono-nerd-font"
            )

            for font in "${fonts[@]}"; do
                if ! brew list --cask "$font" &> /dev/null; then
                    show_info "Instalando $font..."
                    brew install --cask "$font" || show_warning "Error instalando $font"
                else
                    show_info "$font ya está instalada"
                fi
            done

            # Advertencia específica para Terminal.app
            if [[ "$TERM_PROGRAM" == "Apple_Terminal" ]]; then
                echo ""
                show_warning "⚠️ IMPORTANTE: Terminal.app + Nerd Font = Problemas"
                show_warning "   Terminal.app no soporta correctamente Nerd Font"
                show_warning "   Los iconos aparecerán como cuadrados □ □ □"
                show_warning "   Powerlevel10k no funcionará correctamente"
                echo ""
                show_info "💡 SOLUCIÓN: Cambiar a iTerm2"
                show_info "   1. Descarga iTerm2: https://iterm2.com/"
                show_info "   2. Configura fuente: MesloLGS NF"
                show_info "   3. Disfruta de iconos perfectos ✨"
                echo ""
            else
                show_success "✅ iTerm2 + Nerd Font = Combinación perfecta"
            fi
            ;;
        "WSL"|"Linux")
            # Instalar fuentes manualmente
            show_info "Instalando fuentes Nerd Font..."

            local font_dir="/usr/local/share/fonts/nerd-fonts"
            sudo mkdir -p "$font_dir"

            # Descargar MesloLGS NF (recomendada para Powerlevel10k)
            show_info "Descargando MesloLGS NF..."
            local fonts=(
                "MesloLGS%20NF%20Regular.ttf"
                "MesloLGS%20NF%20Bold.ttf"
                "MesloLGS%20NF%20Italic.ttf"
                "MesloLGS%20NF%20Bold%20Italic.ttf"
            )

            for font in "${fonts[@]}"; do
                local url="https://github.com/romkatv/powerlevel10k-media/raw/master/$font"
                local filename=$(echo "$font" | sed 's/%20/ /g')

                if [[ ! -f "$font_dir/$filename" ]]; then
                    show_info "Descargando $filename..."
                    sudo wget -q "$url" -O "$font_dir/$filename"
                fi
            done

            # Actualizar cache de fuentes
            show_info "Actualizando cache de fuentes..."
            sudo fc-cache -f -v

            show_success "✅ Fuentes instaladas correctamente"
            show_info "💡 Configura tu terminal para usar 'MesloLGS NF'"
            ;;
    esac

    show_success "Fuentes instaladas correctamente"

    # Recomendación final
    if [[ "$TERM_PROGRAM" == "Apple_Terminal" ]]; then
        show_warning "🚨 RECORDATORIO: Terminal.app no mostrará iconos correctamente"
        show_warning "   Para una experiencia completa, usa iTerm2"
    else
        show_info "💡 Configura tu terminal para usar 'MesloLGS NF' como fuente"
    fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# 🐚 FUNCIONES DE CONFIGURACIÓN DE ZSH
# ═══════════════════════════════════════════════════════════════════════════════

install_oh_my_zsh() {
    show_step "Instalando Oh My Zsh..."

    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        show_warning "Oh My Zsh ya está instalado"
        return 0
    fi

    # Descargar e instalar Oh My Zsh
    show_info "Descargando Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

    show_success "Oh My Zsh instalado correctamente"
}

install_powerlevel10k() {
    show_step "Instalando tema Powerlevel10k..."

    local p10k_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"

    if [[ -d "$p10k_dir" ]]; then
        show_warning "Powerlevel10k ya está instalado"
        return 0
    fi

    show_info "Clonando repositorio Powerlevel10k..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$p10k_dir"

    show_success "Powerlevel10k instalado correctamente"
}

install_zsh_plugins() {
    show_step "Instalando plugins de Zsh..."

    local custom_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

    # Lista de plugins a instalar
    local plugins=(
        "zsh-users/zsh-autosuggestions"
        "zsh-users/zsh-syntax-highlighting"
        "zsh-users/zsh-completions"
        "zsh-users/zsh-history-substring-search"
        "hlissner/zsh-autopair"
        "MichaelAquilina/zsh-you-should-use"
        "lukechilds/zsh-nvm"
    )

    for plugin in "${plugins[@]}"; do
        local plugin_name=$(basename "$plugin")
        local plugin_dir="$custom_dir/plugins/$plugin_name"

        if [[ -d "$plugin_dir" ]]; then
            show_info "Plugin $plugin_name ya está instalado"
            continue
        fi

        show_info "Instalando plugin $plugin_name..."
        git clone "https://github.com/$plugin.git" "$plugin_dir"
    done

    show_success "Plugins de Zsh instalados correctamente"
}

validate_plugin_sync() {
    show_step "Validando sincronización de plugins..."

    # Desactivar temporalmente set -u para manejar arrays vacíos
    set +u

    local zshrc_file="$HOME/.zshrc"
    local plugins_installed=()
    local plugins_in_zshrc=()

    # Obtener plugins instalados
    local custom_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
    if [[ -d "$custom_dir/plugins" ]]; then
        for plugin_dir in "$custom_dir/plugins"/*; do
            if [[ -d "$plugin_dir" ]]; then
                plugins_installed+=($(basename "$plugin_dir"))
            fi
        done
    fi

    # Obtener plugins en .zshrc usando método universal compatible
    if [[ -f "$zshrc_file" ]]; then
        # Extraer la sección de plugins usando sed (compatible con macOS y Linux)
        local plugins_section=$(sed -n '/plugins=(/,/)/p' "$zshrc_file" | sed '1d;$d')

        # Procesar cada línea para obtener los nombres de los plugins
        if [[ -n "$plugins_section" ]]; then
            while IFS= read -r plugin_line; do
                # Limpiar y extraer el nombre del plugin
                local plugin=$(echo "$plugin_line" | sed 's/[[:space:]()"]//g' | sed 's/#.*//g' | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')
                if [[ -n "$plugin" ]]; then
                    plugins_in_zshrc+=("$plugin")
                fi
            done <<< "$plugins_section"
        fi
    fi

    # Validar sincronización solo si hay plugins instalados
    local missing_plugins=()
    if [[ ${#plugins_installed[@]} -gt 0 ]]; then
        for plugin in "${plugins_installed[@]}"; do
            local found=false
            # Solo verificar si hay plugins en zshrc
            if [[ ${#plugins_in_zshrc[@]} -gt 0 ]]; then
                for zshrc_plugin in "${plugins_in_zshrc[@]}"; do
                    if [[ "$plugin" == "$zshrc_plugin" ]]; then
                        found=true
                        break
                    fi
                done
            fi
            if [[ "$found" == false ]]; then
                missing_plugins+=("$plugin")
            fi
        done
    fi

    # Mostrar resultados
    if [[ ${#missing_plugins[@]} -gt 0 ]]; then
        show_warning "Plugins instalados pero no configurados en .zshrc:"
        for plugin in "${missing_plugins[@]}"; do
            show_warning "  - $plugin"
        done
    else
        show_success "Todos los plugins están correctamente sincronizados"
    fi

    # Reactivar set -u
    set -u
}

# ═══════════════════════════════════════════════════════════════════════════════
# 🛠️ FUNCIONES DE HERRAMIENTAS ADICIONALES
# ═══════════════════════════════════════════════════════════════════════════════

install_additional_tools() {
    show_step "Instalando herramientas adicionales..."

    # Instalar NVM (Node Version Manager)
    if [[ ! -d "$HOME/.nvm" ]]; then
        show_info "Instalando NVM..."
        show_info "Obteniendo la última versión de NVM..."
        local LATEST_NVM_VERSION=$(curl -s "https://api.github.com/repos/nvm-sh/nvm/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

        if [[ -z "$LATEST_NVM_VERSION" ]]; then
            show_warning "No se pudo obtener la última versión, usando v0.39.7"
            LATEST_NVM_VERSION="v0.39.7"
        else
            show_info "Última versión encontrada: $LATEST_NVM_VERSION"
        fi

        curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/$LATEST_NVM_VERSION/install.sh" | bash

        # Cargar NVM para la sesión actual
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

        show_success "NVM instalado correctamente"
    else
        show_info "NVM ya está instalado"
    fi

    # Instalar herramientas específicas por sistema
    case "$PACKAGE_MANAGER" in
        "apt")
            show_info "Instalando herramientas adicionales (apt)..."

            # Instalar herramientas disponibles en apt
            sudo apt install -y \
                bat \
                fd-find \
                fzf \
                ripgrep \
                autojump \
                python3-pip

            # Crear enlaces simbólicos para compatibilidad
            sudo ln -sf /usr/bin/batcat /usr/local/bin/bat 2>/dev/null || true
            sudo ln -sf /usr/bin/fdfind /usr/local/bin/fd 2>/dev/null || true

            # Instalar eza manualmente desde GitHub
            show_info "Instalando eza desde GitHub..."
            if ! command -v eza &> /dev/null; then
                EZA_VERSION=$(curl -s https://api.github.com/repos/eza-community/eza/releases/latest | grep -Po '"tag_name": "v\K[^"]*')
                wget -O /tmp/eza.tar.gz "https://github.com/eza-community/eza/releases/latest/download/eza_x86_64-unknown-linux-gnu.tar.gz"
                sudo tar -xzf /tmp/eza.tar.gz -C /usr/local/bin/
                sudo chmod +x /usr/local/bin/eza
                rm /tmp/eza.tar.gz
                show_success "eza instalado correctamente"
            else
                show_info "eza ya está instalado"
            fi

            # Instalar thefuck via pip
            pip3 install --user thefuck
            ;;
        "brew")
            show_info "Instalando herramientas adicionales (brew)..."
            brew install \
                eza \
                bat \
                fd \
                fzf \
                ripgrep \
                autojump \
                thefuck
            ;;
    esac

    show_success "Herramientas adicionales instaladas"
}

# ═══════════════════════════════════════════════════════════════════════════════
# 📝 FUNCIONES DE CONFIGURACIÓN
# ═══════════════════════════════════════════════════════════════════════════════

apply_configurations() {
    show_step "Aplicando configuraciones personalizadas..."

    # Backup de configuraciones existentes
    local backup_dir="$HOME/.config/zsh-backup-$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$backup_dir"

    for config_file in ".zshrc" ".zsh_personal" ".p10k.zsh"; do
        if [[ -f "$HOME/$config_file" ]]; then
            show_info "Creando backup de $config_file..."
            cp "$HOME/$config_file" "$backup_dir/"
        fi
    done

    # Aplicar nuevas configuraciones
    show_info "Aplicando configuración .zshrc..."
    cp "$CONFIG_DIR/.zshrc" "$HOME/.zshrc"

    show_info "Aplicando configuración .zsh_personal..."
    cp "$CONFIG_DIR/.zsh_personal" "$HOME/.zsh_personal"

    show_info "Aplicando configuración .p10k.zsh..."
    cp "$CONFIG_DIR/.p10k.zsh" "$HOME/.p10k.zsh"

    # Ajustar permisos
    chmod 644 "$HOME/.zshrc" "$HOME/.zsh_personal" "$HOME/.p10k.zsh"

    show_success "Configuraciones aplicadas correctamente"
    show_info "Backup creado en: $backup_dir"
}

configure_shell() {
    show_step "Configurando Zsh como shell por defecto..."

    # Verificar si zsh ya es el shell por defecto
    if [[ "$SHELL" == *"zsh"* ]]; then
        show_success "Zsh ya es el shell por defecto"
        return 0
    fi

    # Obtener la ruta de zsh con fallback
    local zsh_path=$(which zsh 2>/dev/null || echo "/bin/zsh")

    # Verificar que zsh existe
    if [[ ! -x "$zsh_path" ]]; then
        show_error "No se encontró zsh en el sistema"
        return 1
    fi

    # Verificar según el sistema operativo
    case "$SYSTEM" in
        "macOS"|"Linux"|"WSL")
            # Agregar zsh a /etc/shells si no está (requiere sudo)
            if ! grep -q "$zsh_path" /etc/shells 2>/dev/null; then
                show_info "Agregando zsh a /etc/shells..."
                if ! echo "$zsh_path" | sudo tee -a /etc/shells >/dev/null 2>&1; then
                    show_warning "No se pudo agregar zsh a /etc/shells. Continuando..."
                fi
            fi

            # Intentar cambiar shell por defecto
            show_info "Cambiando shell por defecto a zsh..."
            show_warning "Se te solicitará tu contraseña si es necesario"

            if chsh -s "$zsh_path" 2>/dev/null; then
                show_success "✅ Shell cambiado a Zsh exitosamente"
                show_warning "⚠️ Cierra y reabre la terminal para aplicar los cambios"
            else
                show_warning "⚠️ No se pudo cambiar el shell automáticamente"
                show_info "💡 Opciones alternativas:"
                show_info "   1. Ejecuta manualmente: chsh -s $zsh_path"
                show_info "   2. O configura tu terminal para usar zsh por defecto"
                show_info "   3. En algunos sistemas, puedes necesitar privilegios adicionales"

                # Mostrar instrucciones específicas por sistema
                case "$SYSTEM" in
                    "macOS")
                        show_info "   • En macOS: System Preferences > Users & Groups > Advanced Options"
                        ;;
                    "WSL")
                        show_info "   • En WSL: Agrega 'zsh' al final de tu .bashrc"
                        ;;
                esac
            fi
            ;;
        *)
            show_info "ℹ️ Cambio de shell no implementado para $SYSTEM"
            show_info "   Por favor, configura manualmente tu terminal para usar zsh"
            ;;
    esac

    show_success "Configuración de shell completada"
}

install_argos_system() {
    show_step "Instalando sistema ARGOS..."

    # Determinar si necesitamos chafa
    local needs_chafa=true

    # Verificar si estamos en macOS y recomendar iTerm2
    if [[ "$SYSTEM" == "macOS" ]]; then
        show_info "🍎 Detectado macOS"

        # Verificar si ya estamos usando iTerm2
        if [[ "$TERM_PROGRAM" == "iTerm.app" ]]; then
            show_success "✅ iTerm2 detectado - soporte nativo de imágenes"
            show_info "   No se necesita chafa (mejor calidad con imágenes nativas)"
            needs_chafa=false
        else
            show_info "📱 Terminal por defecto detectado"
            show_info "   💡 Recomendación: iTerm2 ofrece mejor experiencia visual"
            show_info "   📥 Descarga: https://iterm2.com/"
            show_info "   🔧 Instalando chafa para Terminal.app..."
        fi
    else
        show_info "🐧 Sistema $SYSTEM - usando chafa para imágenes ASCII"
    fi

    # Instalar chafa solo si es necesario
    if [[ "$needs_chafa" == true ]]; then
        show_info "Instalando chafa (necesario para mostrar imágenes)..."
        case "$PACKAGE_MANAGER" in
            "apt")
                sudo apt install -y chafa
                ;;
            "brew")
                brew install chafa
                ;;
            "dnf")
                sudo dnf install -y chafa
                ;;
            "yum")
                sudo yum install -y chafa
                ;;
            *)
                show_warning "⚠️  Chafa debe instalarse manualmente:"
                show_warning "   Ubuntu/Debian: sudo apt install chafa"
                show_warning "   macOS: brew install chafa"
                show_warning "   Fedora: sudo dnf install chafa"
                ;;
        esac
    else
        show_success "🎉 Chafa no necesario - usando capacidades nativas del terminal"
    fi

    # Crear directorios necesarios
    show_info "Creando directorios para ARGOS..."
    mkdir -p "$HOME/.local/bin"
    mkdir -p "$HOME/.local/share/argos"
    mkdir -p "$HOME/.config/argos"

    # Copiar script portable
    show_info "Instalando script ARGOS adaptativo..."
    if [[ -f "$CONFIG_DIR/argos-fetch-portable" ]]; then
        cp "$CONFIG_DIR/argos-fetch-portable" "$HOME/.local/bin/argos-fetch"
        chmod +x "$HOME/.local/bin/argos-fetch"
    else
        show_error "Script argos-fetch-portable no encontrado en $CONFIG_DIR"
        return 1
    fi

    # Copiar imagen ARGOS específica según sistema
    show_info "Instalando imagen ARGOS específica para $SYSTEM..."

    # Determinar qué imagen usar según el sistema
    local image_source=""
    local image_name=""

    if [[ "$SYSTEM" == "macOS" ]]; then
        image_source="$CONFIG_DIR/loboMacOS.png"
        image_name="loboMacOS.png"
        show_info "🍎 Usando imagen específica para macOS: loboMacOS.png"
    else
        image_source="$CONFIG_DIR/Argos-FetchWU.png"
        image_name="Argos-FetchWU.png"
        show_info "🐧 Usando imagen para WSL/Linux: Argos-FetchWU.png"
    fi

    # Verificar que la imagen existe
    if [[ -f "$image_source" ]]; then
        # Copiar con nombre genérico para el script
        cp "$image_source" "$HOME/.local/share/argos/argos-image.png"
        cp "$image_source" "$HOME/.config/argos/argos-image.png"

        # Mantener también la imagen con su nombre original por compatibilidad
        cp "$image_source" "$HOME/.local/share/argos/$image_name"
        cp "$image_source" "$HOME/.config/argos/$image_name"

        show_success "✅ Imagen $image_name instalada correctamente"
    else
        show_error "❌ Imagen $image_name no encontrada en $CONFIG_DIR"
        return 1
    fi

    # Verificar que $HOME/.local/bin esté en PATH
    if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
        show_info "Agregando $HOME/.local/bin al PATH..."
        # Ya está en el .zshrc, pero por si acaso
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.zshrc" || true
    fi

    show_success "Sistema ARGOS instalado correctamente"

    # Resumen de configuración
    echo ""
    if [[ "$SYSTEM" == "macOS" ]]; then
        if [[ "$TERM_PROGRAM" == "iTerm.app" ]]; then
            show_success "� Configuración óptima: iTerm2 + imágenes nativas"
        else
            show_info "🎨 Configuración actual: Terminal.app + chafa"
            show_info "   💡 Para mejor experiencia: cambia a iTerm2"
        fi
    else
        show_info "🎨 Configuración: Terminal estándar + chafa"
    fi

    show_info "Ejecuta 'argos-fetch' para probar el sistema"
}

validate_complete_installation() {
    show_step "Validando instalación completa..."

    local validation_errors=()

    # Verificar Zsh
    if ! command -v zsh &> /dev/null; then
        validation_errors+=("Zsh no está instalado")
    fi

    # Verificar Oh My Zsh
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        validation_errors+=("Oh My Zsh no está instalado")
    fi

    # Verificar Powerlevel10k
    if [[ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]]; then
        validation_errors+=("Powerlevel10k no está instalado")
    fi

    # Verificar NVM
    if [[ ! -d "$HOME/.nvm" ]]; then
        validation_errors+=("NVM no está instalado")
    fi

    # Verificar ARGOS
    if [[ ! -x "$HOME/.local/bin/argos-fetch" ]]; then
        validation_errors+=("ARGOS no está instalado")
    fi

    if [[ ! -f "$HOME/.local/share/argos/Argos-FetchWU.png" ]]; then
        validation_errors+=("Imagen ARGOS no está instalada")
    fi

    # Verificar chafa (solo si es necesario según el terminal)
    local chafa_needed=true
    if [[ "$SYSTEM" == "macOS" ]] && [[ "$TERM_PROGRAM" == "iTerm.app" ]]; then
        chafa_needed=false
    fi

    if [[ "$chafa_needed" == true ]] && ! command -v chafa &> /dev/null; then
        validation_errors+=("Chafa no está instalado (necesario para terminales que no son iTerm2)")
    fi

    # Verificar archivos de configuración
    local config_files=(".zshrc" ".zsh_personal" ".p10k.zsh")
    for config_file in "${config_files[@]}"; do
        if [[ ! -f "$HOME/$config_file" ]]; then
            validation_errors+=("$config_file no está en el directorio home")
        fi
    done

    # Mostrar resultados
    if [[ ${#validation_errors[@]} -gt 0 ]]; then
        show_error "Problemas encontrados en la instalación:"
        for error in "${validation_errors[@]}"; do
            show_error "  - $error"
        done
        return 1
    else
        show_success "¡Instalación completada exitosamente!"
        show_success "Todos los componentes están correctamente instalados"
        return 0
    fi
}

detect_terminal_capabilities() {
    show_step "Detectando capacidades del terminal..."

    # Información básica del terminal
    show_info "Terminal actual: ${TERM_PROGRAM:-Terminal estándar}"

    # Capacidades específicas
    case "$TERM_PROGRAM" in
        "iTerm.app")
            show_success "✅ iTerm2 detectado - Configuración ÓPTIMA"
            show_info "   🎨 Soporte nativo de imágenes"
            show_info "   🌈 Colores de 24 bits (true color)"
            show_info "   🔤 Unicode completo + Nerd Font"
            show_info "   ⚡ Powerlevel10k funcionará perfectamente"
            show_info "   🎯 Mejor rendimiento visual"
            echo ""
            ;;
        "Apple_Terminal")
            show_warning "📱 Terminal.app detectado - Limitaciones importantes"
            show_warning "   ❌ Unicode limitado (iconos rotos)"
            show_warning "   ❌ Powerlevel10k se verá mal"
            show_warning "   ❌ Nerd Font no funciona correctamente"
            show_warning "   🔤 Solo imágenes ASCII (chafa)"
            show_warning "   🎨 Colores limitados"
            echo ""
            show_info "💡 RECOMENDACIÓN FUERTE: Actualizar a iTerm2"
            show_info "   📥 Descarga: https://iterm2.com/"
            show_info "   🎯 Mejora dramática en experiencia visual"
            echo ""
            ;;
        "vscode")
            show_info "💻 Terminal de VS Code detectado"
            show_info "   🔤 Unicode básico (puede tener problemas)"
            show_info "   🎨 Colores limitados"
            show_info "   ⚠️ Powerlevel10k puede verse subóptimo"
            show_info "   🔧 Imágenes vía ASCII art (chafa)"
            echo ""
            ;;
        *)
            if [[ -n "${WSL_DISTRO_NAME:-}" ]]; then
                show_info "🐧 Terminal WSL detectado"
                show_info "   🔤 Unicode depende de Windows Terminal"
                show_info "   🎨 Colores dependen del host"
                show_info "   💡 Recomendación: Windows Terminal"
                show_info "   🔧 Imágenes vía ASCII art (chafa)"
            else
                show_info "🖥️  Terminal estándar detectado"
                show_info "   🔤 Unicode básico"
                show_info "   🎨 Colores estándar"
                show_info "   🔧 Imágenes vía ASCII art (chafa)"
            fi
            echo ""
            ;;
    esac

    # Verificar soporte específico de fuentes
    if [[ "$TERM_PROGRAM" == "Apple_Terminal" ]]; then
        show_warning "⚠️ ADVERTENCIA: Terminal.app + Nerd Font = Problemas visuales"
        show_warning "   Los iconos aparecerán como cuadrados □ □ □"
        show_warning "   Powerlevel10k no funcionará correctamente"
        show_warning "   La experiencia será subóptima"
    fi

    # Verificar soporte de colores
    if [[ "$COLORTERM" == "truecolor" ]] || [[ "$COLORTERM" == "24bit" ]]; then
        show_success "✅ Soporte de colores de 24 bits"
    else
        show_info "🎨 Soporte de colores básico (puede afectar P10k)"
    fi
}

show_installation_summary() {
    echo ""
    show_step "📊 Resumen de instalación por sistema:"
    echo ""

    # Tabla de componentes instalados
    printf "%-25s %-10s %-15s %-20s\n" "Componente" "Estado" "Método" "Observaciones"
    printf "%-25s %-10s %-15s %-20s\n" "─────────────────────────" "──────" "─────────────" "────────────────"

    # Zsh
    if command -v zsh &> /dev/null; then
        printf "%-25s %-10s %-15s %-20s\n" "Zsh Shell" "✅ Instalado" "$PACKAGE_MANAGER" "Shell por defecto"
    fi

    # Oh My Zsh
    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        printf "%-25s %-10s %-15s %-20s\n" "Oh My Zsh" "✅ Instalado" "Script oficial" "Framework base"
    fi

    # Powerlevel10k
    if [[ -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]]; then
        printf "%-25s %-10s %-15s %-20s\n" "Powerlevel10k" "✅ Instalado" "Git clone" "Tema principal"
    fi

    # NVM
    if [[ -d "$HOME/.nvm" ]]; then
        printf "%-25s %-10s %-15s %-20s\n" "Node Version Manager" "✅ Instalado" "Script oficial" "Gestión de Node.js"
    fi

    # Chafa (condicional)
    if command -v chafa &> /dev/null; then
        printf "%-25s %-10s %-15s %-20s\n" "Chafa" "✅ Instalado" "$PACKAGE_MANAGER" "Imágenes ASCII"
    elif [[ "$SYSTEM" == "macOS" ]] && [[ "$TERM_PROGRAM" == "iTerm.app" ]]; then
        printf "%-25s %-10s %-15s %-20s\n" "Chafa" "⏭️ Omitido" "No necesario" "iTerm2 nativo"
    else
        printf "%-25s %-10s %-15s %-20s\n" "Chafa" "❌ Faltante" "Manual" "Instalar manualmente"
    fi

    # ARGOS
    if [[ -x "$HOME/.local/bin/argos-fetch" ]]; then
        local argos_method="Script portable"
        if [[ "$SYSTEM" == "macOS" ]] && [[ "$TERM_PROGRAM" == "iTerm.app" ]]; then
            argos_method="iTerm2 nativo"
        fi
        printf "%-25s %-10s %-15s %-20s\n" "Sistema ARGOS" "✅ Instalado" "$argos_method" "Bienvenida visual"
    fi

    echo ""
}

# ═══════════════════════════════════════════════════════════════════════════════
# 🔄 FUNCIÓN PARA OFRECER VOLVER AL MENÚ PRINCIPAL
# ═══════════════════════════════════════════════════════════════════════════════

offer_return_to_main_menu() {
    echo ""
    echo -e "${CYAN}🎯 CONTINUAR CON CONFIGURACIÓN${NC}"
    echo "═══════════════════════════════════════════════════════════════"
    echo -e "${BLUE}¿Deseas continuar con más configuraciones?${NC}"
    echo ""
    echo -e "${YELLOW}Opciones disponibles:${NC}"
    echo "• Configurar Git (usuario/email)"
    echo "• Instalar extensiones de VS Code"
    echo "• Instalar herramientas npm"
    echo "• Verificar estado del sistema"
    echo "• Ver ayuda y documentación"
    echo ""

    while true; do
        read -p "¿Abrir menú principal del setup? (s/n): " menu_choice
        case $menu_choice in
            [Ss]|[Yy]|[Ss][Ii]|[Yy][Ee][Ss])
                echo ""
                echo -e "${CYAN}🚀 Abriendo menú principal...${NC}"
                echo ""

                # Buscar el script install.sh
                local install_script="$(dirname "$(dirname "${BASH_SOURCE[0]}")")/install.sh"

                if [[ -f "$install_script" ]]; then
                    # Ejecutar el script principal
                    exec bash "$install_script"
                else
                    show_error "No se encontró el script install.sh en: $install_script"
                    echo -e "${BLUE}ℹ️  Puedes ejecutar manualmente: ./install.sh${NC}"
                fi
                break
                ;;
            [Nn]|[Nn][Oo])
                echo ""
                echo -e "${GREEN}✅ ¡Configuración del terminal completada!${NC}"
                echo -e "${BLUE}ℹ️  Puedes ejecutar más tarde: ./install.sh${NC}"
                echo -e "${YELLOW}⚡ Recuerda reiniciar tu terminal para aplicar todos los cambios${NC}"
                break
                ;;
            *)
                echo -e "${RED}❌ Respuesta inválida. Por favor responde 's' o 'n'${NC}"
                ;;
        esac
    done
}

# ═══════════════════════════════════════════════════════════════════════════════
# 🍎 FUNCIÓN PARA VERIFICAR Y OFRECER iTerm2 EN macOS
# ═══════════════════════════════════════════════════════════════════════════════

check_and_offer_iterm2() {
    # Solo ejecutar en macOS
    if [[ "$SYSTEM" != "macOS" ]]; then
        return 0
    fi

    # Verificar si iTerm2 ya está instalado
    if [[ "$TERM_PROGRAM" == "iTerm.app" ]]; then
        show_success "✅ iTerm2 ya está instalado y activo"
        return 0
    fi

    # Verificar si iTerm2 está instalado pero no activo
    if [[ -d "/Applications/iTerm.app" ]]; then
        show_info "📱 iTerm2 está instalado pero no activo"
        show_info "💡 Puedes abrirlo desde /Applications/iTerm.app"
        return 0
    fi

    # iTerm2 no está instalado - ofrecer instalación
    echo ""
    show_warning "⚠️ ADVERTENCIA: Terminal.app detectado"
    show_warning "   La experiencia visual será SUBÓPTIMA con esta configuración:"
    show_warning "   ❌ Nerd Font no funcionará correctamente"
    show_warning "   ❌ Powerlevel10k mostrará iconos rotos (□□□)"
    show_warning "   ❌ Colores limitados"
    show_warning "   ❌ Unicode limitado"
    echo ""
    show_info "🚀 SOLUCIÓN RECOMENDADA: Instalar iTerm2"
    show_info "   ✅ Soporte completo de Nerd Font"
    show_info "   ✅ Powerlevel10k funcionará perfectamente"
    show_info "   ✅ Colores de 24 bits"
    show_info "   ✅ Unicode completo"
    show_info "   ✅ Mejor rendimiento"
    echo ""

    # Preguntar al usuario
    echo -n "¿Quieres instalar iTerm2 ahora? (S/n): "
    read -r response

    case "$response" in
        ""|"s"|"S"|"y"|"Y"|"yes"|"Yes"|"YES"|"sí"|"Sí"|"SÍ")
            show_step "Instalando iTerm2..."

            # Verificar si Homebrew está instalado
            if ! command -v brew &> /dev/null; then
                show_info "📦 Homebrew no está instalado. Instalando Homebrew primero..."
                if ! /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
                    show_error "❌ Error al instalar Homebrew"
                    show_warning "Por favor, instala iTerm2 manualmente desde https://iterm2.com/"
                    return 1
                fi
            fi

            # Instalar iTerm2
            if brew install --cask iterm2; then
                show_success "✅ iTerm2 instalado exitosamente"
                echo ""
                show_info "🔄 REINICIO NECESARIO:"
                show_info "1. Cierra esta terminal"
                show_info "2. Abre iTerm2 desde /Applications/iTerm.app"
                show_info "3. Ejecuta este script nuevamente"
                show_info "4. ¡Disfruta de la experiencia mejorada!"
                echo ""
                show_warning "⚠️ Por favor, reinicia usando iTerm2 para continuar"
                exit 0
            else
                show_error "❌ Error al instalar iTerm2"
                show_warning "Por favor, instala iTerm2 manualmente desde https://iterm2.com/"
                return 1
            fi
            ;;
        *)
            show_warning "⚠️ Continuando con Terminal.app"
            show_warning "   La experiencia visual será limitada"
            show_warning "   Puedes instalar iTerm2 más tarde desde https://iterm2.com/"
            echo ""
            return 0
            ;;
    esac
}

# ═══════════════════════════════════════════════════════════════════════════════
# 🚀 FUNCIÓN PRINCIPAL
# ═══════════════════════════════════════════════════════════════════════════════

main() {
    show_banner

    # Detectar sistema
    detect_system

    # Verificar y ofrecer instalación de iTerm2 en macOS
    check_and_offer_iterm2

    # Detectar capacidades del terminal
    detect_terminal_capabilities

    # Verificar archivos de configuración
    if ! check_config_files; then
        exit 1
    fi

    # Procesos de instalación
    show_step "Iniciando configuración completa del terminal..."

    # 1. Instalar dependencias
    install_dependencies

    # 2. Instalar fuentes
    install_fonts

    # 3. Instalar Oh My Zsh
    install_oh_my_zsh

    # 4. Instalar Powerlevel10k
    install_powerlevel10k

    # 5. Instalar plugins
    install_zsh_plugins

    # 6. Instalar herramientas adicionales
    install_additional_tools

    # 7. Instalar sistema ARGOS
    install_argos_system

    # 8. Aplicar configuraciones
    apply_configurations

    # 9. Validar sincronización de plugins
    validate_plugin_sync

    # 10. Configurar shell por defecto
    configure_shell

    # 11. Validación final
    validate_complete_installation

    # 12. Mostrar resumen de instalación
    show_installation_summary

    # Resumen final
    echo ""
    show_success "🎉 ¡Configuración del terminal completada!"
    echo ""
    show_info "📋 CONFIGURACIÓN APLICADA:"
    show_info "• Zsh como shell por defecto"
    show_info "• Oh My Zsh instalado"
    show_info "• Tema Powerlevel10k configurado"
    show_info "• Plugins esenciales instalados y sincronizados"
    show_info "• Fuentes Nerd Font instaladas"
    show_info "• Configuraciones personalizadas aplicadas"
    show_info "• NVM y herramientas adicionales instaladas"
    show_info "• Sistema ARGOS instalado y configurado"
    show_info "• Validación de plugins completada"
    echo ""
    show_info "🚀 PRÓXIMOS PASOS:"
    show_info "1. Cierra y reabre la terminal"
    show_info "2. Configura tu terminal para usar la fuente 'MesloLGS NF'"
    show_info "3. Ejecuta 'p10k configure' si quieres personalizar el tema"
    show_info "4. Ejecuta 'argos-fetch' para probar el sistema de bienvenida"
    show_info "5. ¡Disfruta de tu terminal mejorado!"
    echo ""

    # Información específica por sistema
    case "$SYSTEM" in
        "WSL")
            show_info "💡 ESPECÍFICO PARA WSL:"
            show_info "• Configura Windows Terminal para usar 'MesloLGS NF'"
            show_info "• Asegúrate de que VS Code use WSL como terminal por defecto"
            show_info "• ARGOS usa chafa para imágenes ASCII"
            show_info "• Powerlevel10k funcionará correctamente"
            ;;
        "macOS")
            show_info "💡 ESPECÍFICO PARA macOS:"
            if [[ "$TERM_PROGRAM" == "iTerm.app" ]]; then
                show_success "• ✅ iTerm2 configurado - experiencia ÓPTIMA"
                show_success "• ✅ Fuente 'MesloLGS NF' funcionará perfectamente"
                show_success "• ✅ Powerlevel10k se verá perfecto"
                show_success "• ✅ ARGOS usará imágenes nativas"
            else
                show_warning "• ⚠️ Terminal.app detectado - experiencia SUBÓPTIMA"
                show_warning "• ⚠️ Nerd Font no funcionará correctamente"
                show_warning "• ⚠️ Powerlevel10k se verá roto (iconos = □□□)"
                show_warning "• ⚠️ ARGOS usará ASCII art básico"
                echo ""
                show_info "🚨 RECOMENDACIÓN FUERTE: Actualizar a iTerm2"
                show_info "   📥 Descarga: https://iterm2.com/"
                show_info "   🎯 Mejora dramática en experiencia visual"
            fi
            ;;
        "Linux")
            show_info "💡 ESPECÍFICO PARA LINUX:"
            show_info "• Configura tu terminal para usar 'MesloLGS NF'"
            show_info "• ARGOS usa chafa para imágenes ASCII"
            show_info "• Powerlevel10k funcionará correctamente"
            ;;
    esac

    # Resumen de instalación
    show_installation_summary

    # Ofrecer continuar con más configuraciones
    offer_return_to_main_menu
}

# ═══════════════════════════════════════════════════════════════════════════════
# 🚀 PUNTO DE ENTRADA
# ═══════════════════════════════════════════════════════════════════════════════

# Ejecutar función principal
main "$@"
