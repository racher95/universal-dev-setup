#!/bin/bash

# Verificador de Compatibilidad macOS
# Script para analizar si el código de vscode.sh funcionará correctamente en macOS

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🔍 VERIFICADOR DE COMPATIBILIDAD macOS${NC}"
echo -e "${YELLOW}Analizando vscode.sh para problemas potenciales en macOS...${NC}"
echo ""

# Análisis 1: Comandos específicos de macOS
echo -e "${BLUE}📋 1. Verificando comandos específicos de macOS:${NC}"

# Buscar uso de sed vs head
echo "   • Verificando comando 'sed' para macOS..."
if grep -q "sed '\$d'" scripts/vscode.sh; then
    echo -e "   ${GREEN}✅ sed '\$d' encontrado (correcto para macOS)${NC}"
else
    echo -e "   ${RED}❌ sed '\$d' NO encontrado${NC}"
fi

# Buscar detección de OSTYPE
echo "   • Verificando detección de OSTYPE..."
if grep -q 'OSTYPE.*darwin' scripts/vscode.sh; then
    echo -e "   ${GREEN}✅ Detección de darwin encontrada${NC}"
    grep -n 'OSTYPE.*darwin' scripts/vscode.sh | while read line; do
        echo -e "      ${GREEN}│${NC} $line"
    done
else
    echo -e "   ${RED}❌ Detección de darwin NO encontrada${NC}"
fi

echo ""

# Análisis 2: Paths de configuración
echo -e "${BLUE}📂 2. Verificando paths de configuración:${NC}"

# Buscar referencias a directorios de configuración
echo "   • Buscando \$VSCODE_SETTINGS_DIR..."
if grep -q 'VSCODE_SETTINGS_DIR' scripts/vscode.sh; then
    echo -e "   ${GREEN}✅ VSCODE_SETTINGS_DIR encontrado${NC}"
    echo "   💡 Debe definirse en el script principal para macOS como:"
    echo "      macOS: ~/Library/Application Support/Code/User/"
else
    echo -e "   ${YELLOW}⚠️  VSCODE_SETTINGS_DIR no encontrado en vscode.sh${NC}"
fi

echo ""

# Análisis 3: Comandos problemáticos para macOS
echo -e "${BLUE}⚠️  3. Comandos potencialmente problemáticos:${NC}"

# Buscar comandos que pueden fallar en macOS
problemmatic_commands=(
    "head -n -1"
    "wc -l"
    "grep -q"
)

for cmd in "${problemmatic_commands[@]}"; do
    if grep -q "$cmd" scripts/vscode.sh; then
        echo -e "   ${YELLOW}⚠️  '$cmd' encontrado - verificar compatibilidad${NC}"
        grep -n "$cmd" scripts/vscode.sh | head -3 | while read line; do
            echo -e "      ${YELLOW}│${NC} $line"
        done
    fi
done

echo ""

# Análisis 4: Simulación de lógica macOS
echo -e "${BLUE}🧪 4. Simulando lógica de detección macOS:${NC}"

# Simular OSTYPE de macOS
MOCK_OSTYPE="darwin22.0"
echo "   • Simulando OSTYPE='$MOCK_OSTYPE'"

if [[ "$MOCK_OSTYPE" == "darwin"* ]]; then
    echo -e "   ${GREEN}✅ Detección macOS funcionaría correctamente${NC}"
    echo "   🔄 Se ejecutaría: detect_vscode_macos_issues()"
    echo "   📦 Se usaría: code_install_extension_smart()"
else
    echo -e "   ${RED}❌ Detección macOS FALLARÍA${NC}"
fi

echo ""

# Análisis 5: Problemas específicos identificados
echo -e "${BLUE}🚨 5. PROBLEMAS ESPECÍFICOS IDENTIFICADOS:${NC}"

echo -e "${RED}❌ PROBLEMA 1: Variable VSCODE_SETTINGS_DIR${NC}"
echo "   • No está definida en vscode.sh"
echo "   • Debe definirse según el OS en el script principal"
echo ""

echo -e "${RED}❌ PROBLEMA 2: Dependencias del script principal${NC}"
echo "   • vscode.sh depende de variables del install.sh"
echo "   • Puede fallar si se ejecuta independientemente"
echo ""

echo -e "${YELLOW}⚠️  PROBLEMA 3: Sin validación en macOS real${NC}"
echo "   • El código se escribió desde Linux/WSL"
echo "   • Necesita pruebas en macOS real para confirmar funcionamiento"
echo ""

# Recomendaciones
echo -e "${BLUE}📋 RECOMENDACIONES PARA PRUEBA EN macOS:${NC}"
echo ""
echo "1. 🧪 ANTES de probar en macOS, crear script de diagnóstico"
echo "2. 🔍 Verificar que VSCODE_SETTINGS_DIR esté definido"
echo "3. 📋 Crear log detallado para capturar errores reales"
echo "4. ⚠️  Probar con una extensión simple primero"
echo "5. 🔄 Tener plan de rollback si algo falla"
echo ""

echo -e "${GREEN}✅ Verificación completada${NC}"
echo -e "${YELLOW}💡 CONCLUSIÓN: El código puede tener problemas en macOS real${NC}"
echo -e "${YELLOW}   Se recomienda probar en macOS con mucho cuidado${NC}"
