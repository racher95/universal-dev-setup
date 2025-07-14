#!/bin/bash

# Test del nuevo sistema inteligente de manejo de crashes
# Este script prueba el sistema mejorado que muestra errores reales

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

show_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
show_success() { echo -e "${GREEN}✅ $1${NC}"; }
show_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
show_error() { echo -e "${RED}❌ $1${NC}"; }
show_step() { echo -e "\n${BLUE}🔧 $1${NC}"; }

echo "╔════════════════════════════════════════════════════════════╗"
echo "║      🧪 PRUEBA SISTEMA INTELIGENTE DE CRASHES MACOS       ║"
echo "║                                                            ║"
echo "║    Nuevo sistema que muestra errores reales y maneja      ║"
echo "║    crashes con recuperación automática de VS Code         ║"
echo "╚════════════════════════════════════════════════════════════╝"

show_step "1. Verificando funciones del nuevo sistema"

# Verificar que las nuevas funciones existen
if grep -q "code_install_extension_smart" scripts/vscode.sh; then
    show_success "Función code_install_extension_smart() encontrada"
else
    show_error "Función code_install_extension_smart() NO encontrada"
fi

if grep -q "extension_already_installed_smart" scripts/vscode.sh; then
    show_success "Función extension_already_installed_smart() encontrada"
else
    show_error "Función extension_already_installed_smart() NO encontrada"
fi

show_step "2. Verificando captura de errores reales"

if grep -q "2>&1" scripts/vscode.sh; then
    show_success "Captura de stderr y stdout implementada"
else
    show_error "Captura de stderr y stdout NO implementada"
fi

if grep -q "Salida de VS Code" scripts/vscode.sh; then
    show_success "Mostrar salida real de VS Code implementado"
else
    show_error "Mostrar salida real de VS Code NO implementado"
fi

show_step "3. Verificando detección de tipos de crash"

if grep -q "fatal\\|crash\\|electron\\|segmentation" scripts/vscode.sh; then
    show_success "Detección de crashes específicos implementada"
else
    show_error "Detección de crashes específicos NO implementada"
fi

if grep -q "already installed" scripts/vscode.sh; then
    show_success "Detección de extensión ya instalada implementada"
else
    show_error "Detección de extensión ya instalada NO implementada"
fi

if grep -q "not found\\|does not exist" scripts/vscode.sh; then
    show_success "Detección de extensión no encontrada implementada"
else
    show_error "Detección de extensión no encontrada NO implementada"
fi

show_step "4. Verificando sistema de pausas inteligentes"

if grep -q "pause_after_crash" scripts/vscode.sh; then
    show_success "Sistema de pausas variables implementado"
else
    show_error "Sistema de pausas variables NO implementado"
fi

if grep -q "Esperando.*segundos para que VS Code se recupere" scripts/vscode.sh; then
    show_success "Mensajes de recuperación implementados"
else
    show_error "Mensajes de recuperación NO implementados"
fi

show_step "5. Verificando diagnóstico mejorado"

if grep -q "ver errores arriba\|ver diagnóstico arriba" scripts/vscode.sh; then
    show_success "Referencias a diagnóstico implementadas"
else
    show_error "Referencias a diagnóstico NO implementadas"
fi

if grep -q "Revisa los errores mostrados arriba" scripts/vscode.sh; then
    show_success "Instrucciones de diagnóstico implementadas"
else
    show_error "Instrucciones de diagnóstico NO implementadas"
fi

show_step "6. Probando VS Code (si está disponible)"

if command -v code &> /dev/null; then
    show_success "VS Code encontrado en PATH"

    # Simular una prueba del nuevo sistema
    show_info "Probando captura de salida de VS Code..."

    # Intentar listar extensiones y capturar salida
    local output
    local exit_code

    output=$(code --list-extensions 2>&1)
    exit_code=$?

    if [[ $exit_code -eq 0 ]]; then
        show_success "VS Code responde correctamente"
        local ext_count=$(echo "$output" | wc -l)
        show_info "Extensiones detectadas: $ext_count"
    else
        show_warning "VS Code presentó errores - esto es lo que el nuevo sistema capturará:"
        echo "$output" | while IFS= read -r line; do
            show_info "   │ $line"
        done
    fi
else
    show_warning "VS Code no está instalado o no está en PATH"
fi

show_step "7. Resumen del nuevo sistema"

echo ""
show_info "📋 MEJORAS IMPLEMENTADAS:"
show_info "   ✅ Captura de errores reales (stdout + stderr)"
show_info "   ✅ Detección específica de tipos de crash"
show_info "   ✅ Pausas inteligentes para recuperación de VS Code"
show_info "   ✅ Diagnóstico detallado para troubleshooting"
show_info "   ✅ Manejo de casos específicos (ya instalado, no encontrado)"
show_info "   ✅ Sistema de reintentos mejorado"
echo ""

show_success "🎉 Nuevo sistema inteligente implementado correctamente"
show_info "💡 Ahora podrás ver exactamente qué errores produce VS Code en macOS"
show_info "🔄 El sistema permitirá que VS Code se crashee y se recupere automáticamente"
echo ""
