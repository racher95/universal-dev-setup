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
        # "ms-vscode.vscode-json"  # Ya incluido en VS Code por defecto

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

    # Extensiones específicas por sistema
    case "$SYSTEM" in
        "WSL")
            # Las extensiones Remote se instalan automáticamente desde Windows
            show_info "Extensiones Remote gestionadas desde Windows VS Code"
            ;;
        "macOS"|"Linux")
            # Agregar extensiones específicas para sistemas nativos si es necesario
            extensions+=(
                # Futuras extensiones específicas de macOS/Linux
            )
            ;;
    esac

    # Instalar extensiones
    local installed=0
    local failed=0

    # PASO 1: Instalar Spanish Language Pack PRIMERO (crítico)
    local spanish_ext="ms-ceintl.vscode-language-pack-es"
    show_info "🌍 PRIORIDAD: Instalando Spanish Language Pack..."

    if ! extension_already_installed "$spanish_ext"; then
        if code_install_extension_safe "$spanish_ext"; then
            ((installed++))
        else
            show_warning "⚠️ Error instalando Spanish Language Pack - se reintentará"
            ((failed++))
        fi
    else
        show_info "✅ Spanish Language Pack ya está instalado"
    fi

    # PASO 2: Instalar resto de extensiones con manejo de crashes
    show_info "📦 Instalando extensiones adicionales..."

    for ext in "${extensions[@]}"; do
        # Saltar Spanish Language Pack ya que se instaló arriba
        [[ "$ext" == "$spanish_ext" ]] && continue

        if ! extension_already_installed "$ext"; then
            if code_install_extension_safe "$ext"; then
                ((installed++))
            else
                show_warning "❌ Error instalando $ext"
                ((failed++))
            fi
        else
            show_info "✅ $ext ya está instalada"
        fi
    done

    show_status "Extensiones procesadas: $installed instaladas, $failed errores"

    # PASO 3: Configurar idioma español específicamente
    configure_spanish_language
}

