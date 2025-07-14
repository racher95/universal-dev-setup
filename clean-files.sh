#!/bin/bash

# 🧹 Script de Limpieza de Caracteres
# Limpia caracteres problemáticos que pueden causar errores en PowerShell

echo "🧹 Limpiando caracteres problemáticos..."

# Función para limpiar archivo
clean_file() {
    local file="$1"
    local backup="${file}.backup.$(date +%s)"
    
    echo "Limpiando: $file"
    
    # Crear backup
    cp "$file" "$backup"
    
    # Limpiar caracteres problemáticos
    # Remover BOM UTF-8 si existe
    sed -i '1s/^\xEF\xBB\xBF//' "$file" 2>/dev/null || true
    
    # Convertir line endings a Unix
    dos2unix "$file" 2>/dev/null || sed -i 's/\r$//' "$file"
    
    # Remover caracteres de control no imprimibles (excepto tab y newline)
    tr -cd '\11\12\15\40-\176' < "$file" > "${file}.clean"
    mv "${file}.clean" "$file"
    
    echo "✅ $file limpiado (backup: $backup)"
}

# Limpiar archivos principales
for file in install.ps1 install.sh install.bat; do
    if [[ -f "$file" ]]; then
        clean_file "$file"
    fi
done

# Limpiar scripts del directorio scripts/
for file in scripts/*.sh; do
    if [[ -f "$file" ]]; then
        clean_file "$file"
    fi
done

echo "🎉 Limpieza completada"
