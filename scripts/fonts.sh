#!/bin/bash

# Módulo de instalación de fuentes de desarrollo
# Compatible con macOS, Linux, WSL, Windows

install_fonts() {
    show_step "Instalando fuentes de desarrollo para $SYSTEM..."
    
    case "$SYSTEM" in
        "macOS")
            install_macos_fonts
            ;;
        "WSL"|"Linux")
            install_linux_fonts
            ;;
        "Windows")
            install_windows_fonts
            ;;
    esac
    
    show_status "Fuentes de desarrollo instaladas"
}

install_macos_fonts() {
    # Usar Homebrew Cask para fuentes
    if ! brew tap | grep -q "homebrew/cask-fonts"; then
        show_info "Agregando repositorio de fuentes..."
        brew tap homebrew/cask-fonts
    fi
    
    # Lista de fuentes a instalar
    fonts=(
        "font-fira-code"
        "font-jetbrains-mono"
        "font-cascadia-code"
        "font-meslo-lg-nerd-font"
        "font-source-code-pro"
        "font-hack"
    )
    
    for font in "${fonts[@]}"; do
        if ! brew list --cask "$font" &> /dev/null; then
            show_info "Instalando $font..."
            brew install --cask "$font" || show_warning "Error instalando $font"
        else
            show_info "$font ya está instalada"
        fi
    done
}

install_linux_fonts() {
    # Crear directorio de fuentes
    mkdir -p "$FONT_DIR"
    cd /tmp
    
    # Fira Code
    install_font_fira_code
    
    # JetBrains Mono
    install_font_jetbrains_mono
    
    # Cascadia Code
    install_font_cascadia_code
    
    # MesloLGS Nerd Font
    install_font_meslo_nerd
    
    # Source Code Pro
    install_font_source_code_pro
    
    # Hack Font
    install_font_hack
    
    # Actualizar cache de fuentes
    show_info "Actualizando cache de fuentes..."
    sudo fc-cache -f -v > /dev/null 2>&1
}

install_font_fira_code() {
    if [[ ! -f "$FONT_DIR/FiraCode-Regular.ttf" ]]; then
        show_info "Instalando Fira Code..."
        wget -q https://github.com/tonsky/FiraCode/releases/download/6.2/Fira_Code_v6.2.zip
        unzip -q Fira_Code_v6.2.zip
        sudo cp ttf/*.ttf "$FONT_DIR/"
        rm -rf Fira_Code_v6.2.zip ttf/ variable_ttf/
    fi
}

install_font_jetbrains_mono() {
    if [[ ! -f "$FONT_DIR/JetBrainsMono-Regular.ttf" ]]; then
        show_info "Instalando JetBrains Mono..."
        wget -q https://github.com/JetBrains/JetBrainsMono/releases/download/v2.304/JetBrainsMono-2.304.zip
        unzip -q JetBrainsMono-2.304.zip
        sudo cp fonts/ttf/*.ttf "$FONT_DIR/"
        rm -rf JetBrainsMono-2.304.zip fonts/
    fi
}

install_font_cascadia_code() {
    if [[ ! -f "$FONT_DIR/CascadiaCode-Regular.ttf" ]]; then
        show_info "Instalando Cascadia Code..."
        wget -q https://github.com/microsoft/cascadia-code/releases/download/v2111.01/CascadiaCode-2111.01.zip
        unzip -q CascadiaCode-2111.01.zip
        sudo cp ttf/*.ttf "$FONT_DIR/"
        rm -rf CascadiaCode-2111.01.zip ttf/
    fi
}

install_font_meslo_nerd() {
    if [[ ! -f "$FONT_DIR/MesloLGS NF Regular.ttf" ]]; then
        show_info "Instalando MesloLGS Nerd Font..."
        wget -q https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf
        wget -q https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf
        wget -q https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf
        wget -q https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf
        sudo cp "MesloLGS NF"*.ttf "$FONT_DIR/"
        rm -f "MesloLGS NF"*.ttf
    fi
}

install_font_source_code_pro() {
    if [[ ! -f "$FONT_DIR/SourceCodePro-Regular.ttf" ]]; then
        show_info "Instalando Source Code Pro..."
        wget -q https://github.com/adobe-fonts/source-code-pro/releases/download/2.038R-ro%2F1.058R-it%2F1.018R-VAR/TTF-source-code-pro-2.038R-ro-1.058R-it.zip
        unzip -q TTF-source-code-pro-2.038R-ro-1.058R-it.zip
        sudo cp TTF/*.ttf "$FONT_DIR/"
        rm -rf TTF-source-code-pro-2.038R-ro-1.058R-it.zip TTF/
    fi
}

install_font_hack() {
    if [[ ! -f "$FONT_DIR/Hack-Regular.ttf" ]]; then
        show_info "Instalando Hack Font..."
        wget -q https://github.com/source-foundry/Hack/releases/download/v3.003/Hack-v3.003-ttf.zip
        unzip -q Hack-v3.003-ttf.zip
        sudo cp ttf/*.ttf "$FONT_DIR/"
        rm -rf Hack-v3.003-ttf.zip ttf/
    fi
}

install_windows_fonts() {
    show_warning "Instalación de fuentes en Windows requiere permisos de administrador"
    
    if command -v choco &> /dev/null; then
        show_info "Usando Chocolatey para instalar fuentes..."
        choco install -y firacode jetbrainsmono cascadiacodepl hackfont
    else
        show_info "Instalación manual requerida:"
        echo "• Fira Code: https://github.com/tonsky/FiraCode/releases"
        echo "• JetBrains Mono: https://www.jetbrains.com/mono/"
        echo "• Cascadia Code: https://github.com/microsoft/cascadia-code/releases"
        echo "• MesloLGS Nerd Font: https://github.com/romkatv/powerlevel10k-media"
        
        show_info "Descarga las fuentes y haz doble clic para instalar"
    fi
}

# Función para verificar fuentes instaladas
check_fonts() {
    show_step "Verificando fuentes instaladas..."
    
    case "$SYSTEM" in
        "macOS")
            fonts_to_check=(
                "FiraCode-Regular"
                "JetBrainsMono-Regular"
                "CascadiaCode-Regular"
                "MesloLGS NF Regular"
            )
            
            for font in "${fonts_to_check[@]}"; do
                if ls "$FONT_DIR"/*"$font"* &> /dev/null; then
                    show_status "$font encontrada"
                else
                    show_warning "$font no encontrada"
                fi
            done
            ;;
        "WSL"|"Linux")
            fonts_to_check=(
                "FiraCode-Regular.ttf"
                "JetBrainsMono-Regular.ttf"
                "CascadiaCode-Regular.ttf"
                "MesloLGS NF Regular.ttf"
            )
            
            for font in "${fonts_to_check[@]}"; do
                if [[ -f "$FONT_DIR/$font" ]]; then
                    show_status "$font encontrada"
                else
                    show_warning "$font no encontrada"
                fi
            done
            ;;
        "Windows")
            show_info "Verificación de fuentes en Windows requiere PowerShell"
            ;;
    esac
}

# Función para listar fuentes disponibles
list_fonts() {
    show_step "Listando fuentes disponibles..."
    
    case "$SYSTEM" in
        "macOS")
            ls -la "$FONT_DIR"/ | grep -E "\.(ttf|otf)" | head -20
            ;;
        "WSL"|"Linux")
            fc-list | grep -E "(Fira|JetBrains|Cascadia|Meslo)" | head -10
            ;;
        "Windows")
            show_info "Usa 'fc-list' en PowerShell para listar fuentes"
            ;;
    esac
}
