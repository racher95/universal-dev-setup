#!/bin/bash

# 🌍 Script Universal de Configuración VS Code + Terminal
# Compatible con: macOS (nativo) + Windows WSL (Ubuntu)
# Versión: 2.0 - Configuración inteligente según el sistema

echo "🌍 CONFIGURACIÓN UNIVERSAL DE DESARROLLO"
echo "========================================"
echo ""

# === DETECCIÓN DE SISTEMA ===
OS_TYPE="$(uname)"

# Función para detectar WSL con múltiples métodos
detect_wsl() {
    # Método 1: Variable de entorno WSL
    if [[ -n "${WSL_DISTRO_NAME}" ]]; then
        return 0
    fi
    
    # Método 2: /proc/version contiene "microsoft"
    if [[ -f "/proc/version" ]] && grep -qi "microsoft" /proc/version; then
        return 0
    fi
    
    # Método 3: /proc/sys/kernel/osrelease contiene "WSL"
    if [[ -f "/proc/sys/kernel/osrelease" ]] && grep -qi "wsl\|microsoft" /proc/sys/kernel/osrelease; then
        return 0
    fi
    
    # Método 4: Variable WSLENV existe
    if [[ -n "${WSLENV}" ]]; then
        return 0
    fi
    
    return 1
}

if [[ "$OS_TYPE" == "Darwin" ]]; then
    SYSTEM="macOS"
    echo "🍎 Sistema detectado: macOS (nativo)"
elif [[ "$OS_TYPE" == "Linux" ]] && detect_wsl; then
    SYSTEM="WSL"
    DISTRO_NAME="${WSL_DISTRO_NAME:-WSL}"
    echo "🐧 Sistema detectado: Linux WSL (${DISTRO_NAME})"
elif [[ "$OS_TYPE" == "Linux" ]]; then
    SYSTEM="Linux"
    echo "🐧 Sistema detectado: Linux nativo"
else
    echo "❌ Sistema no soportado: $OS_TYPE"
    exit 1
fi

# === COLORES ===
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

# === FUNCIONES DE UTILIDAD ===
show_status() { echo -e "${GREEN}✅ $1${NC}"; }
show_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
show_error() { echo -e "${RED}❌ $1${NC}"; }
show_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
show_step() { echo -e "${PURPLE}🔧 $1${NC}"; }

# === CONFIGURACIÓN DE RUTAS SEGÚN SISTEMA ===
setup_paths() {
    if [[ "$SYSTEM" == "macOS" ]]; then
        VSCODE_SETTINGS_DIR="$HOME/Library/Application Support/Code/User"
        FONT_DIR="$HOME/Library/Fonts"
        PACKAGE_MANAGER="brew"
    elif [[ "$SYSTEM" == "WSL" ]]; then
        # VS Code en Windows accesible desde WSL
        WINDOWS_USER=$(cmd.exe /C "echo %USERNAME%" 2>/dev/null | tr -d '\r\n')
        VSCODE_SETTINGS_DIR="/mnt/c/Users/${WINDOWS_USER}/AppData/Roaming/Code/User"
        FONT_DIR="/usr/local/share/fonts"
        PACKAGE_MANAGER="apt"
    else
        VSCODE_SETTINGS_DIR="$HOME/.config/Code/User"
        FONT_DIR="/usr/local/share/fonts"
        PACKAGE_MANAGER="apt"
    fi

    show_info "Rutas configuradas para $SYSTEM"
    show_info "VS Code: $VSCODE_SETTINGS_DIR"
    show_info "Fuentes: $FONT_DIR"
}

# === INSTALACIÓN DE DEPENDENCIAS BASE ===
install_base_dependencies() {
    show_step "Instalando dependencias base..."

    if [[ "$SYSTEM" == "macOS" ]]; then
        # Verificar si Homebrew está instalado
        if ! command -v brew &> /dev/null; then
            show_info "Instalando Homebrew..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        fi

        # Instalar herramientas base
        brew install git curl wget node npm

    elif [[ "$SYSTEM" == "WSL" || "$SYSTEM" == "Linux" ]]; then
        # Actualizar repositorios
        sudo apt update && sudo apt upgrade -y

        # Instalar herramientas base
        sudo apt install -y git curl wget build-essential fontconfig unzip

        # Instalar Node.js via NodeSource si no está instalado
        if ! command -v node &> /dev/null; then
            curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
            sudo apt install -y nodejs
        fi
    fi

    show_status "Dependencias base instaladas"
}

