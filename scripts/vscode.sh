#!/bin/bash

# Módulo de configuración de VS Code
# Compatible con macOS, Linux, WSL, Windows

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

# Detección de problemas de VS Code en macOS
detect_vscode_macos_issues() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        show_warning "🍎 Detectado macOS: VS Code puede tener problemas con Electron Framework"
        show_info "💡 Si las extensiones fallan, se proporcionarán instrucciones manuales"
        return 0
    fi
    return 1
}

# Funciones robustas para manejar crashes de VS Code en macOS
code_list_extensions_safe() {
    local max_attempts=3
    local attempt=1

    while [[ $attempt -le $max_attempts ]]; do
        if timeout 30 code --list-extensions 2>/dev/null; then
            return 0
        else
            show_warning "⚠️ VS Code crash detectado (intento $attempt/$max_attempts)"
            ((attempt++))
            [[ $attempt -le $max_attempts ]] && sleep 2
        fi
    done

    show_error "❌ VS Code presenta crashes persistentes en macOS"
    show_info "💡 Esto es un problema conocido de Electron Framework"
    return 1
}

code_install_extension_safe() {
    local ext="$1"
    local max_attempts=3
    local attempt=1

    while [[ $attempt -le $max_attempts ]]; do
        show_info "📦 Instalando $ext (intento $attempt/$max_attempts)..."

        if timeout 60 code --install-extension "$ext" --force 2>/dev/null; then
            show_success "✅ $ext instalado correctamente"
            return 0
        else
            show_warning "⚠️ Crash o error instalando $ext"
            ((attempt++))
            [[ $attempt -le $max_attempts ]] && show_info "⏳ Esperando 3 segundos..." && sleep 3
        fi
    done

    show_error "❌ No se pudo instalar $ext después de $max_attempts intentos"
    return 1
}

extension_already_installed() {
    local ext="$1"
    local extensions_list

    # Intentar obtener lista de extensiones de forma segura
    extensions_list=$(code_list_extensions_safe)
    if [[ $? -eq 0 ]]; then
        echo "$extensions_list" | grep -q "^$ext$"
    else
        # Si no se puede obtener la lista, asumir que no está instalada
        return 1
    fi
}

# Instalación manual de extensiones para macOS problemático
install_extensions_manual_mode() {
    show_step "🌍 Configuración Manual de Extensiones para macOS"
    
    show_info "Debido a problemas conocidos con Electron Framework en macOS,"
    show_info "se recomienda instalar las extensiones manualmente:"
    
    echo ""
    show_info "📋 EXTENSIONES ESENCIALES PARA INSTALAR:"
    echo ""
    show_info "🌍 1. Spanish Language Pack"
    show_info "   → Busca: 'Spanish Language Pack for Visual Studio Code'"
    show_info "   → Publisher: MS-CEINTL"
    echo ""
    show_info "🎨 2. Prettier - Code formatter"
    show_info "   → Busca: 'Prettier - Code formatter'"
    show_info "   → Publisher: esbenp"
    echo ""
    show_info "🔍 3. ESLint"
    show_info "   → Busca: 'ESLint'"
    show_info "   → Publisher: dbaeumer"
    echo ""
    show_info "🚀 4. Live Server"
    show_info "   → Busca: 'Live Server'"
    show_info "   → Publisher: ritwickdey"
    echo ""
    show_info "🔗 5. GitLens"
    show_info "   → Busca: 'GitLens — Git supercharged'"
    show_info "   → Publisher: eamodio"
    echo ""
    
    show_info "📝 INSTRUCCIONES:"
    show_info "1. Abre VS Code"
    show_info "2. Presiona Cmd+Shift+X (Extensions)"
    show_info "3. Busca e instala cada extensión de la lista"
    show_info "4. Reinicia VS Code después de instalar Spanish Language Pack"
    echo ""
    
    # Configurar idioma manualmente
    local locale_file="$VSCODE_SETTINGS_DIR/locale.json"
    mkdir -p "$VSCODE_SETTINGS_DIR"
    echo '{"locale":"es"}' > "$locale_file"
    show_success "✅ Configuración de idioma creada: locale.json"
    
    show_info "💡 VS Code se configurará en español después del reinicio"
}

