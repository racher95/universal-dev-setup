#!/bin/bash

# Módulo de instalación de herramientas npm globales
# Compatible con macOS, Linux, WSL, Windows

install_npm_tools() {
    show_step "Instalando herramientas npm globales..."

    # Verificar que npm esté disponible
    if ! command -v npm &> /dev/null; then
        show_error "npm no está disponible"
        show_info "Instala Node.js primero"
        return 1
    fi

    # Actualizar npm a la última versión
    show_info "Actualizando npm..."
    npm install -g npm@latest

    # Lista de herramientas globales esenciales
    local tools=(
        # Servidores de desarrollo
        "live-server"
        "http-server"
        "serve"

        # Herramientas de formateo y linting
        "prettier"
        "eslint"
        "jshint"
        "stylelint"

        # TypeScript
        "typescript"
        "@typescript-eslint/parser"
        "@typescript-eslint/eslint-plugin"

        # Herramientas de construcción
        "webpack"
        "webpack-cli"
        "parcel"
        "vite"

        # Generadores y frameworks
        "create-react-app"
        "vue-cli"
        "@angular/cli"
        "express-generator"

        # Utilidades
        "npm-check-updates"
        "npm-check"
        "nodemon"
        "concurrently"
        "cross-env"

        # Herramientas de testing
        "jest"
        "mocha"
        "cypress"

        # Herramientas de desarrollo
        "gitignore"
        "license"
        "readme-md-generator"
    )

    # Instalar herramientas
    local installed=0
    local failed=0

    for tool in "${tools[@]}"; do
        if ! npm list -g "$tool" &> /dev/null; then
            show_info "Instalando $tool..."
            if npm install -g "$tool" --silent; then
                ((installed++))
            else
                show_warning "Error instalando $tool"
                ((failed++))
            fi
        else
            show_info "$tool ya está instalado"
        fi
    done

    show_status "Herramientas npm procesadas: $installed instaladas, $failed errores"

    # Instalar herramientas específicas por sistema
    install_system_specific_tools

    # Configurar npm
    configure_npm
}

install_system_specific_tools() {
    case "$SYSTEM" in
        "macOS")
            install_macos_npm_tools
            ;;
        "WSL"|"Linux")
            install_linux_npm_tools
            ;;
        "Windows")
            install_windows_npm_tools
            ;;
    esac
}

install_macos_npm_tools() {
    local macos_tools=(
        "trash-cli"
        "wifi-password"
        "battery-level"
    )

    for tool in "${macos_tools[@]}"; do
        if ! npm list -g "$tool" &> /dev/null; then
            show_info "Instalando $tool (macOS)..."
            npm install -g "$tool" --silent
        fi
    done
}

install_linux_npm_tools() {
    local linux_tools=(
        "trash-cli"
        "vtop"
        "gtop"
    )

    for tool in "${linux_tools[@]}"; do
        if ! npm list -g "$tool" &> /dev/null; then
            show_info "Instalando $tool (Linux)..."
            npm install -g "$tool" --silent
        fi
    done
}

install_windows_npm_tools() {
    local windows_tools=(
        "windows-build-tools"
        "node-gyp"
    )

    for tool in "${windows_tools[@]}"; do
        if ! npm list -g "$tool" &> /dev/null; then
            show_info "Instalando $tool (Windows)..."
            npm install -g "$tool" --silent
        fi
    done
}

configure_npm() {
    show_info "Configurando npm..."

    # Configurar registro npm
    npm config set registry https://registry.npmjs.org/

    # Configurar cache directory
    npm config set cache ~/.npm

    # Configurar timeouts (usando opciones válidas)
    npm config set fetch-timeout 60000
    npm config set fetch-retry-mintimeout 10000
    npm config set fetch-retry-maxtimeout 60000

    # Configurar save-exact
    npm config set save-exact true

    # Configurar progress
    npm config set progress false

    # Configurar init defaults
    npm config set init-author-name "$(git config user.name 2>/dev/null || echo 'Developer')"
    npm config set init-author-email "$(git config user.email 2>/dev/null || echo 'developer@example.com')"
    npm config set init-license "MIT"
    npm config set init-version "1.0.0"

    show_status "npm configurado correctamente"
}

# Función para verificar herramientas npm instaladas
check_npm_tools() {
    show_step "Verificando herramientas npm instaladas..."

    if ! command -v npm &> /dev/null; then
        show_error "npm no está disponible"
        return 1
    fi

    show_info "Versión de npm: $(npm --version)"
    show_info "Versión de Node.js: $(node --version)"

    # Verificar herramientas específicas
    local essential_tools=(
        "live-server"
        "prettier"
        "eslint"
        "typescript"
        "nodemon"
    )

    for tool in "${essential_tools[@]}"; do
        if command -v "$tool" &> /dev/null; then
            show_status "$tool disponible"
        else
            show_warning "$tool no disponible"
        fi
    done

    # Mostrar paquetes globales instalados
    show_info "Paquetes globales instalados:"
    npm list -g --depth=0 | head -20
}

# Función para actualizar herramientas npm
update_npm_tools() {
    show_step "Actualizando herramientas npm..."

    if ! command -v npm &> /dev/null; then
        show_error "npm no está disponible"
        return 1
    fi

    # Verificar actualizaciones disponibles
    if command -v npm-check-updates &> /dev/null; then
        show_info "Verificando actualizaciones globales..."
        npm-check-updates -g
    fi

    # Actualizar npm
    npm update -g npm

    # Actualizar herramientas específicas
    local tools_to_update=(
        "live-server"
        "prettier"
        "eslint"
        "typescript"
        "nodemon"
        "create-react-app"
        "vue-cli"
        "@angular/cli"
    )

    for tool in "${tools_to_update[@]}"; do
        if npm list -g "$tool" &> /dev/null; then
            show_info "Actualizando $tool..."
            npm update -g "$tool"
        fi
    done

    show_status "Herramientas npm actualizadas"
}

# Función para limpiar cache npm
clean_npm_cache() {
    show_step "Limpiando cache npm..."

    if command -v npm &> /dev/null; then
        npm cache clean --force
        show_status "Cache npm limpiado"
    fi
}

# Función para instalar dependencias de desarrollo comunes
install_dev_dependencies() {
    show_step "Instalando dependencias de desarrollo comunes..."

    # Crear package.json temporal si no existe
    if [[ ! -f "package.json" ]]; then
        npm init -y > /dev/null 2>&1
    fi

    # Dependencias comunes de desarrollo
    local dev_deps=(
        "eslint"
        "prettier"
        "husky"
        "lint-staged"
        "commitizen"
        "standard-version"
        "jest"
        "nodemon"
        "concurrently"
        "cross-env"
    )

    for dep in "${dev_deps[@]}"; do
        show_info "Instalando $dep como devDependency..."
        npm install --save-dev "$dep" --silent
    done

    show_status "Dependencias de desarrollo instaladas"
}