configure_spanish_language() {
    show_step "Configurando idioma español en VS Code..."

    # Verificar si la extensión de idioma español está instalada
    if code --list-extensions | grep -q "ms-ceintl.vscode-language-pack-es"; then
        show_success "✅ Extensión de idioma español encontrada"

        # Crear archivo locale.json para forzar el idioma
        local locale_file="$VSCODE_SETTINGS_DIR/locale.json"
        echo '{"locale":"es"}' > "$locale_file"
        show_success "Configuración de locale creada: locale.json"

        # Verificar que settings.json tenga la configuración de idioma
        if [[ -f "$VSCODE_SETTINGS_DIR/settings.json" ]]; then
            if ! grep -q '"locale".*"es"' "$VSCODE_SETTINGS_DIR/settings.json"; then
                show_info "Agregando configuración de idioma a settings.json"
                # La configuración ya se agrega en generate_base_settings()
            fi
        fi

        show_info "💡 Reinicia VS Code para ver la interfaz en español"
        show_info "   La extensión Spanish Language Pack estará activa"
    else
        show_warning "⚠️ Extensión de idioma español no encontrada"
        show_info "🔄 Intentando instalación con mayor prioridad..."

        # Intentar instalación con timeout y retry
        local max_attempts=3
        local attempt=1

        while [[ $attempt -le $max_attempts ]]; do
            show_info "Intento $attempt/$max_attempts: Instalando Spanish Language Pack..."

            if timeout 60 code --install-extension ms-ceintl.vscode-language-pack-es --force; then
                show_success "✅ Spanish Language Pack instalado correctamente"

                # Configurar después de instalación exitosa
                local locale_file="$VSCODE_SETTINGS_DIR/locale.json"
                echo '{"locale":"es"}' > "$locale_file"
                show_success "Configuración de locale creada: locale.json"

                show_info "🎉 VS Code configurado en español"
                show_info "💡 Reinicia VS Code para ver los cambios"
                return 0
            else
                show_warning "❌ Intento $attempt falló"
                ((attempt++))
                [[ $attempt -le $max_attempts ]] && show_info "⏳ Esperando 3 segundos antes del siguiente intento..." && sleep 3
            fi
        done

        show_error "❌ No se pudo instalar Spanish Language Pack después de $max_attempts intentos"
        show_info "📋 Instalación manual:"
        show_info "   1. Abre VS Code"
        show_info "   2. Ctrl+Shift+P → 'Extensions: Install Extensions'"
        show_info "   3. Busca: 'Spanish Language Pack'"
        show_info "   4. Instala: 'Spanish Language Pack for Visual Studio Code'"
        show_info "   5. Reinicia VS Code"
        return 1
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
  "[python]": {
    "editor.defaultFormatter": "ms-python.python",
    "editor.formatOnSave": true,
    "editor.codeActionsOnSave": {
      "source.organizeImports": "explicit"
    }
  },

  // === FILES ===
  "files.autoSave": "afterDelay",
  "files.autoSaveDelay": 1000,
  "files.trimTrailingWhitespace": true,
  "files.insertFinalNewline": true,
  "files.trimFinalNewlines": true,
  "files.associations": {
    "*.env": "shellscript",
    "*.env.*": "shellscript",
    "Dockerfile*": "dockerfile",
    "*.dockerfile": "dockerfile"
  },
  "files.exclude": {
    "**/.git": true,
    "**/.DS_Store": true,
    "**/node_modules": true,
    "**/dist": true,
    "**/build": true,
    "**/.next": true,
    "**/.nuxt": true,
    "**/coverage": true,
    "**/__pycache__": true,
    "**/*.pyc": true
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
  "terminal.integrated.fontFamily": "MesloLGS Nerd Font, Fira Code, JetBrains Mono, SF Mono, Monaco, Consolas",
  "terminal.integrated.fontSize": 13,
  "terminal.integrated.lineHeight": 1.4,
  "terminal.integrated.cursorBlinking": true,
  "terminal.integrated.cursorStyle": "line",
  "terminal.integrated.copyOnSelection": true,
  "terminal.integrated.rightClickBehavior": "copyPaste",
  "terminal.integrated.scrollback": 10000,
  "terminal.integrated.defaultProfile.windows": "Ubuntu (WSL)",
  "terminal.integrated.profiles.windows": {
    "Ubuntu (WSL)": {
      "path": "C:\\Windows\\System32\\wsl.exe",
      "args": ["-d", "Ubuntu"],
      "icon": "terminal-ubuntu"
    },
    "PowerShell": {
      "source": "PowerShell",
      "icon": "terminal-powershell"
    },
    "Command Prompt": {
      "path": "C:\\Windows\\System32\\cmd.exe",
      "args": [],
      "icon": "terminal-cmd"
    },
    "Git Bash": {
      "path": "C:\\Program Files\\Git\\bin\\bash.exe",
      "args": [],
      "icon": "terminal-bash"
    }
  },

  // === SECURITY & TRUST ===
  "security.workspace.trust.untrustedFiles": "open",
  "security.workspace.trust.banner": "never",
  "security.workspace.trust.startupPrompt": "never",

  // === EXTENSIONS ===
  "redhat.telemetry.enabled": false,
  "telemetry.telemetryLevel": "off",
  "update.mode": "manual",
  "extensions.ignoreRecommendations": false,
  "extensions.autoUpdate": true,

  // === GITHUB COPILOT ===
  "github.copilot.enable": {
    "*": true,
    "yaml": false,
    "plaintext": false
  },

  // === GIT ===
  "git.confirmSync": false,
  "git.autofetch": true,
  "git.enableSmartCommit": true,
  "git.suggestSmartCommit": false,
  "diffEditor.ignoreTrimWhitespace": false,

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
  "explorer.fileNesting.enabled": true,
  "explorer.fileNesting.patterns": {
    "package.json": "package-lock.json,yarn.lock,pnpm-lock.yaml",
    "*.js": "$(capture).js.map",
    "*.jsx": "$(capture).js,$(capture).*.jsx",
    "*.ts": "$(capture).js,$(capture).*.ts,$(capture).d.ts",
    "*.tsx": "$(capture).ts,$(capture).*.tsx",
    "*.vue": "$(capture).*.ts,$(capture).*.js"
  },

  // === SEARCH ===
  "search.exclude": {
    "**/node_modules": true,
    "**/dist": true,
    "**/build": true,
    "**/.next": true,
    "**/.nuxt": true,
    "**/coverage": true,
    "**/.git": true,
    "**/__pycache__": true,
    "**/*.pyc": true
  },

  // === PERFORMANCE ===
  "typescript.preferences.includePackageJsonAutoImports": "auto",
  "typescript.suggest.autoImports": true,
  "javascript.suggest.autoImports": true,
  "typescript.updateImportsOnFileMove.enabled": "always",
  "javascript.updateImportsOnFileMove.enabled": "always"
}
EOF
}

