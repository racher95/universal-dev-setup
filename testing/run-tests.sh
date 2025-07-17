#!/bin/bash

# 🧪 Script de Pruebas - Universal Development Setup
# Pruebas automatizadas para verificar el funcionamiento del sistema en todas las plataformas

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuración de pruebas
TEST_DIR="test-results"
TEST_LOG="$TEST_DIR/test-$(date +%Y%m%d-%H%M%S).log"
mkdir -p "$TEST_DIR"

# Contadores
TESTS_TOTAL=0
TESTS_PASSED=0
TESTS_FAILED=0

# Funciones de testing
log_test() {
    local message="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $message" >> "$TEST_LOG"
}

test_start() {
    echo "=== UNIVERSAL DEVELOPMENT SETUP - PRUEBAS AUTOMATIZADAS ===" > "$TEST_LOG"
    echo "Fecha: $(date)" >> "$TEST_LOG"
    echo "Sistema: $(uname -a)" >> "$TEST_LOG"
    echo "====================================================" >> "$TEST_LOG"
    echo "" >> "$TEST_LOG"
}

test_pass() {
    local test_name="$1"
    ((TESTS_TOTAL++))
    ((TESTS_PASSED++))
    echo -e "${GREEN}✅ PASS: $test_name${NC}"
    log_test "PASS: $test_name"
}

test_fail() {
    local test_name="$1"
    local reason="$2"
    ((TESTS_TOTAL++))
    ((TESTS_FAILED++))
    echo -e "${RED}❌ FAIL: $test_name${NC}"
    if [[ -n "$reason" ]]; then
        echo -e "   ${YELLOW}Razón: $reason${NC}"
        log_test "FAIL: $test_name - $reason"
    else
        log_test "FAIL: $test_name"
    fi
}

test_skip() {
    local test_name="$1"
    local reason="$2"
    echo -e "${BLUE}⏭️  SKIP: $test_name${NC}"
    if [[ -n "$reason" ]]; then
        echo -e "   ${BLUE}Razón: $reason${NC}"
        log_test "SKIP: $test_name - $reason"
    else
        log_test "SKIP: $test_name"
    fi
}

run_test() {
    local test_name="$1"
    local test_command="$2"

    echo -e "${CYAN}🔍 Ejecutando: $test_name${NC}"

    if eval "$test_command" &>/dev/null; then
        test_pass "$test_name"
    else
        test_fail "$test_name"
    fi
}

