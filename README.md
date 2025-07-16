# 🌍 Universal Development Setup

**Configuración automática y universal para entornos de desarrollo**

Un script inteligente que detecta automáticamente tu sistema operativo y configura un entorno de desarrollo completo con VS Code, fuentes, extensiones y herramientas esenciales.

## 🚀 Características

- **🔍 Detección automática** de sistema operativo (macOS, Linux, WSL)
- **⚙️ Configuración inteligente** según el entorno detectado
- **🎨 Fuentes de desarrollo** (Fira Code, JetBrains Mono, Cascadia Code, MesloLGS)
- **🔌 Extensiones VS Code** esenciales para desarrollo web
- **📝 Configuración VS Code** optimizada con mejores prácticas
- **🛠️ Herramientas npm** globales para desarrollo
- **🔄 Backup automático** de configuraciones existentes
- **📦 Gestión de dependencias** según el sistema

## 💻 Sistemas Soportados

| Sistema          | Estado | Notas                                                  |
| ---------------- | ------ | ------------------------------------------------------ |
| macOS (nativo)   | ✅     | Homebrew + VS Code nativo                              |
| Linux (nativo)   | ✅     | APT + VS Code nativo                                   |
| Windows WSL      | ✅     | APT + VS Code en Windows                               |
| Windows (nativo) | ✅     | Auto-instalación de Chocolatey, dependencias y fuentes |

## 🛠️ Instalación

### 🪟 **Windows (Recomendado) - Bootstrap Automático**

#### ✨ Nuevo: Instalación Automática de Git Bash

```powershell
# PowerShell como administrador - ¡Un solo comando!
git clone https://github.com/racher95/universal-dev-setup.git
cd universal-dev-setup
.\install.ps1
```

**¿Qué hace el script PowerShell?**

1. 🔍 **Detecta** si Git Bash está instalado
2. 📦 **Instala Git Bash automáticamente** si no existe
3. 🔄 **Se relanza en Git Bash** automáticamente
4. 🚀 **Ejecuta la instalación completa** desde bash

#### Métodos Alternativos:

**Git Bash (si ya lo tienes):**

```bash
# Git Bash como administrador
git clone https://github.com/racher95/universal-dev-setup.git
cd universal-dev-setup
./install.sh
```

**Archivo .bat:**

```cmd
# Ejecutar directamente
install.bat
```

**📖 Guía completa:** Ver [WINDOWS.md](WINDOWS.md) para instrucciones detalladas

### 🐧 **Linux/macOS/WSL**

#### Instalación rápida (un comando):

```bash
curl -fsSL https://raw.githubusercontent.com/racher95/universal-dev-setup/main/install.sh | bash
```

#### Instalación manual:

```bash
# Clonar el repositorio
git clone https://github.com/racher95/universal-dev-setup.git
cd universal-dev-setup

# Ejecutar el script
./install.sh
```

## 🪟 Instalación en Windows

### Método 1: Git Bash (Recomendado)

```bash
# Abrir Git Bash como administrador
git clone https://github.com/tu-usuario/universal-dev-setup.git
cd universal-dev-setup
./install.sh
```

### Método 2: WSL

```bash
# Desde WSL (Ubuntu, etc.)
git clone https://github.com/tu-usuario/universal-dev-setup.git
cd universal-dev-setup
./install.sh
```

### Método 3: PowerShell + Git

```powershell
# PowerShell como administrador
git clone https://github.com/tu-usuario/universal-dev-setup.git
cd universal-dev-setup
bash install.sh
```

### ⚠️ Requisitos para Windows:

- **PowerShell** 5.1 o superior
- **Permisos de administrador** (recomendado)
- **Git** instalado
- Conexión a internet

### 🧪 Prueba rápida:

```bash
# Verificar compatibilidad antes de instalar
./diagnose-windows.sh
```

## 📋 Opciones de instalación

El script ofrece un menú interactivo con las siguientes opciones:

1. **🔍 Verificar estado actual** - Revisa qué está instalado
2. **🚀 Instalación completa** - Instala todo automáticamente
3. **📦 Solo dependencias base** - Git, Node.js, herramientas básicas
4. **🔤 Solo fuentes** - Fuentes de desarrollo
5. **🔌 Solo extensiones VS Code** - Extensiones esenciales
6. **⚙️ Solo configuración VS Code** - Settings.json optimizado
7. **🛠️ Solo herramientas npm** - Paquetes globales
8. **❌ Salir**