add_wsl_settings() {
    # Configuraciones específicas para WSL
    local wsl_config=$(cat << 'EOF'
,
  // === WSL SPECIFIC ===
  "remote.WSL.fileWatcher.polling": true,
  "remote.WSL.useShellEnvironment": true,
  "remote.WSL.defaultDistribution": "Ubuntu"
}
EOF
)

    # Agregar configuraciones WSL al archivo
    remove_last_line "$VSCODE_SETTINGS_DIR/settings.json" "$VSCODE_SETTINGS_DIR/settings.tmp"
    echo "$wsl_config" >> "$VSCODE_SETTINGS_DIR/settings.tmp"
    mv "$VSCODE_SETTINGS_DIR/settings.tmp" "$VSCODE_SETTINGS_DIR/settings.json"
}

add_macos_settings() {
    # Configuraciones específicas para macOS
    local macos_config=$(cat << 'EOF'
,
  // === MACOS SPECIFIC ===
  "terminal.integrated.defaultProfile.osx": "zsh",
  "terminal.integrated.profiles.osx": {
    "zsh": {
      "path": "/bin/zsh",
      "args": ["-l"]
    }
  }
}
EOF
)

    # Agregar configuraciones macOS al archivo
    remove_last_line "$VSCODE_SETTINGS_DIR/settings.json" "$VSCODE_SETTINGS_DIR/settings.tmp"
    echo "$macos_config" >> "$VSCODE_SETTINGS_DIR/settings.tmp"
    mv "$VSCODE_SETTINGS_DIR/settings.tmp" "$VSCODE_SETTINGS_DIR/settings.json"
}

