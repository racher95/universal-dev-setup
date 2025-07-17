#!/bin/bash

# Script de Diagnóstico Específico para macOS
# USAR ESTE SCRIPT ANTES DE EJECUTAR LA INSTALACIÓN COMPLETA EN macOS

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🍎 DIAGNÓSTICO PRE-INSTALACIÓN macOS${NC}"
echo -e "${YELLOW}Este script debe ejecutarse EN macOS antes del install.sh${NC}"
echo ""

# Verificar que estamos en macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo -e "${RED}❌ ERROR: Este script debe ejecutarse en macOS${NC}"
    echo -e "${YELLOW}   Sistema detectado: $OSTYPE${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Sistema macOS detectado: $OSTYPE${NC}"
echo ""

# Diagnóstico 1: VS Code instalación
echo -e "${BLUE}📋 1. Verificando instalación de VS Code...${NC}"

if command -v code &> /dev/null; then
    echo -e "${GREEN}✅ VS Code encontrado en PATH${NC}"
    echo "   Versión: $(code --version | head -1)"
    echo "   Ubicación: $(which code)"
else
    echo -e "${RED}❌ VS Code NO encontrado en PATH${NC}"
    echo -e "${YELLOW}   Instala VS Code desde: https://code.visualstudio.com/${NC}"
    echo -e "${YELLOW}   Asegúrate de añadirlo al PATH${NC}"
fi

echo ""

# Diagnóstico 2: Directorio de configuración
echo -e "${BLUE}📂 2. Verificando directorio de configuración...${NC}"

MACOS_VSCODE_DIR="$HOME/Library/Application Support/Code/User"
echo "   Directorio esperado: $MACOS_VSCODE_DIR"

if [[ -d "$MACOS_VSCODE_DIR" ]]; then
    echo -e "${GREEN}✅ Directorio de configuración existe${NC}"
    echo "   Permisos: $(ls -ld "$MACOS_VSCODE_DIR" | awk '{print $1}')"

    if [[ -w "$MACOS_VSCODE_DIR" ]]; then
        echo -e "${GREEN}✅ Directorio escribible${NC}"
    else
        echo -e "${RED}❌ Directorio NO escribible${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  Directorio no existe (se creará)${NC}"

    # Intentar crear
    if mkdir -p "$MACOS_VSCODE_DIR" 2>/dev/null; then
        echo -e "${GREEN}✅ Directorio creado exitosamente${NC}"
    else
        echo -e "${RED}❌ No se puede crear directorio${NC}"
    fi
fi

echo ""

# Diagnóstico 3: Comandos específicos de macOS
echo -e "${BLUE}🔧 3. Verificando comandos específicos de macOS...${NC}"

# Probar sed (eliminación de última línea)
echo "   • Probando comando 'sed' para eliminar última línea..."
echo -e "línea1\nlínea2\nlínea3" > /tmp/test_sed.txt
if sed '$d' /tmp/test_sed.txt > /tmp/test_sed_result.txt 2>/dev/null; then
    if [[ $(wc -l < /tmp/test_sed_result.txt) -eq 2 ]]; then
        echo -e "${GREEN}✅ sed funciona correctamente${NC}"
    else
        echo -e "${RED}❌ sed no funciona como esperado${NC}"
    fi
else
    echo -e "${RED}❌ sed falló${NC}"
fi
rm -f /tmp/test_sed.txt /tmp/test_sed_result.txt

# Probar wc -l
echo "   • Probando comando 'wc -l'..."
if echo -e "línea1\nlínea2" | wc -l > /dev/null 2>&1; then
    echo -e "${GREEN}✅ wc -l funciona${NC}"
else
    echo -e "${RED}❌ wc -l falló${NC}"
fi

# Probar grep -q
echo "   • Probando comando 'grep -q'..."
if echo "test" | grep -q "test" 2>/dev/null; then
    echo -e "${GREEN}✅ grep -q funciona${NC}"
else
    echo -e "${RED}❌ grep -q falló${NC}"
fi

echo ""

# Diagnóstico 4: Extensiones actuales
echo -e "${BLUE}📦 4. Verificando extensiones actuales...${NC}"

if command -v code &> /dev/null; then
    echo "   • Intentando listar extensiones..."
    if extensions_output=$(code --list-extensions 2>&1); then
        extension_count=$(echo "$extensions_output" | wc -l)
        echo -e "${GREEN}✅ Comando funciona - $extension_count extensiones instaladas${NC}"

        if [[ $extension_count -gt 0 ]]; then
            echo "   📋 Extensiones actuales:"
            echo "$extensions_output" | head -5 | while read ext; do
                echo "      • $ext"
            done
            if [[ $extension_count -gt 5 ]]; then
                echo "      ... y $((extension_count - 5)) más"
            fi
        fi
    else
        echo -e "${RED}❌ Error listando extensiones:${NC}"
        echo "$extensions_output" | while read line; do
            echo -e "${RED}   │ $line${NC}"
        done
    fi
else
    echo -e "${YELLOW}⚠️  VS Code no disponible${NC}"
fi

echo ""

# Diagnóstico 5: Prueba de instalación simple
echo -e "${BLUE}🧪 5. Prueba de instalación simple...${NC}"

if command -v code &> /dev/null; then
    echo "   • Probando instalación de extensión simple..."

    # Intentar instalar una extensión ligera como prueba
    test_extension="ms-vscode.hexeditor"

    echo "   📦 Probando: $test_extension"
    if install_output=$(code --install-extension "$test_extension" --force 2>&1); then
        echo -e "${GREEN}✅ Instalación de prueba exitosa${NC}"
        echo "   📋 Salida:"
        echo "$install_output" | while read line; do
            echo "      │ $line"
        done
    else
        echo -e "${RED}❌ Instalación de prueba falló${NC}"
        echo "   📋 Errores:"
        echo "$install_output" | while read line; do
            echo -e "${RED}      │ $line${NC}"
        done
    fi
else
    echo -e "${YELLOW}⚠️  VS Code no disponible para prueba${NC}"
fi

echo ""

# Resumen final
echo -e "${BLUE}📋 RESUMEN DEL DIAGNÓSTICO:${NC}"
echo ""

# Verificar resultados críticos
critical_pass=true

if ! command -v code &> /dev/null; then
    echo -e "${RED}❌ CRÍTICO: VS Code no está instalado${NC}"
    critical_pass=false
fi

if [[ ! -d "$MACOS_VSCODE_DIR" ]] && ! mkdir -p "$MACOS_VSCODE_DIR" 2>/dev/null; then
    echo -e "${RED}❌ CRÍTICO: No se puede acceder al directorio de configuración${NC}"
    critical_pass=false
fi

if $critical_pass; then
    echo -e "${GREEN}✅ DIAGNÓSTICO APROBADO${NC}"
    echo -e "${GREEN}   El sistema está listo para ejecutar install.sh${NC}"
    echo ""
    echo -e "${BLUE}📋 PRÓXIMOS PASOS:${NC}"
    echo "1. 🚀 Ejecuta: ./install.sh"
    echo "2. 🔧 Selecciona opción 6 (VS Code)"
    echo "3. 📋 Monitorea la salida de errores"
    echo "4. 🔄 Reinicia VS Code después de la instalación"
else
    echo -e "${RED}❌ DIAGNÓSTICO FALLÓ${NC}"
    echo -e "${RED}   Corrige los problemas críticos antes de continuar${NC}"
fi

echo ""
echo -e "${YELLOW}💡 Este diagnóstico ayudará a identificar problemas específicos de macOS${NC}"