# Función principal de instalación de extensiones
install_vscode_extensions() {
    show_step "Instalando extensiones de VS Code..."

    # Verificar que VS Code esté disponible
    if ! command -v code &> /dev/null; then
        show_error "VS Code no está disponible en PATH"
        show_info "Instala VS Code desde: https://code.visualstudio.com/"
        return 1
    fi

    # Lista de extensiones esenciales
    local extensions=(
        # Idioma español - PRIORIDAD: Instalar primero
        "ms-ceintl.vscode-language-pack-es"

        # Esenciales
        "esbenp.prettier-vscode"
        "dbaeumer.vscode-eslint"
        "ms-vscode.vscode-typescript-next"

        # Temas e iconos
        "pkief.material-icon-theme"
        "zhuangtongfa.material-theme"
        "dracula-theme.theme-dracula"

        # Desarrollo web
        "ritwickdey.liveserver"
        "formulahendry.auto-rename-tag"
        "christian-kohler.path-intellisense"
        "bradlc.vscode-tailwindcss"

        # Git
        "eamodio.gitlens"
        "mhutchie.git-graph"
        "github.vscode-github-actions"
        "github.vscode-pull-request-github"

        # Colaboración
        "ms-vsliveshare.vsliveshare"
        "ms-vsliveshare.vsliveshare-audio"

        # Utilidades
        "usernamehw.errorlens"
        "streetsidesoftware.code-spell-checker"
        "gruntfuggly.todo-tree"
        "ms-vscode.hexeditor"

        # Desarrollo específico
        "ms-python.python"
        "ms-vscode.cpptools"
        "rust-lang.rust-analyzer"
        "golang.go"
    )

    # Detectar si estamos en macOS con problemas
    if detect_vscode_macos_issues; then
        # Usar sistema anti-crash para macOS
        local installed=0
        local failed=0

        # PASO 1: Instalar Spanish Language Pack PRIMERO (crítico)
        local spanish_ext="ms-ceintl.vscode-language-pack-es"
        show_info "🌍 PRIORIDAD: Instalando Spanish Language Pack..."

        if ! extension_already_installed "$spanish_ext"; then
            if code_install_extension_safe "$spanish_ext"; then
                ((installed++))
                show_success "✅ Spanish Language Pack instalado con sistema anti-crash"
                
                # Configurar idioma inmediatamente
                local locale_file="$VSCODE_SETTINGS_DIR/locale.json"
                mkdir -p "$VSCODE_SETTINGS_DIR"
                echo '{"locale":"es"}' > "$locale_file"
                show_success "✅ Configuración de idioma creada"
            else
                show_warning "⚠️ Spanish Language Pack falló con sistema anti-crash"
                ((failed++))
            fi
        else
            show_info "✅ Spanish Language Pack ya está instalado"
        fi

        # PASO 2: Intentar instalar extensiones esenciales con anti-crash
        local essential_extensions=(
            "esbenp.prettier-vscode"
            "dbaeumer.vscode-eslint"
            "ritwickdey.liveserver"
            "eamodio.gitlens"
            "pkief.material-icon-theme"
        )

        show_info "� Instalando extensiones esenciales con sistema anti-crash..."
        for ext in "${essential_extensions[@]}"; do
            if ! extension_already_installed "$ext"; then
                if code_install_extension_safe "$ext"; then
                    ((installed++))
                else
                    show_warning "❌ $ext falló con anti-crash"
                    ((failed++))
                fi
            else
                show_info "✅ $ext ya está instalada"
            fi
        done

        show_status "📊 Resultado macOS: $installed instaladas, $failed errores"
        
        # Si hay muchos errores, mostrar modo manual
        if [[ $failed -gt 2 ]]; then
            show_warning "⚠️ Múltiples errores detectados, mostrando modo manual..."
            install_extensions_manual_mode
        fi
        
        return 0
    fi

    # En otros sistemas (Linux, WSL), instalación normal
    local installed=0
    local failed=0

    show_info "🐧 Sistema no-macOS: Instalación normal de extensiones"
    for ext in "${extensions[@]}"; do
        if ! extension_already_installed "$ext"; then
            if code_install_extension_safe "$ext"; then
                ((installed++))
            else
                ((failed++))
            fi
        else
            show_info "✅ $ext ya está instalada"
        fi
    done

    show_status "Extensiones procesadas: $installed instaladas, $failed errores"
    
    # Configurar idioma español específicamente
    configure_spanish_language
}

