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
    # El repositorio homebrew/cask-fonts fue migrado
    # Las fuentes ahora están disponibles directamente como cask
    show_info "Instalando fuentes desde Homebrew Cask..."

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
    show_step "Instalando fuentes en Windows..."

    # Verificar permisos de administrador
    if ! check_windows_admin; then
        show_warning "Se requieren permisos de administrador para instalar fuentes"
        show_info "Algunas fuentes pueden requerir instalación manual"
    fi

    # Intentar instalación automática con Chocolatey
    if command -v choco &> /dev/null || install_chocolatey_for_fonts; then
        install_fonts_with_chocolatey
    else
        show_info "Instalación manual de fuentes requerida"
        provide_manual_font_instructions
    fi

    # Verificar instalación de fuentes
    verify_windows_fonts
}

# Verificar permisos de administrador para Windows
check_windows_admin() {
    # Intentar crear archivo temporal en directorio de fuentes del sistema
    local test_file="/c/Windows/Fonts/temp_test_$$"
    if touch "$test_file" 2>/dev/null; then
        rm -f "$test_file" 2>/dev/null
        return 0
    fi
    return 1
}

# Instalar Chocolatey específicamente para fuentes
install_chocolatey_for_fonts() {
    show_info "Chocolatey no encontrado. Intentando instalación..."
    
    if ! command -v powershell &> /dev/null && ! command -v pwsh &> /dev/null; then
        show_warning "PowerShell no disponible para instalar Chocolatey"
        return 1
    fi

    # Script simplificado para fuentes
    local install_script='
        try {
            Set-ExecutionPolicy Bypass -Scope Process -Force
            [System.Net.ServicePointManager]::SecurityProtocol = 3072
            iex ((New-Object System.Net.WebClient).DownloadString("https://community.chocolatey.org/install.ps1"))
            Write-Host "Chocolatey instalado exitosamente"
        } catch {
            Write-Host "Error instalando Chocolatey: $_"
            exit 1
        }
    '

    if command -v powershell &> /dev/null; then
        echo "$install_script" | powershell -Command -
    elif command -v pwsh &> /dev/null; then
        echo "$install_script" | pwsh -Command -
    fi

    # Verificar instalación
    sleep 2
    if command -v choco &> /dev/null; then
        show_status "Chocolatey instalado para gestión de fuentes"
        return 0
    else
        show_warning "No se pudo instalar Chocolatey automáticamente"
        return 1
    fi
}

# Instalar fuentes con Chocolatey
install_fonts_with_chocolatey() {
    show_info "Instalando fuentes con Chocolatey..."

    # Lista de fuentes disponibles en Chocolatey
    local fonts=(
        "firacode"
        "jetbrainsmono" 
        "cascadiacodepl"
        "hackfont"
        "sourcecodepro"
        "inconsolata"
    )

    local installed=0
    local failed=0

    # Habilitar confirmación automática para esta sesión
    choco feature enable -n allowGlobalConfirmation

    for font in "${fonts[@]}"; do
        show_info "Instalando fuente: $font..."
        if choco install "$font" -y --no-progress 2>/dev/null; then
            show_status "$font instalada"
            ((installed++))
        else
            show_warning "Error instalando $font"
            ((failed++))
        fi
    done

    show_info "Fuentes procesadas: $installed instaladas, $failed errores"

    # Si Chocolatey falla, intentar método manual
    if [[ $installed -eq 0 ]]; then
        show_warning "Chocolatey no pudo instalar fuentes. Usando método manual..."
        provide_manual_font_instructions
    fi
}

# Proporcionar instrucciones de instalación manual
provide_manual_font_instructions() {
    show_info "=== INSTALACIÓN MANUAL DE FUENTES ==="
    echo ""
    echo "Descarga e instala estas fuentes manualmente:"
    echo ""
    echo "1. Fira Code (Recomendada):"
    echo "   https://github.com/tonsky/FiraCode/releases"
    echo "   - Descarga FiraCode.zip"
    echo "   - Extrae y selecciona todos los archivos .ttf"
    echo "   - Clic derecho → Instalar"
    echo ""
    echo "2. JetBrains Mono:"
    echo "   https://www.jetbrains.com/mono/"
    echo "   - Descarga la fuente"
    echo "   - Instala todos los archivos .ttf"
    echo ""
    echo "3. Cascadia Code (Microsoft):"
    echo "   https://github.com/microsoft/cascadia-code/releases"
    echo "   - Incluida en Windows 11"
    echo "   - Para Windows 10, descargar manualmente"
    echo ""
    echo "4. MesloLGS Nerd Font (Para terminal):"
    echo "   https://github.com/romkatv/powerlevel10k-media"
    echo "   - Descarga los 4 archivos .ttf"
    echo "   - Instala todos"
    echo ""
    echo "💡 Tip: Después de instalar, reinicia VS Code para aplicar las fuentes"
}

# Verificar fuentes instaladas en Windows
verify_windows_fonts() {
    show_step "Verificando fuentes instaladas..."

    # Lista de fuentes a verificar
    local fonts_to_check=(
        "Fira Code"
        "JetBrains Mono"
        "Cascadia Code"
        "Cascadia Mono"
        "MesloLGS NF"
        "Source Code Pro"
        "Inconsolata"
    )

    local found=0
    local total=${#fonts_to_check[@]}

    # Verificar usando PowerShell si está disponible
    if command -v powershell &> /dev/null; then
        show_info "Verificando fuentes con PowerShell..."
        
        for font in "${fonts_to_check[@]}"; do
            local ps_script="
                \$fonts = [System.Drawing.Text.InstalledFontCollection]::new().Families.Name
                if (\$fonts -contains '$font') { 
                    Write-Host 'FOUND'
                } else { 
                    Write-Host 'NOT_FOUND'
                }
            "
            
            local result=$(echo "$ps_script" | powershell -Command -)
            if [[ "$result" == *"FOUND"* ]]; then
                show_status "$font: ✓ Instalada"
                ((found++))
            else
                show_info "$font: ✗ No encontrada"
            fi
        done
    else
        # Verificación alternativa por archivos
        show_info "Verificando fuentes por archivos del sistema..."
        
        local font_dirs=(
            "/c/Windows/Fonts"
            "/c/Users/$USER/AppData/Local/Microsoft/Windows/Fonts"
        )
        
        for font in "${fonts_to_check[@]}"; do
            local found_font=false
            for dir in "${font_dirs[@]}"; do
                if [[ -d "$dir" ]]; then
                    # Buscar archivos de fuente relacionados
                    local font_files=$(find "$dir" -iname "*${font// /}*" -o -iname "*${font//' '/'-'}*" 2>/dev/null | wc -l)
                    if [[ $font_files -gt 0 ]]; then
                        show_status "$font: ✓ Encontrada ($font_files archivos)"
                        ((found++))
                        found_font=true
                        break
                    fi
                fi
            done
            
            if [[ "$found_font" == false ]]; then
                show_info "$font: ✗ No encontrada"
            fi
        done
    fi

    show_info "Fuentes verificadas: $found/$total encontradas"
    
    if [[ $found -eq 0 ]]; then
        show_warning "No se encontraron fuentes de programación"
        show_info "Ejecuta la instalación manual siguiendo las instrucciones anteriores"
        return 1
    elif [[ $found -lt $((total / 2)) ]]; then
        show_warning "Pocas fuentes encontradas. Considera instalar más"
        return 1
    else
        show_status "Suficientes fuentes de programación disponibles"
        return 0
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
            verify_windows_fonts
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