# === INSTALACIÓN DE FUENTES ===
install_fonts() {
    show_step "Instalando fuentes de desarrollo..."

    if [[ "$SYSTEM" == "macOS" ]]; then
        # Usar Homebrew Cask para fuentes en macOS
        brew tap homebrew/cask-fonts

        # Instalar fuentes
        fonts=(
            "font-fira-code"
            "font-jetbrains-mono"
            "font-cascadia-code"
            "font-meslo-lg-nerd-font"
        )

        for font in "${fonts[@]}"; do
            if ! brew list --cask | grep -q "$font"; then
                show_info "Instalando $font..."
                brew install --cask "$font"
            else
                show_warning "$font ya está instalada"
            fi
        done

    else
        # Linux/WSL - Descarga manual
        mkdir -p "$FONT_DIR"
        cd /tmp

        # Fira Code
        if [ ! -f "$FONT_DIR/FiraCode-Regular.ttf" ]; then
            show_info "Instalando Fira Code..."
            wget https://github.com/tonsky/FiraCode/releases/download/6.2/Fira_Code_v6.2.zip
            unzip -q Fira_Code_v6.2.zip
            sudo cp ttf/*.ttf "$FONT_DIR/"
            rm -rf Fira_Code_v6.2.zip ttf/ variable_ttf/
        fi

        # JetBrains Mono
        if [ ! -f "$FONT_DIR/JetBrainsMono-Regular.ttf" ]; then
            show_info "Instalando JetBrains Mono..."
            wget https://github.com/JetBrains/JetBrainsMono/releases/download/v2.304/JetBrainsMono-2.304.zip
            unzip -q JetBrainsMono-2.304.zip
            sudo cp fonts/ttf/*.ttf "$FONT_DIR/"
            rm -rf JetBrainsMono-2.304.zip fonts/
        fi

        # Cascadia Code
        if [ ! -f "$FONT_DIR/CascadiaCode-Regular.ttf" ]; then
            show_info "Instalando Cascadia Code..."
            wget https://github.com/microsoft/cascadia-code/releases/download/v2111.01/CascadiaCode-2111.01.zip
            unzip -q CascadiaCode-2111.01.zip
            sudo cp ttf/*.ttf "$FONT_DIR/"
            rm -rf CascadiaCode-2111.01.zip ttf/
        fi

        # MesloLGS Nerd Font
        if [ ! -f "$FONT_DIR/MesloLGS NF Regular.ttf" ]; then
            show_info "Instalando MesloLGS Nerd Font..."
            wget https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf
            wget https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf
            wget https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf
            wget https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf
            sudo cp "MesloLGS NF"*.ttf "$FONT_DIR/"
            rm -f "MesloLGS NF"*.ttf
        fi

        # Actualizar cache
        sudo fc-cache -f -v
    fi

    show_status "Fuentes instaladas correctamente"
}

# === INSTALACIÓN DE EXTENSIONES VS CODE ===
install_vscode_extensions() {
    show_step "Instalando extensiones de VS Code..."

    # Verificar que VS Code está instalado
    if ! command -v code &> /dev/null; then
        if [[ "$SYSTEM" == "macOS" ]]; then
            show_warning "VS Code no encontrado. Instálalo desde: https://code.visualstudio.com/"
        elif [[ "$SYSTEM" == "WSL" ]]; then
            show_warning "VS Code no encontrado en PATH. Asegúrate de que esté instalado en Windows."
        fi
        return
    fi

    # Lista de extensiones esenciales
    extensions=(
        # Esenciales
        "esbenp.prettier-vscode"
        "dbaeumer.vscode-eslint"
        "pkief.material-icon-theme"
        "zhuangtongfa.material-theme"

        # Desarrollo web
        "ritwickdey.liveserver"
        "formulahendry.auto-rename-tag"
        "christian-kohler.path-intellisense"
        "bradlc.vscode-tailwindcss"

        # JavaScript/TypeScript
        "ms-vscode.vscode-typescript-next"

        # Git
        "eamodio.gitlens"
        "mhutchie.git-graph"

        # Colaboración
        "ms-vsliveshare.vsliveshare"
        "ms-vsliveshare.vsliveshare-audio"

        # Utilidades
        "usernamehw.errorlens"
        "streetsidesoftware.code-spell-checker"
        "gruntfuggly.todo-tree"
    )

    # Agregar extensiones específicas según el sistema
    if [[ "$SYSTEM" == "WSL" ]]; then
        # Las extensiones Remote se instalan automáticamente desde Windows
        show_info "Extensiones Remote se gestionan desde Windows VS Code"
    fi

    # Instalar extensiones
    for ext in "${extensions[@]}"; do
        if ! code --list-extensions | grep -q "^$ext$"; then
            show_info "Instalando $ext..."
            code --install-extension "$ext"
        else
            show_warning "$ext ya está instalada"
        fi
    done

    show_status "Extensiones instaladas"
}

# === CONFIGURACIÓN DE SETTINGS.JSON ===
configure_vscode_settings() {
    show_step "Configurando VS Code settings.json..."

    # Crear directorio si no existe
    mkdir -p "$VSCODE_SETTINGS_DIR"

    # Verificar si el directorio es accesible
    if [ ! -w "$VSCODE_SETTINGS_DIR" ]; then
        show_error "No se puede escribir en: $VSCODE_SETTINGS_DIR"
        show_info "Configuración manual requerida"
        return
    fi

    # Crear backup si existe configuración previa
    if [ -f "$VSCODE_SETTINGS_DIR/settings.json" ]; then
        cp "$VSCODE_SETTINGS_DIR/settings.json" "$VSCODE_SETTINGS_DIR/settings.json.backup.$(date +%Y%m%d_%H%M%S)"
        show_warning "Backup creado de configuración existente"
    fi

    # Configuración universal
    cat > "$VSCODE_SETTINGS_DIR/settings.json" << 'EOF'
{
  "workbench.iconTheme": "material-icon-theme",
  "workbench.colorTheme": "One Dark Pro",
  "workbench.startupEditor": "none",
  "workbench.editor.enablePreview": false,
  "workbench.editor.closeOnFileDelete": true,

  // === EDITOR CONFIGURATION ===
  "editor.fontFamily": "'Fira Code', 'JetBrains Mono', 'Cascadia Code', 'SF Mono', 'Monaco', 'Inconsolata', 'Consolas', 'Droid Sans Mono', 'monospace'",
  "editor.fontLigatures": true,
  "editor.fontSize": 14,
  "editor.lineHeight": 1.6,
  "editor.linkedEditing": true,
  "editor.fontVariations": true,
  "editor.cursorBlinking": "smooth",
  "editor.cursorSmoothCaretAnimation": "on",
  "editor.smoothScrolling": true,
  "editor.minimap.enabled": true,
  "editor.minimap.showSlider": "always",
  "editor.wordWrap": "on",
  "editor.rulers": [80, 120],
  "editor.tabSize": 2,
  "editor.insertSpaces": true,
  "editor.detectIndentation": true,
  "editor.renderWhitespace": "boundary",
  "editor.bracketPairColorization.enabled": true,
  "editor.guides.bracketPairs": "active",
  "editor.inlineSuggest.enabled": true,
  "editor.suggestSelection": "first",
  "editor.acceptSuggestionOnEnter": "smart",

  // === FORMATTING ===
  "editor.formatOnSave": true,
  "editor.formatOnPaste": true,
  "editor.formatOnType": true,
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "editor.formatOnSaveMode": "file",
  "editor.codeActionsOnSave": {
    "source.organizeImports": "explicit",
    "source.fixAll.eslint": "explicit"
  },

  // === PRETTIER CONFIG ===
  "prettier.singleQuote": true,
  "prettier.trailingComma": "es5",
  "prettier.semi": false,
  "prettier.tabWidth": 2,
  "prettier.useTabs": false,
  "prettier.printWidth": 80,
  "prettier.bracketSpacing": true,
  "prettier.arrowParens": "avoid",

  // === LANGUAGE SPECIFIC ===
  "[javascript]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode",
    "editor.codeActionsOnSave": {
      "source.organizeImports": "explicit",
      "source.fixAll.eslint": "explicit"
    }
  },
  "[typescript]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode",
    "editor.codeActionsOnSave": {
      "source.organizeImports": "explicit",
      "source.fixAll.eslint": "explicit"
    }
  },
  "[html]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode",
    "editor.linkedEditing": true
  },
  "[css]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode",
    "editor.suggest.insertMode": "replace"
  },
  "[scss]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[json]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[jsonc]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },

  // === FILES ===
  "files.autoSave": "afterDelay",
  "files.autoSaveDelay": 1000,
  "files.trimTrailingWhitespace": true,
  "files.insertFinalNewline": true,
  "files.trimFinalNewlines": true,
  "files.exclude": {
    "**/.git": true,
    "**/.DS_Store": true,
    "**/node_modules": true,
    "**/dist": true,
    "**/build": true,
    "**/.next": true,
    "**/.nuxt": true,
    "**/coverage": true
  },

  // === EMMET ===
  "emmet.includeLanguages": {
    "javascript": "javascriptreact",
    "typescript": "typescriptreact",
    "vue-html": "html"
  },
  "emmet.triggerExpansionOnTab": true,
  "emmet.showExpandedAbbreviation": "always",

  // === TERMINAL ===
  "terminal.integrated.fontFamily": "MesloLGS Nerd Font, SF Mono, Monaco, Consolas",
  "terminal.integrated.fontSize": 13,
  "terminal.integrated.lineHeight": 1.4,
  "terminal.integrated.cursorBlinking": true,
  "terminal.integrated.cursorStyle": "line",
  "terminal.integrated.copyOnSelection": true,
  "terminal.integrated.rightClickBehavior": "copyPaste",

  // === SECURITY & TRUST ===
  "security.workspace.trust.untrustedFiles": "open",

  // === EXTENSIONS ===
  "redhat.telemetry.enabled": false,
  "github.copilot.nextEditSuggestions.enabled": true,
  "github.copilot.enable": {
    "*": true,
    "yaml": false,
    "plaintext": false
  },

  // === HTML & CSS ===
  "html.autoClosingTags": true,
  "html.autoCreateQuotes": true,
  "html.completion.attributeDefaultValue": "doublequotes",
  "css.validate": true,
  "scss.validate": true,
  "less.validate": true,

  // === JAVASCRIPT & TYPESCRIPT ===
  "javascript.validate.enable": true,
  "javascript.format.enable": true,
  "typescript.validate.enable": true,
  "typescript.format.enable": true,
  "typescript.preferences.quoteStyle": "single",
  "javascript.preferences.quoteStyle": "single",
  "typescript.suggest.autoImports": true,
  "javascript.suggest.autoImports": true,
  "typescript.updateImportsOnFileMove.enabled": "always",
  "javascript.updateImportsOnFileMove.enabled": "always",

  // === LIVE SERVER ===
  "liveServer.settings.donotVerifyTags": true,
  "liveServer.settings.donotShowInfoMsg": true,
  "liveServer.settings.CustomBrowser": "chrome",
  "liveServer.settings.port": 5500,
  "liveServer.settings.host": "localhost",

  // === EXPLORER ===
  "explorer.confirmDelete": false,
  "explorer.confirmDragAndDrop": false,
  "explorer.compactFolders": false,
  "explorer.sortOrder": "type",

  // === SEARCH ===
  "search.exclude": {
    "**/node_modules": true,
    "**/dist": true,
    "**/build": true,
    "**/.next": true,
    "**/.nuxt": true,
    "**/coverage": true,
    "**/.git": true
  },

  // === PERFORMANCE ===
  "extensions.ignoreRecommendations": false,
  "telemetry.telemetryLevel": "off",
  "update.mode": "manual"
}
EOF

    # Agregar configuraciones específicas según el sistema
    if [[ "$SYSTEM" == "WSL" ]]; then
        # Agregar configuraciones específicas de WSL
        cat >> "$VSCODE_SETTINGS_DIR/settings.json.tmp" << 'EOF'