configure_spanish_language() {
    show_step "Configurando idioma español en VS Code..."
    
    # Verificar si la extensión de idioma español está instalada
    if code --list-extensions 2>/dev/null | grep -q "ms-ceintl.vscode-language-pack-es"; then
        show_success "✅ Extensión de idioma español encontrada"
        
        # Crear archivo locale.json para forzar el idioma
        local locale_file="$VSCODE_SETTINGS_DIR/locale.json"
        mkdir -p "$VSCODE_SETTINGS_DIR"
        echo '{"locale":"es"}' > "$locale_file"
        show_success "Configuración de locale creada: locale.json"
        
        show_info "💡 Reinicia VS Code para ver la interfaz en español"
    else
        show_warning "⚠️ Extensión de idioma español no encontrada"
        show_info "🔄 Intentando instalación con mayor prioridad..."
        
        # Intentar instalación específica para idioma
        if [[ "$OSTYPE" == "darwin"* ]]; then
            # En macOS usar sistema anti-crash
            code_install_extension_safe "ms-ceintl.vscode-language-pack-es"
        else
            # En otros sistemas instalación normal
            timeout 60 code --install-extension ms-ceintl.vscode-language-pack-es --force
        fi
        
        if [[ $? -eq 0 ]]; then
            # Configurar después de instalación exitosa
            local locale_file="$VSCODE_SETTINGS_DIR/locale.json"
            mkdir -p "$VSCODE_SETTINGS_DIR"
            echo '{"locale":"es"}' > "$locale_file"
            show_success "✅ Spanish Language Pack instalado y configurado"
            show_info "💡 Reinicia VS Code para ver los cambios"
        else
            show_error "❌ No se pudo instalar Spanish Language Pack"
            show_info "📋 Instalación manual requerida:"
            show_info "   1. Abre VS Code"
            show_info "   2. Ctrl+Shift+P → 'Extensions: Install Extensions'"
            show_info "   3. Busca: 'Spanish Language Pack'"
            show_info "   4. Instala: 'Spanish Language Pack for Visual Studio Code'"
            show_info "   5. Reinicia VS Code"
        fi
    fi
}

configure_vscode_settings() {
    show_step "Configurando VS Code settings.json..."

    # Crear directorio si no existe
    mkdir -p "$VSCODE_SETTINGS_DIR"

    # Verificar permisos de escritura
    if [[ ! -w "$VSCODE_SETTINGS_DIR" ]]; then
        show_error "No se puede escribir en: $VSCODE_SETTINGS_DIR"
        show_info "Verifica permisos o ejecuta con privilegios apropiados"
        return 1
    fi

    # Backup de configuración existente
    if [[ -f "$VSCODE_SETTINGS_DIR/settings.json" ]]; then
        local backup_file="$VSCODE_SETTINGS_DIR/settings.json.backup.$(date +%Y%m%d_%H%M%S)"
        cp "$VSCODE_SETTINGS_DIR/settings.json" "$backup_file"
        show_info "Backup creado: $(basename "$backup_file")"
    fi

    # Generar configuración base
    generate_base_settings > "$VSCODE_SETTINGS_DIR/settings.json"

    # Agregar configuraciones específicas por sistema
    case "$SYSTEM" in
        "WSL")
            add_wsl_settings
            ;;
        "macOS")
            add_macos_settings
            ;;
        "Windows")
            add_windows_settings
            ;;
    esac

    show_status "Settings.json configurado para $SYSTEM"
}

generate_base_settings() {
    cat << 'EOF'
{
  // === IDIOMA Y LOCALIZACIÓN ===
  "locale": "es",
  "update.enableWindowsBackgroundUpdates": false,

  "workbench.iconTheme": "material-icon-theme",
  "workbench.colorTheme": "One Dark Pro",
  "workbench.startupEditor": "none",
  "workbench.editor.enablePreview": false,
  "workbench.editor.closeOnFileDelete": true,
  "workbench.tree.indent": 15,
  "workbench.tree.renderIndentGuides": "always",

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
  "editor.quickSuggestions": {
    "other": true,
    "comments": false,
    "strings": false
  },

  // === TERMINAL CONFIGURATION ===
  "terminal.integrated.fontFamily": "'MesloLGS Nerd Font', 'Fira Code', 'JetBrains Mono', 'Cascadia Code', monospace",
  "terminal.integrated.fontSize": 13,
  "terminal.integrated.lineHeight": 1.2,
  "terminal.integrated.cursorBlinking": true,
  "terminal.integrated.cursorStyle": "line",

  // === FILES AND SEARCH ===
  "files.autoSave": "afterDelay",
  "files.autoSaveDelay": 1000,
  "files.trimTrailingWhitespace": true,
  "files.insertFinalNewline": true,
  "files.trimFinalNewlines": true,
  "search.exclude": {
    "**/node_modules": true,
    "**/bower_components": true,
    "**/*.code-search": true,
    "**/dist": true,
    "**/build": true
  },

  // === PRETTIER CONFIGURATION ===
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "editor.formatOnSave": true,
  "editor.formatOnPaste": true,
  "[javascript]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[typescript]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[json]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[html]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[css]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[scss]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[markdown]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },

  // === ESLINT CONFIGURATION ===
  "eslint.validate": [
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact"
  ],
  "eslint.codeAction.showDocumentation": {
    "enable": true
  },

  // === LIVE SERVER ===
  "liveServer.settings.donotShowInfoMsg": true,
  "liveServer.settings.port": 5500,
  "liveServer.settings.donotVerifyTags": true,

  // === GIT CONFIGURATION ===
  "git.enableSmartCommit": true,
  "git.confirmSync": false,
  "git.autofetch": true,
  "gitlens.currentLine.enabled": false,
  "gitlens.hovers.currentLine.over": "line",

  // === SECURITY ===
  "security.workspace.trust.untrustedFiles": "open",
  "extensions.ignoreRecommendations": false
}
EOF
}