add_windows_settings() {
    # Configuraciones específicas para Windows
    local windows_config=$(cat << 'EOF'
,
  // === WINDOWS SPECIFIC ===
  "terminal.integrated.defaultProfile.windows": "PowerShell",
  "terminal.integrated.profiles.windows": {
    "PowerShell": {
      "source": "PowerShell",
      "icon": "terminal-powershell"
    },
    "Command Prompt": {
      "path": "C:\\Windows\\System32\\cmd.exe",
      "args": [],
      "icon": "terminal-cmd"
    },
    "Git Bash": {
      "path": "C:\\Program Files\\Git\\bin\\bash.exe",
      "args": [],
      "icon": "terminal-bash"
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

    if [[ -f "$VSCODE_SETTINGS_DIR/settings.json" ]]; then
        show_status "settings.json encontrado"

        # Verificar configuraciones clave
        if grep -q "material-icon-theme" "$VSCODE_SETTINGS_DIR/settings.json"; then
            show_status "Tema de iconos configurado"
        fi

        if grep -q "Fira Code" "$VSCODE_SETTINGS_DIR/settings.json"; then
            show_status "Fuente Fira Code configurada"
        fi

        if grep -q "prettier-vscode" "$VSCODE_SETTINGS_DIR/settings.json"; then
            show_status "Prettier configurado"
        fi
    else
        show_warning "settings.json no encontrado"
    fi

    # Verificar extensiones
    if command -v code &> /dev/null; then
        local ext_count=$(code --list-extensions | wc -l)
        show_info "Extensiones instaladas: $ext_count"
    fi
}

# Función para mostrar información post-instalación de VS Code
show_vscode_post_install_info() {
    echo -e "\n${CYAN}📋 INFORMACIÓN POST-INSTALACIÓN DE VS CODE:${NC}"
    echo "════════════════════════════════════════════════════════"
    echo -e "${YELLOW}🌐 Cambio de idioma a español:${NC}"
    echo "1. Abre VS Code"
    echo "2. Presiona Ctrl+Shift+P (Cmd+Shift+P en macOS)"
    echo "3. Escribe: Configure Display Language"
    echo "4. Selecciona 'Español' de la lista"
    echo "5. Reinicia VS Code"
    echo ""
    echo -e "${BLUE}ℹ️  El paquete de idioma español ya está instalado automáticamente${NC}"
    echo -e "${BLUE}ℹ️  Si no aparece español, espera unos minutos y reinicia VS Code${NC}"
    echo ""
    echo -e "${YELLOW}🔤 Fuentes instaladas:${NC}"
    echo "• Fira Code (con ligaduras)"
    echo "• JetBrains Mono"
    echo "• Cascadia Code"
    echo "• MesloLGS Nerd Font"
    echo ""
    echo -e "${YELLOW}⚙️  Configuraciones aplicadas:${NC}"
    echo "• Tema: One Dark Pro"
    echo "• Iconos: Material Icon Theme"
    echo "• Formato automático al guardar"
    echo "• Configuración de terminal optimizada"
    echo ""
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

# Instalación alternativa para macOS cuando code CLI falla
install_extension_vsix() {
    local ext_id="$1"
    local ext_dir="$HOME/.vscode/extensions"
    
    show_info "📦 Instalación alternativa para $ext_id..."
    
    # Crear directorio de extensiones si no existe
    mkdir -p "$ext_dir"
    
    # URLs de descarga directa para extensiones críticas
    case "$ext_id" in
        "ms-ceintl.vscode-language-pack-es")
            show_info "🌍 Instalando Spanish Language Pack vía descarga directa..."
            local download_url="https://marketplace.visualstudio.com/_apis/public/gallery/publishers/MS-CEINTL/vsextensions/vscode-language-pack-es/latest/vspackage"
            ;;
        "esbenp.prettier-vscode")
            show_info "🎨 Instalando Prettier vía descarga directa..."
            local download_url="https://marketplace.visualstudio.com/_apis/public/gallery/publishers/esbenp/vsextensions/prettier-vscode/latest/vspackage"
            ;;
        *)
            show_warning "⚠️ Descarga directa no configurada para $ext_id"
            return 1
            ;;
    esac
    
    # Intentar descarga e instalación manual
    local temp_file="/tmp/${ext_id}.vsix"
    
    if curl -L -o "$temp_file" "$download_url" 2>/dev/null; then
        show_info "✅ Descarga exitosa de $ext_id"
        
        # Intentar instalación con el archivo .vsix
        if code --install-extension "$temp_file" 2>/dev/null; then
            show_success "✅ $ext_id instalado vía archivo .vsix"
            rm -f "$temp_file"
            return 0
        else
            show_warning "⚠️ Falló instalación de archivo .vsix para $ext_id"
            rm -f "$temp_file"
            return 1
        fi
    else
        show_warning "⚠️ No se pudo descargar $ext_id"
        return 1
    fi
}

# Función para manejar la instalación con fallback en macOS
install_extension_with_fallback() {
    local ext="$1"
    
    # Detectar si estamos en macOS y el comando code está fallando sistemáticamente
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # Primero intentar método estándar UNA sola vez
        show_info "🔄 Intentando instalación estándar de $ext..."
        if timeout 30 code --install-extension "$ext" --force 2>/dev/null; then
            show_success "✅ $ext instalado con método estándar"
            return 0
        else
            show_warning "⚠️ Método estándar falló para $ext, intentando alternativo..."
            # Si falla, intentar método alternativo
            if install_extension_vsix "$ext"; then
                return 0
            else
                show_error "❌ Ambos métodos fallaron para $ext"
                return 1
            fi
        fi
    else
        # En otros sistemas, usar función segura original
        code_install_extension_safe "$ext"
    fi
}

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
        # "ms-vscode.vscode-json"  # Ya incluido en VS Code por defecto

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

    # Extensiones específicas por sistema
    case "$SYSTEM" in
        "WSL")
            # Las extensiones Remote se instalan automáticamente desde Windows
            show_info "Extensiones Remote gestionadas desde Windows VS Code"
            ;;
        "macOS"|"Linux")
            # Agregar extensiones específicas para sistemas nativos si es necesario
            extensions+=(
                # Futuras extensiones específicas de macOS/Linux
            )
            ;;
    esac

    # Instalar extensiones
    local installed=0
    local failed=0

    # PASO 1: Instalar Spanish Language Pack PRIMERO (crítico)
    local spanish_ext="ms-ceintl.vscode-language-pack-es"
    show_info "🌍 PRIORIDAD: Instalando Spanish Language Pack..."

    if ! extension_already_installed "$spanish_ext"; then
        if code_install_extension_safe "$spanish_ext"; then
            ((installed++))
        else
            show_warning "⚠️ Error instalando Spanish Language Pack - se reintentará"
            ((failed++))
        fi
    else
        show_info "✅ Spanish Language Pack ya está instalado"
    fi

    # PASO 2: Instalar resto de extensiones con manejo de crashes
    show_info "📦 Instalando extensiones adicionales..."

    for ext in "${extensions[@]}"; do
        # Saltar Spanish Language Pack ya que se instaló arriba
        [[ "$ext" == "$spanish_ext" ]] && continue

        if ! extension_already_installed "$ext"; then
            if code_install_extension_safe "$ext"; then
                ((installed++))
            else
                show_warning "❌ Error instalando $ext"
                ((failed++))
            fi
        else
            show_info "✅ $ext ya está instalada"
        fi
    done

    show_status "Extensiones procesadas: $installed instaladas, $failed errores"

    # PASO 3: Configurar idioma español específicamente
    configure_spanish_language
}

