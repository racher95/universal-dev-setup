# 🍎 Sistema Anti-Crash para macOS

## Problema Original

En macOS, VS Code tiene problemas conocidos con el **Electron Framework** que causan:
- ❌ Crashes al instalar extensiones via CLI (`code --install-extension`)
- ❌ Timeouts y procesos colgados
- ❌ Instalación de 0 extensiones con múltiples errores
- ❌ Spanish Language Pack no se instala correctamente

## Solución Implementada

### 🔧 Funciones Anti-Crash

#### 1. `detect_vscode_macos_issues()`
- Detecta automáticamente si estamos en macOS
- Muestra advertencias preventivas
- Activa el modo anti-crash

#### 2. `code_list_extensions_safe()`
- Lista extensiones con timeout y reintentos
- Maneja crashes de Electron Framework
- 3 intentos máximo con pausa entre reintentos

#### 3. `code_install_extension_safe()`
- Instala extensiones con timeout de 60 segundos
- Sistema de 3 reintentos automáticos
- Detección de crashes y manejo de errores
- Pausas entre reintentos para estabilizar

#### 4. `extension_already_installed()`
- Verifica si una extensión ya está instalada
- Usa `code_list_extensions_safe()` para evitar crashes
- Fallback seguro si no se puede verificar

### 🌍 Prioridad Spanish Language Pack

```bash
# PASO 1: Instalar Spanish Language Pack PRIMERO
local spanish_ext="ms-ceintl.vscode-language-pack-es"
if ! extension_already_installed "$spanish_ext"; then
    if code_install_extension_safe "$spanish_ext"; then
        # Configurar idioma inmediatamente
        echo '{"locale":"es"}' > "$VSCODE_SETTINGS_DIR/locale.json"
    fi
fi
```

### 📦 Instalación por Fases

1. **Fase 1**: Spanish Language Pack (crítico)
2. **Fase 2**: Extensiones esenciales con anti-crash
3. **Fase 3**: Modo manual si hay muchos fallos

### 🛡️ Fallback: Modo Manual

Si el sistema anti-crash falla, se activa automáticamente:

```bash
install_extensions_manual_mode() {
    # Muestra instrucciones detalladas
    # Lista exacta de extensiones con publishers
    # Pasos específicos para macOS (Cmd+Shift+X)
}
```

## 🧪 Testing

### Ejecutar Pruebas
```bash
# Prueba completa del sistema anti-crash
./test-macos-anticrash.sh

# Prueba solo configuración VS Code
./install.sh → opción 6
```

### Verificación Manual
```bash
# En macOS, verificar detección
[[ "$OSTYPE" == "darwin"* ]] && echo "macOS detectado"

# Probar timeout
timeout 30 code --list-extensions

# Verificar Spanish Language Pack
code --list-extensions | grep "ms-ceintl.vscode-language-pack-es"
```

## 📊 Métricas de Éxito

### Antes (Problema Original)
- ❌ 0 extensiones instaladas
- ❌ 25 errores de crash
- ❌ 100% tasa de fallo

### Después (Con Anti-Crash)
- ✅ Spanish Language Pack instalado con prioridad
- ✅ Extensiones esenciales con manejo de errores
- ✅ Modo manual como fallback robusto
- ✅ Configuración de idioma garantizada

## 🔧 Configuración Específica

### macOS vs Otros Sistemas
```bash
if detect_vscode_macos_issues; then
    # Lógica específica macOS con anti-crash
    code_install_extension_safe "$ext"
else
    # Instalación normal para Linux/WSL
    code --install-extension "$ext" --force
fi
```

### Archivos de Configuración
- `locale.json` → Fuerza idioma español
- `settings.json` → Configuración optimizada
- Backup automático de configuraciones existentes

## 🚀 Uso

### Instalación Automática
```bash
git clone https://github.com/tu-usuario/universal-dev-setup.git
cd universal-dev-setup
./install.sh  # Detecta macOS automáticamente
```

### Solo VS Code
```bash
./install.sh
# Seleccionar opción 6: "Solo configuración VS Code"
```

## 📝 Logs y Debugging

El sistema genera logs detallados:
- Detección de crashes
- Intentos de reintento
- Éxito/fallo de cada extensión
- Activación de modo manual

## 🔄 Futuras Mejoras

1. **Detección de versión de macOS** específica
2. **Cache de extensiones** problemáticas
3. **Instalación diferida** para extensiones problemáticas
4. **Integración con Homebrew** para VS Code alternativo

---

**✅ Estado**: Implementado y funcional  
**🧪 Testado**: Verificado en múltiples escenarios  
**📚 Documentado**: Guía completa disponible
