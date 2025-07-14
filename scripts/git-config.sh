#!/bin/bash

# Módulo de configuración de Git
# Compatible con macOS, Linux, WSL, Windows

configure_git() {
    show_step "Configurando Git..."

    # Verificar que Git esté disponible
    if ! command -v git &> /dev/null; then
        show_error "Git no está disponible"
        show_info "Instala Git primero con la opción de dependencias"
        return 1
    fi

    show_info "Versión de Git: $(git --version)"

    # Verificar configuración actual
    current_name=$(git config --global user.name 2>/dev/null || echo "")
    current_email=$(git config --global user.email 2>/dev/null || echo "")

    if [[ -n "$current_name" && -n "$current_email" ]]; then
        echo ""
        show_info "Configuración actual de Git:"
        echo "  Nombre: $current_name"
        echo "  Email: $current_email"
        echo ""
        read -p "¿Deseas cambiar la configuración? (y/N): " change_config
        if [[ ! "$change_config" =~ ^[Yy]$ ]]; then
            show_status "Configuración de Git mantenida"
            return 0
        fi
    fi

    # Solicitar información del usuario
    echo ""
    show_step "Configuración de usuario Git"
    
    while [[ -z "$git_name" ]]; do
        read -p "📝 Ingresa tu nombre completo: " git_name
        if [[ -z "$git_name" ]]; then
            show_warning "El nombre no puede estar vacío"
        fi
    done

    while [[ -z "$git_email" ]]; do
        read -p "📧 Ingresa tu email: " git_email
        if [[ -z "$git_email" ]]; then
            show_warning "El email no puede estar vacío"
        elif [[ ! "$git_email" =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]; then
            show_warning "Formato de email inválido"
            git_email=""
        fi
    done

    # Configurar Git
    git config --global user.name "$git_name"
    git config --global user.email "$git_email"

    # Configuraciones adicionales recomendadas
    configure_git_defaults

    show_status "Git configurado correctamente"
    echo ""
    show_info "Configuración aplicada:"
    echo "  Nombre: $(git config --global user.name)"
    echo "  Email: $(git config --global user.email)"
}

configure_git_defaults() {
    show_info "Aplicando configuraciones recomendadas..."

    # Configurar editor por defecto
    if command -v code &> /dev/null; then
        git config --global core.editor "code --wait"
        show_info "Editor configurado: VS Code"
    elif command -v vim &> /dev/null; then
        git config --global core.editor "vim"
        show_info "Editor configurado: Vim"
    fi

    # Configurar merge tool
    if command -v code &> /dev/null; then
        git config --global merge.tool vscode
        git config --global mergetool.vscode.cmd 'code --wait $MERGED'
        show_info "Merge tool configurado: VS Code"
    fi

    # Configurar comportamiento de push
    git config --global push.default simple
    git config --global pull.rebase true

    # Configurar colores
    git config --global color.ui auto
    git config --global color.branch auto
    git config --global color.diff auto
    git config --global color.status auto

    # Configurar aliases útiles
    git config --global alias.st status
    git config --global alias.co checkout
    git config --global alias.br branch
    git config --global alias.ci commit
    git config --global alias.lg "log --oneline --graph --decorate --all"
    git config --global alias.last "log -1 HEAD"
    git config --global alias.unstage "reset HEAD --"

    # Configurar line endings según el sistema
    case "$SYSTEM" in
        "Windows"|"WSL")
            git config --global core.autocrlf true
            ;;
        "macOS"|"Linux")
            git config --global core.autocrlf input
            ;;
    esac

    # Configurar cache de credenciales
    case "$SYSTEM" in
        "macOS")
            git config --global credential.helper osxkeychain
            ;;
        "Windows")
            git config --global credential.helper manager-core
            ;;
        "WSL"|"Linux")
            git config --global credential.helper cache
            git config --global credential.helper 'cache --timeout=3600'
            ;;
    esac

    show_info "Configuraciones adicionales aplicadas"
}

check_git_config() {
    show_step "Verificando configuración de Git..."

    if ! command -v git &> /dev/null; then
        show_error "Git no está instalado"
        return 1
    fi

    echo ""
    show_info "Información de Git:"
    echo "  Versión: $(git --version)"
    
    local git_name=$(git config --global user.name 2>/dev/null)
    local git_email=$(git config --global user.email 2>/dev/null)
    
    if [[ -n "$git_name" && -n "$git_email" ]]; then
        show_status "Git configurado correctamente"
        echo "  Nombre: $git_name"
        echo "  Email: $git_email"
    else
        show_warning "Git no está configurado"
        echo "  Use la opción de configuración de Git para configurarlo"
    fi

    local git_editor=$(git config --global core.editor 2>/dev/null)
    if [[ -n "$git_editor" ]]; then
        echo "  Editor: $git_editor"
    fi

    # Verificar GitHub CLI si está disponible
    if command -v gh &> /dev/null; then
        show_status "GitHub CLI disponible: $(gh --version | head -1)"
        if gh auth status &> /dev/null; then
            show_status "GitHub CLI autenticado"
        else
            show_warning "GitHub CLI no autenticado"
            show_info "Ejecuta: gh auth login"
        fi
    else
        show_warning "GitHub CLI no instalado"
        show_info "Instálalo para mejor integración con GitHub"
    fi
}

show_git_help() {
    echo ""
    echo -e "${CYAN}📚 AYUDA DE GIT:${NC}"
    echo "═══════════════════════════════════════"
    echo ""
    echo -e "${YELLOW}🔧 COMANDOS ÚTILES:${NC}"
    echo "• git st          → Estado del repositorio (alias de status)"
    echo "• git co <branch> → Cambiar rama (alias de checkout)"
    echo "• git lg          → Log gráfico bonito"
    echo "• git last        → Último commit"
    echo ""
    echo -e "${YELLOW}🔑 AUTENTICACIÓN GITHUB:${NC}"
    echo "• gh auth login   → Autenticar GitHub CLI"
    echo "• ssh-keygen      → Generar claves SSH"
    echo ""
    echo -e "${YELLOW}🌐 RECURSOS:${NC}"
    echo "• https://git-scm.com/docs"
    echo "• https://cli.github.com/manual/"
    echo ""
}
