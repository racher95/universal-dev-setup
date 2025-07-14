# 🛠️ Scripts de Diagnóstico y Pruebas

## 📋 **Descripción General**

Este proyecto incluye varios scripts especializados para diferentes propósitos de diagnóstico y pruebas.

## 🔍 **Scripts Disponibles**

### **1. `diagnose-windows.sh` - Diagnóstico Específico de Windows**

**Propósito:** Diagnosticar la compatibilidad y estado del sistema Windows antes de la instalación.

**¿Cuándo usar?**
- ✅ **Antes de instalar** en sistemas Windows
- ✅ **Para verificar** compatibilidad Windows/WSL
- ✅ **Cuando hay problemas** específicos de Windows
- ✅ **Para soporte técnico** en Windows

**Qué verifica:**
- 🪟 Detección de Windows nativo vs WSL
- 💻 PowerShell disponibilidad y versión
- 📦 Gestores de paquetes (Chocolatey, winget)
- 🔐 Permisos de administrador
- 🛠️ Herramientas básicas (VS Code, Git, Node.js)

**Comando:**
```bash
./diagnose-windows.sh
```

**Salida:** Log en `logs/diagnostic-YYYYMMDD-HHMMSS.log`

---

### **2. `run-tests.sh` - Pruebas Automatizadas Generales**

**Propósito:** Ejecutar pruebas automatizadas completas del sistema en cualquier plataforma.

**¿Cuándo usar?**
- ✅ **Desarrollo y debugging** del proyecto
- ✅ **Verificar integridad** del sistema
- ✅ **Pruebas de compatibilidad** multiplataforma
- ✅ **Validación antes de releases**
- ✅ **CI/CD pipelines**

**Qué prueba:**
- 🖥️ Detección de sistema operativo
- 📁 Integridad de archivos del proyecto
- 🔧 Dependencias del sistema
- 📋 Sistema de logging
- 🔌 Compatibilidad VS Code
- 🧪 Funcionalidades específicas de plataforma

**Comando:**
```bash
./run-tests.sh
```

**Salida:** Log en `test-results/test-YYYYMMDD-HHMMSS.log`

---

### **3. `view-logs.sh` - Gestión de Logs**

**Propósito:** Herramienta para gestionar y visualizar logs de instalación y diagnóstico.

**¿Cuándo usar?**
- ✅ **Ver logs** de instalación o diagnóstico
- ✅ **Debugging** de problemas
- ✅ **Preparar logs** para soporte técnico
- ✅ **Limpieza** de logs antiguos

**Comandos:**
```bash
./view-logs.sh summary    # Resumen de logs
./view-logs.sh latest     # Ver log más reciente
./view-logs.sh errors     # Solo errores
./view-logs.sh compress   # Comprimir para envío
```

---

## 🎯 **Guía de Uso por Escenario**

### **🪟 Instalando en Windows**
```bash
# 1. Diagnóstico previo específico de Windows
./diagnose-windows.sh

# 2. Si todo está bien, instalar
./install.sh
# O desde PowerShell: .\install.ps1

# 3. Si hay problemas, revisar logs
./view-logs.sh errors
```

### **🐧 Instalando en Linux/macOS**
```bash
# 1. Pruebas generales del sistema
./run-tests.sh

# 2. Instalar
./install.sh

# 3. Verificar logs si hay problemas
./view-logs.sh latest
```

### **🔧 Desarrollo y Testing**
```bash
# Ejecutar todas las pruebas
./run-tests.sh

# Ver estado de logs
./view-logs.sh summary

# Limpiar logs de testing
./view-logs.sh clean
```

### **🐛 Debugging y Soporte**
```bash
# Para Windows:
./diagnose-windows.sh
./view-logs.sh compress

# Para otras plataformas:
./run-tests.sh
./view-logs.sh compress

# El archivo .tar.gz contiene toda la información necesaria
```

## 📊 **Matriz de Compatibilidad**

| Script | Windows | WSL | Linux | macOS | Propósito |
|--------|---------|-----|--------|-------|-----------|
| `diagnose-windows.sh` | ✅ Óptimo | ✅ Funciona | ⚠️ Limitado | ⚠️ Limitado | Diagnóstico Windows |
| `run-tests.sh` | ✅ Funciona | ✅ Óptimo | ✅ Óptimo | ✅ Óptimo | Pruebas generales |
| `view-logs.sh` | ✅ Funciona | ✅ Funciona | ✅ Funciona | ✅ Funciona | Gestión de logs |

## 🔍 **Diferencias Clave**

| Aspecto | `diagnose-windows.sh` | `run-tests.sh` |
|---------|----------------------|----------------|
| **Objetivo** | Diagnosticar Windows | Probar todo el sistema |
| **Audiencia** | Usuario final | Desarrollador/Admin |
| **Frecuencia** | Antes de instalar | Durante desarrollo |
| **Plataforma** | Específico Windows | Multiplataforma |
| **Salida** | Diagnóstico legible | Resultados de pruebas |
| **Logs** | `logs/diagnostic-*.log` | `test-results/test-*.log` |

## 💡 **Recomendaciones**

- **Para usuarios finales:** Usa `diagnose-windows.sh` en Windows y confía en `install.sh` para otras plataformas
- **Para desarrolladores:** Usa `run-tests.sh` regularmente durante desarrollo
- **Para soporte:** Pide logs de `diagnose-windows.sh` para problemas de Windows, `run-tests.sh` para otros
- **Para CI/CD:** Integra `run-tests.sh` en pipelines de testing