configure_spanish_language() {
    show_step "Configurando idioma español en VS Code..."

    # Verificar si la extensión de idioma español está instalada
    if code --list-extensions | grep -q "ms-ceintl.vscode-language-pack-es"; then
        show_success "✅ Extensión de idioma español encontrada"

        # Crear archivo locale.json para forzar el idioma
        local locale_file="$VSCODE_SETTINGS_DIR/locale.json"
        echo '{"locale":"es"}' > "$locale_file"
        show_success "Configuración de locale creada: locale.json"

        # Verificar que settings.json tenga la configuración de idioma
        if [[ -f "$VSCODE_SETTINGS_DIR/settings.json" ]]; then
            if ! grep -q '"locale".*"es"' "$VSCODE_SETTINGS_DIR/settings.json"; then
                show_info "Agregando configuración de idioma a settings.json"
                # La configuración ya se agrega en generate_base_settings()
            fi
        fi

        show_info "💡 Reinicia VS Code para ver la interfaz en español"
        show_info "   La extensión Spanish Language Pack estará activa"
    else
        show_warning "⚠️ Extensión de idioma español no encontrada"
        show_info "🔄 Intentando instalación con mayor prioridad..."

        # Intentar instalación con timeout y retry
        local max_attempts=3
        local attempt=1

        while [[ $attempt -le $max_attempts ]]; do
            show_info "Intento $attempt/$max_attempts: Instalando Spanish Language Pack..."

            if timeout 60 code --install-extension ms-ceintl.vscode-language-pack-es --force; then
                show_success "✅ Spanish Language Pack instalado correctamente"

                # Configurar después de instalación exitosa
                local locale_file="$VSCODE_SETTINGS_DIR/locale.json"
                echo '{"locale":"es"}' > "$locale_file"
                show_success "Configuración de locale creada: locale.json"

                show_info "🎉 VS Code configurado en español"
                show_info "💡 Reinicia VS Code para ver los cambios"
                return 0
            else
                show_warning "❌ Intento $attempt falló"
                ((attempt++))
                [[ $attempt -le $max_attempts ]] && show_info "⏳ Esperando 3 segundos antes del siguiente intento..." && sleep 3
            fi
        done

        show_error "❌ No se pudo instalar Spanish Language Pack después de $max_attempts intentos"
        show_info "📋 Instalación manual:"
        show_info "   1. Abre VS Code"
        show_info "   2. Ctrl+Shift+P → 'Extensions: Install Extensions'"
        show_info "   3. Busca: 'Spanish Language Pack'"
        show_info "   4. Instala: 'Spanish Language Pack for Visual Studio Code'"
        show_info "   5. Reinicia VS Code"
        return 1
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
  "[python]": {
    "editor.defaultFormatter": "ms-python.python",
    "editor.formatOnSave": true,
    "editor.codeActionsOnSave": {
      "source.organizeImports": "explicit"
    }
  },

  // === FILES ===
  "files.autoSave": "afterDelay",
  "files.autoSaveDelay": 1000,
  "files.trimTrailingWhitespace": true,
  "files.insertFinalNewline": true,
  "files.trimFinalNewlines": true,
  "files.associations": {
    "*.env": "shellscript",
    "*.env.*": "shellscript",
    "Dockerfile*": "dockerfile",
    "*.dockerfile": "dockerfile"
  },
  "files.exclude": {
    "**/.git": true,
    "**/.DS_Store": true,
    "**/node_modules": true,
    "**/dist": true,
    "**/build": true,
    "**/.next": true,
    "**/.nuxt": true,
    "**/coverage": true,
    "**/__pycache__": true,
    "**/*.pyc": true
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
  "terminal.integrated.fontFamily": "MesloLGS Nerd Font, Fira Code, JetBrains Mono, SF Mono, Monaco, Consolas",
  "terminal.integrated.fontSize": 13,
  "terminal.integrated.lineHeight": 1.4,
  "terminal.integrated.cursorBlinking": true,
  "terminal.integrated.cursorStyle": "line",
  "terminal.integrated.copyOnSelection": true,
  "terminal.integrated.rightClickBehavior": "copyPaste",
  "terminal.integrated.scrollback": 10000,
  "terminal.integrated.defaultProfile.windows": "Ubuntu (WSL)",
  "terminal.integrated.profiles.windows": {
    "Ubuntu (WSL)": {
      "path": "C:\\Windows\\System32\\wsl.exe",
      "args": ["-d", "Ubuntu"],
      "icon": "terminal-ubuntu"
    },
    "PowerShell": {
      "source": "PowerShell",
      "icon": "terminal-powershell"
    },
    "Command Prompt": {
      "path": "C:\\Windows\\System32\\cmd.exe",
      "args": [],
      "icon": "terminal-cmd"
    },
    "Git Bash": {
      "path": "C:\\Program Files\\Git\\bin\\bash.exe",
      "args": [],
      "icon": "terminal-bash"
    }
  },

  // === SECURITY & TRUST ===
  "security.workspace.trust.untrustedFiles": "open",
  "security.workspace.trust.banner": "never",
  "security.workspace.trust.startupPrompt": "never",

  // === EXTENSIONS ===
  "redhat.telemetry.enabled": false,
  "telemetry.telemetryLevel": "off",
  "update.mode": "manual",
  "extensions.ignoreRecommendations": false,
  "extensions.autoUpdate": true,

  // === GITHUB COPILOT ===
  "github.copilot.enable": {
    "*": true,
    "yaml": false,
    "plaintext": false
  },

  // === GIT ===
  "git.confirmSync": false,
  "git.autofetch": true,
  "git.enableSmartCommit": true,
  "git.suggestSmartCommit": false,
  "diffEditor.ignoreTrimWhitespace": false,

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
  "explorer.fileNesting.enabled": true,
  "explorer.fileNesting.patterns": {
    "package.json": "package-lock.json,yarn.lock,pnpm-lock.yaml",
    "*.js": "$(capture).js.map",
    "*.jsx": "$(capture).js,$(capture).*.jsx",
    "*.ts": "$(capture).js,$(capture).*.ts,$(capture).d.ts",
    "*.tsx": "$(capture).ts,$(capture).*.tsx",
    "*.vue": "$(capture).*.ts,$(capture).*.js"
  },

  // === SEARCH ===
  "search.exclude": {
    "**/node_modules": true,
    "**/dist": true,
    "**/build": true,
    "**/.next": true,
    "**/.nuxt": true,
    "**/coverage": true,
    "**/.git": true,
    "**/__pycache__": true,
    "**/*.pyc": true
  },

  // === PERFORMANCE ===
  "typescript.preferences.includePackageJsonAutoImports": "auto",
  "typescript.suggest.autoImports": true,
  "javascript.suggest.autoImports": true,
  "typescript.updateImportsOnFileMove.enabled": "always",
  "javascript.updateImportsOnFileMove.enabled": "always"
}
EOF
}

