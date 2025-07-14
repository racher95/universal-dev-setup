# 🪟 INSTALACIÓN EN WINDOWS - GUÍA COMPLETA

## 🚀 Método Recomendado: PowerShell Bootstrap

### 1. Descarga el proyecto
```powershell
git clone https://github.com/tu-usuario/universal-dev-setup.git
cd universal-dev-setup
```

### 2. Ejecuta el script PowerShell
```powershell
# PowerShell como administrador (recomendado)
.\install.ps1
```

**¿Qué hace este script?**
1. ✅ **Detecta automáticamente** si Git Bash está instalado
2. ✅ **Instala Git Bash automáticamente** si no está presente
3. ✅ **Se relanza automáticamente** en Git Bash
4. ✅ **Ejecuta la instalación completa** desde el entorno bash

## 🔧 Flujo de Instalación

```
PowerShell → Instala Git Bash → Relanza en Bash → Instalación Completa
```

### Paso a Paso:

1. **Inicio en PowerShell**
   - Verifica permisos de administrador
   - Detecta si Git Bash está instalado

2. **Instalación Automática de Git Bash** (si es necesario)
   - Intenta con Chocolatey (más rápido)
   - Fallback a winget
   - Fallback a descarga directa
   - Instalación silenciosa

3. **Relanzamiento en Git Bash**
   - Cambia automáticamente a Git Bash
   - Ejecuta `./install.sh`
   - Continúa con la instalación normal

4. **Instalación Completa**
   - Instala dependencias (Git, Node.js, Python, etc.)
   - Configura fuentes de programación
   - Instala extensiones de VS Code
   - Configura VS Code en español
   - Instala herramientas npm

## 🛠️ Opciones Avanzadas

### Forzar instalación
```powershell
.\install.ps1 -Force
```

### Saltar instalación de Git Bash
```powershell
.\install.ps1 -SkipBashInstall
```

### Ver ayuda
```powershell
.\install.ps1 -Help
```

## 📋 Métodos Alternativos

### Método 1: Si ya tienes Git Bash
```bash
# Git Bash como administrador
git clone https://github.com/tu-usuario/universal-dev-setup.git
cd universal-dev-setup
./install.sh
```

### Método 2: Archivo .bat
```cmd
# Ejecutar install.bat
install.bat
```

### Método 3: WSL
```bash
# Dentro de WSL (Ubuntu, etc.)
git clone https://github.com/tu-usuario/universal-dev-setup.git
cd universal-dev-setup
./install.sh
```

## ⚠️ Requisitos

- **PowerShell 5.1+** (incluido en Windows 10/11)
- **Conexión a internet** para descargas
- **Permisos de administrador** (recomendado)
- **VS Code** (se puede instalar automáticamente)

## 🔍 Verificación Previa

Antes de la instalación, puedes verificar tu sistema:

```bash
# En Git Bash (si ya lo tienes)
./test-windows.sh
```

## 🎯 Características Específicas de Windows

- ✅ **Auto-instalación de Chocolatey** Package Manager
- ✅ **Instalación de fuentes** con fallback manual
- ✅ **Configuración de VS Code en español**
- ✅ **Configuración de terminal** PowerShell/Git Bash
- ✅ **Manejo de permisos** de administrador
- ✅ **Verificación robusta** de dependencias

## 🐛 Solución de Problemas

### Error: "No se puede ejecutar scripts"
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Error: "Git Bash no encontrado"
- El script lo instala automáticamente
- O instala manualmente desde: https://git-scm.com/download/win

### Error: "Permisos insuficientes"
- Ejecuta PowerShell como administrador
- O usa `.\install.ps1 -Force` para continuar

### Error: "Chocolatey no se instala"
- Verifica conexión a internet
- El script intentará métodos alternativos
- Instalación manual: https://chocolatey.org/install

## 🎉 Después de la Instalación

1. **Reinicia VS Code** para aplicar configuraciones
2. **Cambia el idioma a español**:
   - Ctrl+Shift+P → "Configure Display Language"
   - Selecciona "Español"
   - Reinicia VS Code
3. **Verifica las fuentes** instaladas
4. **Prueba las extensiones** instaladas

## 📞 Soporte

Si encuentras problemas:
1. Ejecuta `.\test-windows.sh` para diagnóstico
2. Revisa los logs en la terminal
3. Verifica permisos de administrador
4. Reporta problemas con capturas de pantalla

¡Disfruta tu nuevo entorno de desarrollo! 🚀✨
