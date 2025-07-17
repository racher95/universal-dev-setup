#!/bin/bash

# 📋 Visor de Logs - Universal Development Setup
# Script para visualizar y gestionar logs de instalación

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

LOG_DIR="logs"

show_header() {
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                    📋 VISOR DE LOGS                          ║"
    echo "║              Universal Development Setup                     ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

show_usage() {
    echo -e "${BLUE}Uso: $0 [comando]${NC}"
    echo ""
    echo "Comandos disponibles:"
    echo "  list        - Listar todos los logs disponibles"
    echo "  latest      - Mostrar el log más reciente"
    echo "  errors      - Mostrar solo logs de errores"
    echo "  clean       - Limpiar logs antiguos (>7 días)"
    echo "  compress    - Comprimir logs para envío"
    echo "  summary     - Resumen de logs"
    echo ""
    echo "Ejemplos:"
    echo "  $0 list"
    echo "  $0 latest"
    echo "  $0 errors"
}

list_logs() {
    echo -e "${YELLOW}📁 Logs disponibles:${NC}"
    echo "════════════════════════════════════════"

    if [[ ! -d "$LOG_DIR" ]] || [[ -z "$(ls -A $LOG_DIR 2>/dev/null)" ]]; then
        echo -e "${RED}❌ No se encontraron logs en $LOG_DIR${NC}"
        return 1
    fi

    echo -e "${BLUE}Logs de instalación:${NC}"
    ls -la "$LOG_DIR"/installation-*.log 2>/dev/null | while read -r line; do
        echo "  📋 $line"
    done

    echo -e "\n${YELLOW}Logs de errores:${NC}"
    ls -la "$LOG_DIR"/errors-*.log 2>/dev/null | while read -r line; do
        echo "  ❌ $line"
    done

    echo -e "\n${CYAN}Logs de diagnóstico:${NC}"
    ls -la "$LOG_DIR"/diagnostic-*.log 2>/dev/null | while read -r line; do
        echo "  🔍 $line"
    done
}

show_latest() {
    echo -e "${YELLOW}📋 Log más reciente:${NC}"
    echo "════════════════════════════════════════"

    latest_log=$(ls -t "$LOG_DIR"/*.log 2>/dev/null | head -n1)

    if [[ -z "$latest_log" ]]; then
        echo -e "${RED}❌ No se encontraron logs${NC}"
        return 1
    fi

    echo -e "${BLUE}Archivo: $latest_log${NC}"
    echo -e "${GREEN}Contenido:${NC}"
    echo "----------------------------------------"
    cat "$latest_log"
}

show_errors() {
    echo -e "${RED}❌ Logs de errores:${NC}"
    echo "════════════════════════════════════════"

    error_logs=$(ls "$LOG_DIR"/errors-*.log 2>/dev/null)

    if [[ -z "$error_logs" ]]; then
        echo -e "${GREEN}✅ No se encontraron logs de errores${NC}"
        return 0
    fi

    for log in $error_logs; do
        echo -e "\n${YELLOW}📁 Archivo: $log${NC}"
        echo "----------------------------------------"
        cat "$log"
        echo "----------------------------------------"
    done
}

clean_logs() {
    echo -e "${YELLOW}🧹 Limpiando logs antiguos (>7 días)...${NC}"

    if [[ ! -d "$LOG_DIR" ]]; then
        echo -e "${RED}❌ Directorio de logs no existe${NC}"
        return 1
    fi

    old_logs=$(find "$LOG_DIR" -name "*.log" -mtime +7 2>/dev/null)

    if [[ -z "$old_logs" ]]; then
        echo -e "${GREEN}✅ No hay logs antiguos para limpiar${NC}"
        return 0
    fi

    echo "Logs a eliminar:"
    echo "$old_logs"
    echo ""
    read -p "¿Continuar? (y/N): " -r

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        find "$LOG_DIR" -name "*.log" -mtime +7 -delete
        echo -e "${GREEN}✅ Logs antiguos eliminados${NC}"
    else
        echo -e "${BLUE}ℹ️  Operación cancelada${NC}"
    fi
}

compress_logs() {
    echo -e "${BLUE}📦 Comprimiendo logs para envío...${NC}"

    if [[ ! -d "$LOG_DIR" ]] || [[ -z "$(ls -A $LOG_DIR 2>/dev/null)" ]]; then
        echo -e "${RED}❌ No hay logs para comprimir${NC}"
        return 1
    fi

    timestamp=$(date +"%Y%m%d-%H%M%S")
    archive_name="logs-$timestamp.tar.gz"

    tar -czf "$archive_name" "$LOG_DIR"/ 2>/dev/null

    if [[ $? -eq 0 ]]; then
        size=$(du -h "$archive_name" | cut -f1)
        echo -e "${GREEN}✅ Logs comprimidos en: $archive_name ($size)${NC}"
        echo -e "${BLUE}ℹ️  Puedes compartir este archivo para soporte${NC}"
    else
        echo -e "${RED}❌ Error al comprimir logs${NC}"
        return 1
    fi
}

show_summary() {
    echo -e "${CYAN}📊 Resumen de logs:${NC}"
    echo "════════════════════════════════════════"

    if [[ ! -d "$LOG_DIR" ]]; then
        echo -e "${RED}❌ Directorio de logs no existe${NC}"
        return 1
    fi

    total_logs=$(ls "$LOG_DIR"/*.log 2>/dev/null | wc -l)
    installation_logs=$(ls "$LOG_DIR"/installation-*.log 2>/dev/null | wc -l)
    error_logs=$(ls "$LOG_DIR"/errors-*.log 2>/dev/null | wc -l)
    diagnostic_logs=$(ls "$LOG_DIR"/diagnostic-*.log 2>/dev/null | wc -l)

    echo -e "${BLUE}Total de logs: $total_logs${NC}"
    echo -e "${GREEN}📋 Logs de instalación: $installation_logs${NC}"
    echo -e "${RED}❌ Logs de errores: $error_logs${NC}"
    echo -e "${CYAN}🔍 Logs de diagnóstico: $diagnostic_logs${NC}"

    if [[ $total_logs -gt 0 ]]; then
        echo ""
        echo -e "${YELLOW}Último log creado:${NC}"
        ls -t "$LOG_DIR"/*.log 2>/dev/null | head -n1 | xargs ls -la
    fi

    # Espacio usado
    if [[ -d "$LOG_DIR" ]]; then
        size=$(du -sh "$LOG_DIR" 2>/dev/null | cut -f1)
        echo -e "\n${BLUE}Espacio usado por logs: $size${NC}"
    fi
}

# Función principal
main() {
    show_header

    if [[ $# -eq 0 ]]; then
        show_usage
        return 0
    fi

    case "$1" in
        "list")
            list_logs
            ;;
        "latest")
            show_latest
            ;;
        "errors")
            show_errors
            ;;
        "clean")
            clean_logs
            ;;
        "compress")
            compress_logs
            ;;
        "summary")
            show_summary
            ;;
        *)
            echo -e "${RED}❌ Comando no reconocido: $1${NC}"
            echo ""
            show_usage
            return 1
            ;;
    esac
}

# Ejecutar función principal
main "$@"
