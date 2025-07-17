#!/bin/bash

# Verificador de Extensiones VS Code
# Compara las extensiones instaladas vs la lista esperada

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}📋 VERIFICADOR DE EXTENSIONES VS CODE${NC}"
echo ""

# Lista completa de extensiones esperadas
expected_extensions=(
    "ms-ceintl.vscode-language-pack-es"
    "esbenp.prettier-vscode"
    "dbaeumer.vscode-eslint"
    "ms-vscode.vscode-typescript-next"
    "pkief.material-icon-theme"
    "zhuangtongfa.material-theme"
    "dracula-theme.theme-dracula"
    "ritwickdey.liveserver"
    "formulahendry.auto-rename-tag"
    "christian-kohler.path-intellisense"
    "bradlc.vscode-tailwindcss"
    "eamodio.gitlens"
    "mhutchie.git-graph"
    "github.vscode-github-actions"
    "github.vscode-pull-request-github"
ms-vsliveshare.vsliveshare
    "usernamehw.errorlens"
    "streetsidesoftware.code-spell-checker"
    "gruntfuggly.todo-tree"
    "ms-vscode.hexeditor"
    "ms-python.python"
    "ms-vscode.cpptools"
    "rust-lang.rust-analyzer"
    "golang.go"
)

# Obtener extensiones instaladas
echo -e "${BLUE}🔍 Obteniendo lista de extensiones instaladas...${NC}"
if ! installed_extensions=$(code --list-extensions 2>/dev/null); then
    echo -e "${RED}❌ Error: No se puede obtener lista de extensiones${NC}"
    echo "   Asegúrate de que VS Code esté instalado y en PATH"
    exit 1
fi

# Contadores
total_expected=${#expected_extensions[@]}
installed_count=0
missing_count=0

echo -e "${BLUE}📊 ANÁLISIS DE EXTENSIONES:${NC}"
echo ""

# Verificar cada extensión esperada
echo -e "${BLUE}✅ EXTENSIONES INSTALADAS:${NC}"
for ext in "${expected_extensions[@]}"; do
    if echo "$installed_extensions" | grep -q "^$ext$"; then
        echo -e "${GREEN}  ✅ $ext${NC}"
        ((installed_count++))
    fi
done

echo ""
echo -e "${YELLOW}❌ EXTENSIONES FALTANTES:${NC}"
for ext in "${expected_extensions[@]}"; do
    if ! echo "$installed_extensions" | grep -q "^$ext$"; then
        echo -e "${RED}  ❌ $ext${NC}"
        ((missing_count++))
    fi
done

echo ""
echo -e "${BLUE}📋 RESUMEN:${NC}"
echo -e "${GREEN}  ✅ Instaladas: $installed_count de $total_expected${NC}"
echo -e "${RED}  ❌ Faltantes: $missing_count de $total_expected${NC}"

# Calcular porcentaje
percentage=$((installed_count * 100 / total_expected))
echo -e "${BLUE}  📊 Progreso: $percentage%${NC}"

echo ""

# Extensiones adicionales (no esperadas)
echo -e "${BLUE}🔍 EXTENSIONES ADICIONALES INSTALADAS:${NC}"
additional_found=false
while IFS= read -r ext; do
    if [[ -n "$ext" ]]; then
        found=false
        for expected in "${expected_extensions[@]}"; do
            if [[ "$ext" == "$expected" ]]; then
                found=true
                break
            fi
        done
        if [[ "$found" == false ]]; then
            echo -e "${YELLOW}  + $ext${NC}"
            additional_found=true
        fi
    fi
done <<< "$installed_extensions"

if [[ "$additional_found" == false ]]; then
    echo -e "${BLUE}  (Ninguna extensión adicional encontrada)${NC}"
fi

echo ""

# Recomendaciones
if [[ $missing_count -gt 0 ]]; then
    echo -e "${YELLOW}💡 RECOMENDACIONES:${NC}"
    echo "  1. Ejecuta nuevamente el script de instalación"
    echo "  2. Instala manualmente las extensiones faltantes"
    echo "  3. Verifica que no haya errores de red o permisos"
    echo ""

    echo -e "${BLUE}📋 COMANDOS PARA INSTALAR FALTANTES:${NC}"
    for ext in "${expected_extensions[@]}"; do
        if ! echo "$installed_extensions" | grep -q "^$ext$"; then
            echo "  code --install-extension $ext"
        fi
    done
else
    echo -e "${GREEN}🎉 ¡PERFECTO! Todas las extensiones están instaladas${NC}"
fi

echo ""
echo -e "${BLUE}📋 Total de extensiones instaladas: $(echo "$installed_extensions" | wc -l)${NC}"
