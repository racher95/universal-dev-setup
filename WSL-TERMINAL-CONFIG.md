# 🖥️ Configuración de Terminal WSL en VS Code

## Problema Identificado

Al usar VS Code en Windows con WSL, GitHub Copilot y otras extensiones pueden usar la terminal de Windows en lugar de la terminal de Ubuntu WSL, causando que los comandos no se ejecuten en el entorno Linux correcto.

## Solución Implementada

### 1. Configuración Automática WSL

El script `install.sh` detecta automáticamente cuando se ejecuta desde WSL y configura:

```json
{
  // === WSL SPECIFIC SETTINGS ===
  "remote.WSL.fileWatcher.polling": true,
  "remote.WSL.useShellEnvironment": true,
  "terminal.integrated.defaultProfile.windows": "Ubuntu (WSL)",
  "terminal.integrated.profiles.windows": {
    "Ubuntu (WSL)": {
      "path": "C:\\Windows\\System32\\wsl.exe",
      "args": ["-d", "Ubuntu"],
      "icon": "terminal-ubuntu"
    }
  },
  "terminal.integrated.automationProfile.windows": null
}
```

### 2. Detección de Sistema

El script detecta WSL mediante:
- Variable de entorno `$WSL_DISTRO_NAME`
- Tipo de sistema `$OSTYPE == "linux-gnu"`
- Configuración específica para directorio `.vscode-server`

### 3. Configuraciones Específicas

| Sistema | Terminal Predeterminada | Directorio Config |
|---------|------------------------|-------------------|
| WSL | Ubuntu (WSL) | `~/.vscode-server/data/Machine` |
| Windows | Git Bash | `$APPDATA/Code/User` |
| macOS | zsh | `~/Library/Application Support/Code/User` |
| Linux | bash | `~/.config/Code/User` |

## Verificación

### Script de Prueba
```bash
./test-wsl-terminal.sh
```

### Verificación Manual
1. Abrir VS Code desde WSL: `code .`
2. Abrir terminal: `Ctrl+`` (backtick)
3. Verificar que muestre `Ubuntu (WSL)` en el dropdown
4. Ejecutar `uname -a` - debe mostrar Linux, no Windows

## Troubleshooting

### Problema: Terminal sigue siendo Windows
**Solución:**
1. Ejecutar: `./install.sh` → Opción 5 (VS Code)
2. Reiniciar VS Code completamente
3. Verificar configuración manual:
   - `Ctrl+,` → Settings
   - Buscar: `terminal.integrated.defaultProfile.windows`
   - Seleccionar: `Ubuntu (WSL)`

### Problema: GitHub Copilot usa terminal incorrecta
**Solución:**
1. Verificar que `terminal.integrated.automationProfile.windows` esté en `null`
2. Reiniciar VS Code
3. Si persiste, reinstalar configuración con el script

### Problema: Extensiones no reconocen WSL
**Solución:**
1. Instalar extensión `ms-vscode-remote.remote-wsl`
2. Abrir proyecto con `code .` desde WSL
3. Verificar que VS Code muestre `WSL: Ubuntu` en la barra de estado

## Configuración Manual de Emergencia

Si el script no funciona, configurar manualmente:

```json
{
  "terminal.integrated.defaultProfile.windows": "Ubuntu (WSL)",
  "terminal.integrated.profiles.windows": {
    "Ubuntu (WSL)": {
      "path": "C:\\Windows\\System32\\wsl.exe",
      "args": ["-d", "Ubuntu"],
      "icon": "terminal-ubuntu"
    }
  },
  "terminal.integrated.automationProfile.windows": null,
  "remote.WSL.fileWatcher.polling": true,
  "remote.WSL.useShellEnvironment": true
}
```

## Comandos Útiles

```bash
# Verificar entorno WSL
echo $WSL_DISTRO_NAME

# Verificar configuración VS Code
cat ~/.vscode-server/data/Machine/settings.json | grep -A 10 "terminal.integrated"

# Abrir VS Code desde WSL
code .

# Verificar terminal desde VS Code
uname -a  # Debe mostrar Linux
pwd       # Debe mostrar ruta WSL (/home/...)
```
