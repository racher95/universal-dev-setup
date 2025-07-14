# 🐛 Solución de Problemas Windows

## 🔴 **Errores Comunes y Soluciones**

### **1. Error PowerShell: "No se puede enlazar el argumento al parámetro 'Path'"**

**Síntoma:**

```
Split-Path : No se puede enlazar el argumento al parámetro 'Path' porque es nulo.
En C:\universal-dev-setup\install.ps1: 100 Carácter: 37
```

**Causa:** El script PowerShell no puede determinar su propia ubicación.

**Solución Implementada:**

- ✅ Detección robusta de directorio del script
- ✅ Múltiples métodos de fallback
- ✅ Compatibilidad con diferentes versiones de PowerShell

### **2. Error de instalación de Git**

**Síntoma:**

```
ERROR: Running ["...Git-2.50.1-64-bit.exe" /VERYSILENT ...] was not successful. Exit code was '1'.
```

**Causas Posibles:**

- Git ya está instalado y hay conflicto
- Permisos insuficientes
- Otro instalador de Git en ejecución

**Solución Implementada:**

- ✅ Verificación previa si Git ya está instalado
- ✅ Saltar instalación si Git funciona correctamente
- ✅ Mejor manejo de errores de Chocolatey

### **3. Error con comando `whoami`**

**Síntoma:**

```
whoami: extra operand '/groups'
Try 'whoami --help' for more information.
```

**Causa:** Comando `whoami /groups` es de Windows CMD, no compatible con Git Bash.

**Solución Implementada:**

- ✅ Método de verificación alternativo usando archivos de prueba
- ✅ Uso de PowerShell para verificación de permisos
- ✅ Compatibilidad con Git Bash

### **4. Comentarios del Chat Apareciendo en PowerShell**

**Síntoma:** PowerShell muestra texto de comentarios del desarrollo como errores.

**Causas Posibles:**

- Caracteres Unicode problemáticos
- BOM (Byte Order Mark) en archivos
- Caracteres de control ocultos

**Soluciones:**

```bash
# Ejecutar script de limpieza
./clean-files.sh

# Verificar codificación
file install.ps1

# Recrear archivo si es necesario
```

## 🛠️ **Comandos de Diagnóstico**

### **Diagnóstico Rápido:**

```bash
# Diagnóstico específico de Windows
./diagnose-windows.sh

# Pruebas generales
./run-tests.sh

# Ver logs de error
./view-logs.sh errors
```

### **Verificación Manual:**

```bash
# Verificar Git
git --version

# Verificar Node.js
node --version
npm --version

# Verificar PowerShell
powershell -Command '$PSVersionTable'

# Verificar Chocolatey
choco --version
```

### **Limpiar y Reinstalar:**

```bash
# Limpiar archivos problemáticos
./clean-files.sh

# Reinstalar desde PowerShell limpio
.\install.ps1 -Force
```

## 🔧 **Soluciones Específicas**

### **Git ya instalado:**

```bash
# Si Git funciona, no necesita reinstalación
git --version
# Si muestra versión, está funcionando correctamente
```

### **Permisos de Administrador:**

```powershell
# Verificar permisos en PowerShell
([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
```

### **Chocolatey con problemas:**

```powershell
# Reinstalar Chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
```

### **Limpiar cache de Chocolatey:**

```cmd
choco cache clear
choco upgrade chocolatey
```

## 📋 **Lista de Verificación Pre-Instalación**

### **Antes de ejecutar install.ps1:**

- [ ] PowerShell ejecutándose como Administrador
- [ ] Política de ejecución permite scripts: `Set-ExecutionPolicy RemoteSigned`
- [ ] Git Bash no está en ejecución simultáneamente
- [ ] Conexión a internet estable

### **Después de errores:**

- [ ] Revisar logs: `./view-logs.sh latest`
- [ ] Verificar qué se instaló: `./diagnose-windows.sh`
- [ ] Limpiar archivos: `./clean-files.sh`
- [ ] Intentar instalación manual de componentes fallidos

## 🚨 **Emergencia: Instalación Manual**

Si el script automático falla completamente:

### **1. Instalar Git manualmente:**

```
https://git-scm.com/download/win
```

### **2. Instalar Node.js manualmente:**

```
https://nodejs.org/
```

### **3. Instalar VS Code manualmente:**

```
https://code.visualstudio.com/
```

### **4. Continuar con script bash:**

```bash
# Una vez que Git Bash esté disponible
./install.sh
```

## 📞 **Soporte Técnico**

### **Información necesaria para reportar problemas:**

```bash
# Generar información completa
./diagnose-windows.sh
./run-tests.sh
./view-logs.sh compress

# Compartir el archivo logs-YYYYMMDD-HHMMSS.tar.gz
```

### **Datos del sistema:**

- Versión de Windows
- Versión de PowerShell
- Permisos de administrador
- Software previamente instalado
- Logs completos de error

### **Contacto:**

- Issues: https://github.com/tu-usuario/universal-dev-setup/issues
- Con logs adjuntos y descripción completa del problema