add_wsl_settings() {
    local wsl_config=$(cat << 'EOF'
  ,
  // === WSL SPECIFIC SETTINGS ===
  "terminal.integrated.defaultProfile.windows": "Git Bash",
  "remote.WSL.fileWatcher.polling": true,
  "remote.WSL.useShellEnvironment": true
}
EOF
)

    # Agregar configuraciones WSL al archivo
    remove_last_line "$VSCODE_SETTINGS_DIR/settings.json" "$VSCODE_SETTINGS_DIR/settings.tmp"
    echo "$wsl_config" >> "$VSCODE_SETTINGS_DIR/settings.tmp"
    mv "$VSCODE_SETTINGS_DIR/settings.tmp" "$VSCODE_SETTINGS_DIR/settings.json"
}

add_macos_settings() {
    local macos_config=$(cat << 'EOF'
  ,
  // === MACOS SPECIFIC SETTINGS ===
  "terminal.integrated.defaultProfile.osx": "zsh",
  "editor.fontFamily": "'Fira Code', 'JetBrains Mono', 'SF Mono', 'Monaco', monospace"
}
EOF
)

    # Agregar configuraciones macOS al archivo
    remove_last_line "$VSCODE_SETTINGS_DIR/settings.json" "$VSCODE_SETTINGS_DIR/settings.tmp"
    echo "$macos_config" >> "$VSCODE_SETTINGS_DIR/settings.tmp"
    mv "$VSCODE_SETTINGS_DIR/settings.tmp" "$VSCODE_SETTINGS_DIR/settings.json"
}

add_windows_settings() {
    local windows_config=$(cat << 'EOF'
  ,
  // === WINDOWS SPECIFIC SETTINGS ===
  "terminal.integrated.defaultProfile.windows": "Git Bash",
  "terminal.integrated.profiles.windows": {
    "Git Bash": {
      "path": "C:\\Program Files\\Git\\bin\\bash.exe",
      "args": ["--login", "-i"]
    }
  }
}
EOF
)

    # Agregar configuraciones Windows al archivo
    remove_last_line "$VSCODE_SETTINGS_DIR/settings.json" "$VSCODE_SETTINGS_DIR/settings.tmp"
    echo "$windows_config" >> "$VSCODE_SETTINGS_DIR/settings.tmp"
    mv "$VSCODE_SETTINGS_DIR/settings.tmp" "$VSCODE_SETTINGS_DIR/settings.json"
}

# Función para verificar configuración de VS Code
check_vscode_config() {
    show_step "Verificando configuración de VS Code..."

    # Verificar que VS Code esté instalado
    if ! command -v code &> /dev/null; then
        show_error "VS Code no está instalado o no está en PATH"
        return 1
    fi

    # Verificar directorio de configuración
    if [[ ! -d "$VSCODE_SETTINGS_DIR" ]]; then
        show_warning "Directorio de configuración no existe: $VSCODE_SETTINGS_DIR"
        return 1
    fi

    # Verificar settings.json
    if [[ -f "$VSCODE_SETTINGS_DIR/settings.json" ]]; then
        show_success "settings.json encontrado"
    else
        show_warning "settings.json no encontrado"
    fi

    # Contar extensiones instaladas
    local extension_count=$(code --list-extensions 2>/dev/null | wc -l || echo "0")
    show_info "Extensiones instaladas: $extension_count"

    return 0
}

# Función para mostrar información post-instalación
show_vscode_post_install_info() {
    show_step "Información post-instalación de VS Code"

    echo ""
    show_info "🎉 ¡Configuración de VS Code completada!"
    echo ""
    show_info "📋 PRÓXIMOS PASOS:"
    show_info "1. Reinicia VS Code para aplicar cambios"
    show_info "2. Verifica que la interfaz esté en español"
    show_info "3. Instala extensiones faltantes manualmente si es necesario"
    echo ""
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        show_info "🍎 ESPECÍFICO PARA macOS:"
        show_info "• Si las extensiones no se instalaron automáticamente"
        show_info "• Usa Cmd+Shift+X para abrir el panel de extensiones"
        show_info "• Instala manualmente las extensiones de la lista proporcionada"
        echo ""
    fi

    show_info "⚙️ CONFIGURACIÓN APLICADA:"
    show_info "• Idioma configurado en español"
    show_info "• Fuentes con ligaduras habilitadas"
    show_info "• Formateo automático con Prettier"
    show_info "• Terminal configurado"
    show_info "• Configuraciones específicas para $SYSTEM"
    echo ""
}
