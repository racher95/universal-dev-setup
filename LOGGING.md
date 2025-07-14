# 📋 Sistema de Logging - Universal Development Setup

## 🎯 **Información General**

El sistema automáticamente guarda logs detallados de todas las operaciones de instalación y diagnóstico para facilitar el debugging y soporte.

## 📁 **Estructura de Logs**

```
logs/
├── installation-YYYYMMDD-HHMMSS.log    # Log completo de instalación
├── errors-YYYYMMDD-HHMMSS.log          # Solo errores (si existen)
└── diagnostic-YYYYMMDD-HHMMSS.log      # Log de diagnóstico del sistema
```

## 🔍 **Tipos de Logs**

### **1. Log de Instalación Completa**

- **Archivo:** `logs/installation-YYYYMMDD-HHMMSS.log`
- **Contenido:**
  - Información del sistema
  - Todos los pasos de instalación
  - Éxitos y errores
  - Timestamps detallados
  - Duración total

### **2. Log de Errores**

- **Archivo:** `logs/errors-YYYYMMDD-HHMMSS.log`
- **Contenido:**
  - Solo errores críticos
  - Información de debugging
  - Context de cada error

### **3. Log de Diagnóstico**

- **Archivo:** `logs/diagnostic-YYYYMMDD-HHMMSS.log`
- **Contenido:**
  - Estado del sistema antes/después
  - Versiones de software detectadas
  - Permisos y configuraciones

## 🚀 **Uso Automático**

Los logs se generan automáticamente sin intervención:

```bash
# Durante instalación normal
./install.sh
# → Genera: logs/installation-YYYYMMDD-HHMMSS.log

# Durante instalación automática (desde PowerShell)
./install.sh --auto
# → Genera: logs/installation-YYYYMMDD-HHMMSS.log

# Durante diagnóstico específico de Windows
./diagnose-windows.sh
# → Genera: logs/diagnostic-YYYYMMDD-HHMMSS.log
```

## 📊 **Ejemplo de Log de Instalación**

```
=== UNIVERSAL DEVELOPMENT SETUP - LOG DE INSTALACIÓN ===
Fecha de inicio: 2025-01-14 15:30:45
Sistema operativo: Linux 5.15.0-56-generic #62-Ubuntu SMP ...
Usuario: kevin
Directorio de trabajo: /home/kevin/OneDrive/DProjects/universal-dev-setup
Versión del script: 3.0
====================================================

[2025-01-14 15:30:45] [INFO] STEP: Iniciando instalación completa...
[2025-01-14 15:30:46] [SUCCESS] Dependencias base instaladas correctamente
[2025-01-14 15:30:48] [SUCCESS] Fuentes Fira Code instaladas
[2025-01-14 15:30:52] [SUCCESS] Extensiones VS Code instaladas
[2025-01-14 15:30:55] [WARNING] Algunas configuraciones requieren reinicio
[2025-01-14 15:30:56] [SUCCESS] ¡Instalación completa terminada!

====================================================
Instalación finalizada: 2025-01-14 15:30:56
Duración total: 11s
Estado final: COMPLETADO
====================================================
```

## 🐛 **Para Reportar Errores**

### **Información Necesaria:**

1. **Log completo de instalación:**

   ```bash
   cat logs/installation-YYYYMMDD-HHMMSS.log
   ```

2. **Log de errores específicos:**

   ```bash
   cat logs/errors-YYYYMMDD-HHMMSS.log
   ```

3. **Diagnóstico específico de Windows:**

   ```bash
   ./diagnose-windows.sh
   cat logs/diagnostic-YYYYMMDD-HHMMSS.log
   ```

4. **Pruebas generales del sistema:**
   ```bash
   ./run-tests.sh
   cat test-results/test-YYYYMMDD-HHMMSS.log
   ```

### **Comandos Útiles para Compartir:**

```bash
# Ver el log más reciente
ls -la logs/ | tail -n5

# Comprimir logs para envío
tar -czf logs-$(date +%Y%m%d).tar.gz logs/

# Ver solo errores del último log
grep -i "error\|failed\|❌" logs/installation-*.log | tail -n10
```

## 🔧 **Limpieza de Logs**

Los logs se acumulan en el directorio `logs/`. Para limpiarlos:

```bash
# Eliminar logs antiguos (más de 7 días)
find logs/ -name "*.log" -mtime +7 -delete

# Eliminar todos los logs
rm -rf logs/

# Mantener solo los 5 más recientes
ls -t logs/*.log | tail -n +6 | xargs rm -f
```

## ⚠️ **Importante**

- Los logs **NO se suben al repositorio Git** (están en `.gitignore`)
- Los logs pueden contener **información del sistema** (rutas, usuario, etc.)
- **Revisa el contenido** antes de compartir logs públicamente
- Los logs se crean automáticamente, **no requieren configuración**

## 🎯 **Beneficios**

✅ **Debugging fácil** - Información completa de errores
✅ **Soporte mejorado** - Logs detallados para ayuda
✅ **Auditoría** - Registro de qué se instaló y cuándo
✅ **Automatización** - Sin intervención manual necesaria
✅ **Histórico** - Múltiples instalaciones tracked