add_wsl_settings() {
    # Configuraciones específicas para WSL
    local wsl_config=$(cat << 'EOF'
,
  // === WSL SPECIFIC ===
  "remote.WSL.fileWatcher.polling": true,
  "remote.WSL.useShellEnvironment": true,
  "remote.WSL.defaultDistribution": "Ubuntu"
}
EOF
)

    # Agregar configuraciones WSL al archivo
    remove_last_line "$VSCODE_SETTINGS_DIR/settings.json" "$VSCODE_SETTINGS_DIR/settings.tmp"
    echo "$wsl_config" >> "$VSCODE_SETTINGS_DIR/settings.tmp"
    mv "$VSCODE_SETTINGS_DIR/settings.tmp" "$VSCODE_SETTINGS_DIR/settings.json"
}

add_macos_settings() {
    # Configuraciones específicas para macOS
    local macos_config=$(cat << 'EOF'
,
  // === MACOS SPECIFIC ===
  "terminal.integrated.defaultProfile.osx": "zsh",
  "terminal.integrated.profiles.osx": {
    "zsh": {
      "path": "/bin/zsh",
      "args": ["-l"]
    }
  }
}
EOF
)

    # Agregar configuraciones macOS al archivo
    remove_last_line "$VSCODE_SETTINGS_DIR/settings.json" "$VSCODE_SETTINGS_DIR/settings.tmp"
    echo "$macos_config" >> "$VSCODE_SETTINGS_DIR/settings.tmp"
    mv "$VSCODE_SETTINGS_DIR/settings.tmp" "$VSCODE_SETTINGS_DIR/settings.json"
}