## 🔧 Componentes instalados

### Dependencias base:

- Git, curl, wget
- Node.js (LTS) + npm
- Build tools según el sistema

### Fuentes:

- **Fira Code** - Fuente con ligaduras
- **JetBrains Mono** - Fuente moderna
- **Cascadia Code** - Fuente de Microsoft
- **MesloLGS Nerd Font** - Para terminales con iconos

### Extensiones VS Code:

- **🌍 Spanish Language Pack** - Interfaz en español (PRIORIDAD)
- **Prettier** - Formateo de código
- **ESLint** - Linting
- **Live Server** - Servidor local
- **GitLens** - Git mejorado
- **Auto Rename Tag** - HTML/XML
- **Path Intellisense** - Rutas inteligentes
- **Tailwind CSS** - CSS framework
- **Error Lens** - Errores inline
- **Live Share** - Colaboración en tiempo real
- **Material Icons** - Iconos mejorados
- Y más...

### Herramientas npm:

- live-server, prettier, eslint
- typescript, npm-check-updates
- Y más utilidades

## 🎯 Configuración VS Code

El script aplica configuraciones optimizadas para desarrollo web:

- **🌍 Idioma**: Interfaz en español configurada automáticamente
- **Editor**: Fuentes con ligaduras, formateo automático
- **Prettier**: Configuración estándar
- **ESLint**: Corrección automática
- **Terminal**: Fuente Nerd Font
- **Live Server**: Puerto 5500 por defecto
- **Git**: Integración mejorada
- **WSL**: Configuraciones específicas

### 📋 Archivos de Configuración:

- `settings.json` - Configuración principal con `"locale": "es"`
- `locale.json` - Archivo específico de idioma para forzar español
- Ambos archivos aseguran que VS Code se muestre en español

**💡 Importante:** Reinicia VS Code después de la instalación para ver la interfaz en español.

## 🔒 Seguridad y Logging

- **Backup automático** de configuraciones existentes
- **Verificación de permisos** antes de escribir
- **Detección de errores** con manejo apropiado
- **📋 Sistema de logging automático** para debugging
- **📁 Logs detallados** guardados en `logs/` con timestamps
- **🐛 Captura de errores** en archivos separados para soporte

## 🌐 Compatibilidad

### macOS:

- Homebrew para gestión de paquetes
- VS Code desde el sitio oficial
- Fuentes via Homebrew Cask

### Linux:

- APT para gestión de paquetes
- VS Code desde repositorio oficial
- Fuentes descargadas manualmente

### Windows WSL:

- APT dentro de WSL
- VS Code en Windows (acceso desde WSL)
- Configuración híbrida optimizada

## 📚 Documentación

- **[📋 Sistema de Logging](LOGGING.md)** - Información sobre logs automáticos y debugging
- **[🪟 Instalación en Windows](WINDOWS.md)** - Guía específica para Windows con PowerShell
- **[🍎 Sistema Anti-Crash macOS](MACOS-ANTICRASH.md)** - Solución para problemas de extensiones en macOS
- **[🔧 Configuración de Terminal](TERMINAL-CONFIG.md)** - Setup avanzado de terminales
- **[🧪 Testing y Validación](TESTING.md)** - Cómo probar y validar la instalación
- **[🛠️ Scripts de Diagnóstico](SCRIPTS.md)** - Guía completa de scripts de diagnóstico y pruebas

## 🔍 **Diagnóstico y Pruebas**

### Para Windows:

```bash
# Diagnóstico específico antes de instalar
./diagnose-windows.sh
```

### Para cualquier plataforma:

```bash
# Pruebas automatizadas completas
./run-tests.sh

# Gestión de logs
./view-logs.sh summary
```

## 🤝 Contribuir

¡Las contribuciones son bienvenidas! Por favor:

1. Fork el repositorio
2. Crea una rama para tu feature
3. Commit tus cambios
4. Push a la rama
5. Abre un Pull Request

## 📄 Licencia

MIT License - ver [LICENSE](LICENSE) para más detalles.

## 🙏 Agradecimientos

- Comunidad de VS Code
- Desarrolladores de las fuentes incluidas
- Maintainers de las extensiones
- Usuarios que reportan issues y mejoras

---

**¿Problemas o sugerencias?** Abre un [issue](https://github.com/tu-usuario/universal-dev-setup/issues) o contáctame en [@tu-usuario](https://twitter.com/tu-usuario).