# Pruebas del sistema
show_header() {
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                    🧪 PRUEBAS AUTOMATIZADAS                  ║"
    echo "║              Universal Development Setup                     ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

test_system_detection() {
    echo -e "\n${YELLOW}📋 PRUEBAS DE DETECCIÓN DEL SISTEMA${NC}"
    echo "════════════════════════════════════════════════"

    # Detectar sistema
    OS_TYPE="$(uname -s)"
    if [[ -n "$OS_TYPE" ]]; then
        test_pass "Detección de tipo de OS ($OS_TYPE)"
    else
        test_fail "Detección de tipo de OS"
    fi

    # Verificar arquitectura
    ARCH="$(uname -m)"
    if [[ -n "$ARCH" ]]; then
        test_pass "Detección de arquitectura ($ARCH)"
    else
        test_fail "Detección de arquitectura"
    fi

    # Verificar kernel
    KERNEL="$(uname -r)"
    if [[ -n "$KERNEL" ]]; then
        test_pass "Detección de kernel ($KERNEL)"
    else
        test_fail "Detección de kernel"
    fi
}

test_script_files() {
    echo -e "\n${YELLOW}📁 PRUEBAS DE ARCHIVOS DEL SCRIPT${NC}"
    echo "════════════════════════════════════════════════"

    # Verificar archivo principal
    if [[ -f "install.sh" ]]; then
        test_pass "Archivo install.sh existe"

        # Verificar permisos de ejecución
        if [[ -x "install.sh" ]]; then
            test_pass "install.sh es ejecutable"
        else
            test_fail "install.sh no es ejecutable"
        fi
    else
        test_fail "Archivo install.sh no encontrado"
    fi

    # Verificar directorio de scripts
    if [[ -d "scripts" ]]; then
        test_pass "Directorio scripts/ existe"

        # Verificar scripts individuales
        for script in dependencies.sh fonts.sh vscode.sh npm-tools.sh git-config.sh; do
            if [[ -f "scripts/$script" ]]; then
                test_pass "Script scripts/$script existe"
            else
                test_fail "Script scripts/$script no encontrado"
            fi
        done
    else
        test_fail "Directorio scripts/ no encontrado"
    fi

    # Verificar archivos de documentación
    for doc in README.md LOGGING.md WINDOWS.md; do
        if [[ -f "$doc" ]]; then
            test_pass "Documentación $doc existe"
        else
            test_fail "Documentación $doc no encontrada"
        fi
    done
}

test_dependencies() {
    echo -e "\n${YELLOW}🔧 PRUEBAS DE DEPENDENCIAS${NC}"
    echo "════════════════════════════════════════════════"

    # Verificar bash
    run_test "Bash disponible" "command -v bash"

    # Verificar comandos básicos
    run_test "Comando uname" "command -v uname"
    run_test "Comando date" "command -v date"
    run_test "Comando mkdir" "command -v mkdir"
    run_test "Comando chmod" "command -v chmod"

    # Verificar git
    if command -v git &>/dev/null; then
        test_pass "Git disponible ($(git --version | cut -d' ' -f3))"
    else
        test_fail "Git no disponible"
    fi

    # Verificar curl o wget
    if command -v curl &>/dev/null; then
        test_pass "curl disponible"
    elif command -v wget &>/dev/null; then
        test_pass "wget disponible"
    else
        test_fail "Ni curl ni wget disponibles"
    fi
}

test_logging_system() {
    echo -e "\n${YELLOW}📋 PRUEBAS DEL SISTEMA DE LOGGING${NC}"
    echo "════════════════════════════════════════════════"

    # Verificar directorio de logs
    if mkdir -p "logs" 2>/dev/null; then
        test_pass "Directorio logs/ se puede crear"
    else
        test_fail "No se puede crear directorio logs/"
    fi

    # Verificar escritura de logs
    local test_log="logs/test-$(date +%s).log"
    if echo "Test log entry" > "$test_log" 2>/dev/null; then
        test_pass "Escritura de logs funciona"
        rm -f "$test_log" 2>/dev/null
    else
        test_fail "No se pueden escribir logs"
    fi

    # Verificar script de visualización de logs
    if [[ -f "view-logs.sh" ]] && [[ -x "view-logs.sh" ]]; then
        test_pass "Script view-logs.sh disponible y ejecutable"
    else
        test_fail "Script view-logs.sh no disponible o no ejecutable"
    fi
}

test_vscode_compatibility() {
    echo -e "\n${YELLOW}🔌 PRUEBAS DE COMPATIBILIDAD VS CODE${NC}"
    echo "════════════════════════════════════════════════"

    # Verificar si VS Code está instalado
    if command -v code &>/dev/null; then
        test_pass "VS Code encontrado en PATH"

        # Verificar versión
        local vscode_version=$(code --version 2>/dev/null | head -n1)
        if [[ -n "$vscode_version" ]]; then
            test_pass "Versión VS Code detectada ($vscode_version)"
        else
            test_fail "No se puede detectar versión VS Code"
        fi

        # Verificar extensiones
        if code --list-extensions &>/dev/null; then
            test_pass "Comando de extensiones VS Code funciona"
        else
            test_fail "Comando de extensiones VS Code no funciona"
        fi
    else
        test_skip "VS Code no está instalado" "No es requerido para las pruebas"
    fi
}

test_platform_specific() {
    echo -e "\n${YELLOW}🖥️  PRUEBAS ESPECÍFICAS DE PLATAFORMA${NC}"
    echo "════════════════════════════════════════════════"

    OS_TYPE="$(uname -s)"
    case "$OS_TYPE" in
        "Darwin")
            echo -e "${BLUE}Ejecutando pruebas para macOS...${NC}"
            run_test "Comando sw_vers (macOS)" "command -v sw_vers"
            ;;
        "Linux")
            echo -e "${BLUE}Ejecutando pruebas para Linux...${NC}"
            run_test "Comando lsb_release" "command -v lsb_release"

            # Detectar WSL
            if [[ -n "${WSL_DISTRO_NAME}" ]] || [[ -n "${WSLENV}" ]] || [[ "$(uname -r)" == *microsoft* ]]; then
                echo -e "${BLUE}Detectado WSL - Ejecutando pruebas específicas...${NC}"
                test_pass "Detección de WSL"
                run_test "Directorio /mnt/c existe (WSL)" "test -d /mnt/c"
            fi
            ;;
        "CYGWIN"*|"MINGW"*|"MSYS"*)
            echo -e "${BLUE}Ejecutando pruebas para Windows nativo...${NC}"
            run_test "Comando cmd.exe" "command -v cmd.exe"
            ;;
        *)
            test_fail "Sistema operativo no reconocido: $OS_TYPE"
            ;;
    esac
}

show_summary() {
    echo -e "\n${CYAN}📊 RESUMEN DE PRUEBAS${NC}"
    echo "════════════════════════════════════════════════"
    echo -e "Total de pruebas: ${BLUE}$TESTS_TOTAL${NC}"
    echo -e "Pruebas exitosas: ${GREEN}$TESTS_PASSED${NC}"
    echo -e "Pruebas fallidas: ${RED}$TESTS_FAILED${NC}"

    local success_rate=0
    if [[ $TESTS_TOTAL -gt 0 ]]; then
        success_rate=$((TESTS_PASSED * 100 / TESTS_TOTAL))
    fi
    echo -e "Tasa de éxito: ${BLUE}$success_rate%${NC}"

    echo "" >> "$TEST_LOG"
    echo "====================================================" >> "$TEST_LOG"
    echo "RESUMEN DE PRUEBAS:" >> "$TEST_LOG"
    echo "Total: $TESTS_TOTAL" >> "$TEST_LOG"
    echo "Exitosas: $TESTS_PASSED" >> "$TEST_LOG"
    echo "Fallidas: $TESTS_FAILED" >> "$TEST_LOG"
    echo "Tasa de éxito: $success_rate%" >> "$TEST_LOG"
    echo "====================================================" >> "$TEST_LOG"

    echo ""
    echo -e "${CYAN}📋 Log de pruebas guardado en: $TEST_LOG${NC}"

    if [[ $TESTS_FAILED -eq 0 ]]; then
        echo -e "${GREEN}🎉 ¡Todas las pruebas pasaron! El sistema está listo.${NC}"
        return 0
    else
        echo -e "${YELLOW}⚠️  Algunas pruebas fallaron. Revisa el log para detalles.${NC}"
        return 1
    fi
}

# Función principal
main() {
    show_header
    test_start

    echo -e "${BLUE}ℹ️  Ejecutando pruebas automatizadas del sistema...${NC}"
    echo ""

    test_system_detection
    test_script_files
    test_dependencies
    test_logging_system
    test_vscode_compatibility
    test_platform_specific

    show_summary
}

# Verificar si se ejecuta directamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