,
  // === WSL SPECIFIC ===
  "security.allowedUNCHosts": ["wsl.localhost", "wsl$"],
  "remote.WSL.fileWatcher.polling": true,
  "terminal.integrated.defaultProfile.windows": "Ubuntu (WSL)",
  "terminal.integrated.profiles.windows": {
    "Ubuntu (WSL)": {
      "path": "C:\\Windows\\System32\\wsl.exe",
      "args": ["-d", "Ubuntu"]
    }
  }
}
EOF
        # Combinar archivos (remover la última llave y agregar configuraciones WSL)
        head -n -1 "$VSCODE_SETTINGS_DIR/settings.json" > "$VSCODE_SETTINGS_DIR/settings.tmp"
        cat "$VSCODE_SETTINGS_DIR/settings.json.tmp" >> "$VSCODE_SETTINGS_DIR/settings.tmp"
        mv "$VSCODE_SETTINGS_DIR/settings.tmp" "$VSCODE_SETTINGS_DIR/settings.json"
        rm -f "$VSCODE_SETTINGS_DIR/settings.json.tmp"
    fi

    show_status "Settings.json configurado para $SYSTEM"
}

# === INSTALACIÓN DE HERRAMIENTAS NPM ===
install_npm_tools() {
    show_step "Instalando herramientas de desarrollo..."

    if command -v npm &> /dev/null; then
        npm install -g live-server prettier eslint typescript @typescript-eslint/parser @typescript-eslint/eslint-plugin npm-check-updates
        show_status "Herramientas npm instaladas"
    else
        show_warning "npm no está disponible"
    fi
}

