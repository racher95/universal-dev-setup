# Plan de Pruebas para macOS - README

## 🚨 IMPORTANTE: Contexto del Problema

**SITUACIÓN ACTUAL:**

- Código desarrollado desde Windows + WSL (Ubuntu)
- Problema target: VS Code crashes en macOS
- Riesgo: Confusión entre sistemas operativos

**PROBLEMA IDENTIFICADO:**

- El usuario tiene RAZÓN: estamos mezclando sistemas
- No podemos validar código macOS desde Linux/WSL
- Variables críticas faltaban en el script original

## 🔧 CORRECCIONES APLICADAS

### ✅ Problema 1: Variable VSCODE_SETTINGS_DIR indefinida

**ANTES:** ❌ Variable no definida en vscode.sh
**DESPUÉS:** ✅ Función `setup_vscode_directories()` añadida

```bash
# Ahora se detecta y configura automáticamente:
# macOS: ~/Library/Application Support/Code/User
# Linux: ~/.config/Code/User
# WSL: ~/.vscode-server/data/Machine
```

### ✅ Problema 2: Dependencias del script principal

**ANTES:** ❌ vscode.sh dependía de variables externas
**DESPUÉS:** ✅ Autocontenido con detección de sistema

## 📋 PROCESO DE PRUEBA EN macOS

### PASO 1: Diagnóstico Pre-Instalación (CRÍTICO)

```bash
# EN macOS, ejecutar primero:
chmod +x macos-diagnostic.sh
./macos-diagnostic.sh
```

**Propósito:**

- Verificar VS Code instalación
- Probar comandos específicos de macOS
- Confirmar permisos de directorio
- Ejecutar prueba de extensión simple

### PASO 2: Instalación con Monitoreo

```bash
# Solo si el diagnóstico pasa:
./install.sh
# Seleccionar opción 6 (VS Code)
```

### PASO 3: Verificación Post-Instalación (NUEVO)

```bash
# Verificar que TODAS las extensiones se instalaron:
chmod +x check-extensions.sh
./check-extensions.sh
```

**Resultado esperado:**

- ✅ 25+ extensiones instaladas (no solo 6-7)
- ✅ Progreso: 100% de extensiones
- ✅ Spanish Language Pack configurado

**Si faltan extensiones:**

- 🔄 Ejecutar instalación manual con los comandos proporcionados
- 📋 Verificar errores de red o permisos
- 🔍 Revisar logs de instalación

### PASO 4: Análisis de Errores

Si hay errores, ahora veremos la salida REAL:

```bash
📋 Salida de VS Code:
│ Installing extension 'ms-ceintl.vscode-language-pack-es'...
│ [ERROR REAL AQUÍ] - No más 2>/dev/null
```

## 🔍 DIFERENCIAS CRÍTICAS: WSL vs macOS

### Comandos que pueden diferir:

```bash
# Eliminación de última línea:
macOS:   sed '$d' file.txt
Linux:   head -n -1 file.txt

# Paths:
macOS:   ~/Library/Application Support/Code/User/
Linux:   ~/.config/Code/User/
WSL:     ~/.vscode-server/data/Machine/

# Variables de entorno:
macOS:   OSTYPE="darwin22.0"
Linux:   OSTYPE="linux-gnu"
```

## 🚨 SEÑALES DE ÉXITO/FALLO

### ✅ SEÑALES DE ÉXITO:

- Diagnóstico previo pasa todas las pruebas
- `setup_vscode_directories()` detecta "macOS"
- Instalación muestra salida detallada (no errores ocultos)
- Spanish Language Pack se instala exitosamente

### ❌ SEÑALES DE FALLO:

- Variables undefined en macOS
- Comandos Linux ejecutándose en macOS
- Errores de permisos en directorio
- VS Code crashes con patrones específicos

## 💡 LECCIONES APRENDIDAS

1. **NUNCA desarrollar para un OS desde otro diferente**
2. **SIEMPRE crear scripts de diagnóstico específicos**
3. **NO ocultar errores con 2>/dev/null en desarrollo**
4. **Usar detección robusta de sistema operativo**

## 🎯 CONCLUSIÓN

El usuario tenía **100% razón** al señalar la confusión de sistemas.
Los scripts ahora están corregidos pero **REQUIEREN prueba real en macOS**
para validar el funcionamiento correcto.

**SIGUIENTE ACCIÓN:** Ejecutar en macOS real con monitoreo completo.