add_windows_settings() {
    # Configuraciones específicas para Windows
    local windows_config=$(cat << 'EOF'
,
  // === WINDOWS SPECIFIC ===
  "terminal.integrated.defaultProfile.windows": "PowerShell",
  "terminal.integrated.profiles.windows": {
    "PowerShell": {
      "source": "PowerShell",
      "icon": "terminal-powershell"
    },
    "Command Prompt": {
      "path": "C:\\Windows\\System32\\cmd.exe",
      "args": [],
      "icon": "terminal-cmd"
    },
    "Git Bash": {
      "path": "C:\\Program Files\\Git\\bin\\bash.exe",
      "args": [],
      "icon": "terminal-bash"
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

    if [[ -f "$VSCODE_SETTINGS_DIR/settings.json" ]]; then
        show_status "settings.json encontrado"

        # Verificar configuraciones clave
        if grep -q "material-icon-theme" "$VSCODE_SETTINGS_DIR/settings.json"; then
            show_status "Tema de iconos configurado"
        fi

        if grep -q "Fira Code" "$VSCODE_SETTINGS_DIR/settings.json"; then
            show_status "Fuente Fira Code configurada"
        fi

        if grep -q "prettier-vscode" "$VSCODE_SETTINGS_DIR/settings.json"; then
            show_status "Prettier configurado"
        fi
    else
        show_warning "settings.json no encontrado"
    fi

    # Verificar extensiones
    if command -v code &> /dev/null; then
        local ext_count=$(code --list-extensions | wc -l)
        show_info "Extensiones instaladas: $ext_count"
    fi
}

# Función para mostrar información post-instalación de VS Code
show_vscode_post_install_info() {
    echo -e "\n${CYAN}📋 INFORMACIÓN POST-INSTALACIÓN DE VS CODE:${NC}"
    echo "════════════════════════════════════════════════════════"
    echo -e "${YELLOW}🌐 Cambio de idioma a español:${NC}"
    echo "1. Abre VS Code"
    echo "2. Presiona Ctrl+Shift+P (Cmd+Shift+P en macOS)"
    echo "3. Escribe: Configure Display Language"
    echo "4. Selecciona 'Español' de la lista"
    echo "5. Reinicia VS Code"
    echo ""
    echo -e "${BLUE}ℹ️  El paquete de idioma español ya está instalado automáticamente${NC}"
    echo -e "${BLUE}ℹ️  Si no aparece español, espera unos minutos y reinicia VS Code${NC}"
    echo ""
    echo -e "${YELLOW}🔤 Fuentes instaladas:${NC}"
    echo "• Fira Code (con ligaduras)"
    echo "• JetBrains Mono"
    echo "• Cascadia Code"
    echo "• MesloLGS Nerd Font"
    echo ""
    echo -e "${YELLOW}⚙️  Configuraciones aplicadas:${NC}"
    echo "• Tema: One Dark Pro"
    echo "• Iconos: Material Icon Theme"
    echo "• Formato automático al guardar"
    echo "• Configuración de terminal optimizada"
    echo ""
}