# === MENÚ PRINCIPAL ===
show_menu() {
    echo ""
    echo "🎯 Selecciona qué configurar:"
    echo "=========================="
    echo "1. 🔍 Verificar estado actual"
    echo "2. 🚀 Instalación completa"
    echo "3. 📦 Solo dependencias base"
    echo "4. 🔤 Solo fuentes"
    echo "5. 🔌 Solo extensiones VS Code"
    echo "6. ⚙️  Solo configuración VS Code"
    echo "7. 🛠️  Solo herramientas npm"
    echo "8. ❌ Salir"
    echo ""
}

# === VERIFICACIÓN DE ESTADO ===
check_status() {
    show_step "Verificando estado actual..."

    echo ""
    echo "📋 Sistema: $SYSTEM"
    echo "📁 VS Code Settings: $VSCODE_SETTINGS_DIR"
    echo "🔤 Directorio de fuentes: $FONT_DIR"
    echo ""

    # Verificar VS Code
    if command -v code &> /dev/null; then
        show_status "VS Code encontrado"
        echo "🔌 Extensiones instaladas: $(code --list-extensions | wc -l)"
    else
        show_warning "VS Code no encontrado"
    fi

    # Verificar Node.js
    if command -v node &> /dev/null; then
        show_status "Node.js $(node --version)"
    else
        show_warning "Node.js no instalado"
    fi

    # Verificar configuración
    if [ -f "$VSCODE_SETTINGS_DIR/settings.json" ]; then
        show_status "Settings.json existe"
    else
        show_warning "Settings.json no encontrado"
    fi
}

# === FUNCIÓN PRINCIPAL ===
main() {
    setup_paths

    while true; do
        show_menu
        read -p "Opción (1-8): " choice

        case $choice in
            1) check_status ;;
            2)
                install_base_dependencies
                install_fonts
                install_vscode_extensions
                configure_vscode_settings
                install_npm_tools
                show_status "¡Configuración completa terminada!"
                ;;
            3) install_base_dependencies ;;
            4) install_fonts ;;
            5) install_vscode_extensions ;;
            6) configure_vscode_settings ;;
            7) install_npm_tools ;;
            8)
                echo "👋 ¡Hasta luego!"
                exit 0
                ;;
            *)
                show_error "Opción inválida"
                ;;
        esac

        echo ""
        read -p "Presiona Enter para continuar..."
    done
}

# === EJECUCIÓN ===
main
