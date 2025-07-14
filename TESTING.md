# 🧪 GUÍA DE TESTING - Universal Dev Setup

## 📋 **Para Testing en Windows**

### **🎯 Objetivo del Test:**

Probar el sistema completo de bootstrap PowerShell → Git Bash → Instalación completa

### **📥 Descarga y Preparación:**

```powershell
# 1. Clonar el repositorio
git clone https://github.com/racher95/universal-dev-setup.git
cd universal-dev-setup

# 2. Ejecutar el script principal
.\install.ps1
```

### **🔍 Lo que deberías observar:**

#### **Fase 1: PowerShell Bootstrap**

```
✅ PowerShell [versión] detectado
✅ Ejecutándose con permisos de administrador
🔍 Verificando Git Bash...
❌ Git Bash no encontrado
🔄 Iniciando instalación automática...
```

#### **Fase 2: Instalación Automática de Git Bash**

```
📦 Instalando Git Bash...
🔄 Intentando con Chocolatey...
   O
🔄 Usando winget...
   O
🔄 Descarga directa desde git-scm.com...

✅ Git Bash instalado correctamente
```

#### **Fase 3: Relanzamiento Automático**

```
=== LANZANDO SCRIPT PRINCIPAL ===
Cambiando a Git Bash para continuar...
Bash: C:\Program Files\Git\bin\bash.exe

Ejecutando: bash -c 'cd "/c/ruta/proyecto" && ./install.sh'
────────────────────────────────────────────────────────────
```

#### **Fase 4: Instalación Normal en Bash**

```
╔══════════════════════════════════════════════════════════════╗
║            🌍 UNIVERSAL DEVELOPMENT SETUP 3.0               ║
║                                                              ║
║     Configuración automática para entornos de desarrollo    ║
╚══════════════════════════════════════════════════════════════╝

🪟 Sistema detectado: Windows (nativo)

=== INFORMACIÓN DEL SISTEMA WINDOWS ===
🔹 Entorno: Windows Nativo
🔹 PowerShell: Disponible v[version]
🔹 Chocolatey: Instalado/Se instalará automáticamente
...
```

### **✅ Puntos Críticos a Verificar:**

1. **Bootstrap PowerShell:**

   - [ ] PowerShell detecta correctamente la versión
   - [ ] Verifica permisos de administrador
   - [ ] Busca Git Bash en rutas estándar

2. **Instalación Git Bash:**

   - [ ] Instala automáticamente si no existe
   - [ ] Prueba múltiples métodos (Chocolatey, winget, directo)
   - [ ] Actualiza PATH correctamente

3. **Relanzamiento:**

   - [ ] Cambia automáticamente a Git Bash
   - [ ] Convierte rutas Windows → Unix correctamente
   - [ ] Ejecuta install.sh sin errores

4. **Instalación Completa:**
   - [ ] Detecta Windows nativo correctamente
   - [ ] Instala dependencias Windows
   - [ ] Configura fuentes
   - [ ] Instala extensiones VS Code
   - [ ] Configura VS Code en español
   - [ ] Configura terminal predeterminado

### **📝 Logs Importantes a Compartir:**

**Si hay errores, comparte:**

1. **Output completo** del script PowerShell
2. **Mensajes de error** específicos
3. **Versión de Windows** (Windows 10/11)
4. **Versión de PowerShell**
5. **Si tienes permisos de administrador**
6. **Estado previo** (¿tenías Git instalado antes?)

### **🔧 Comandos de Diagnóstico:**

**Si algo falla, ejecuta:**

```bash
# Desde Git Bash (después del relanzamiento)
./diagnose-windows.sh
```

**Información del sistema:**

```powershell
# Desde PowerShell
$PSVersionTable
Get-ExecutionPolicy
[System.Environment]::OSVersion
```

### **🎯 Resultados Esperados:**

**Al finalizar deberías tener:**

- ✅ Git Bash instalado y funcionando
- ✅ VS Code configurado en español
- ✅ Terminal de VS Code apuntando a Ubuntu/WSL por defecto
- ✅ Fuentes de programación instaladas
- ✅ Extensions VS Code instaladas
- ✅ Node.js y herramientas npm
- ✅ Configuración git global

### **🐛 Problemas Posibles:**

1. **Permisos insuficientes:**

   - Ejecutar PowerShell como administrador

2. **Política de ejecución:**

   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

3. **Antivirus/Windows Defender:**

   - Puede bloquear la descarga automática
   - Agregar excepción temporal

4. **Conexión a internet:**
   - Verificar acceso a github.com, chocolatey.org, git-scm.com

---

## 📤 **Después del Test:**

Comparte los logs completos incluyendo:

- ✅ Lo que funcionó perfectamente
- ⚠️ Warnings o mensajes de atención
- ❌ Errores específicos
- 💡 Sugerencias de mejora

¡Estoy listo para recibir tus resultados y ajustar lo que sea necesario! 🚀
