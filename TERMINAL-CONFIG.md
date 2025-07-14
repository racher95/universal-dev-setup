# Configuración de Terminal para VS Code

## Problema
VS Code puede abrir terminales del sistema Windows en lugar de bash/Ubuntu.

## Solución Automática
El script configura automáticamente el terminal por defecto en `settings.json`:

```json
{
  "terminal.integrated.defaultProfile.windows": "Ubuntu (WSL)",
  "terminal.integrated.profiles.windows": {
    "Ubuntu (WSL)": {
      "path": "C:\\Windows\\System32\\wsl.exe",
      "args": ["-d", "Ubuntu"],
      "icon": "terminal-ubuntu"
    },
    "PowerShell": {
      "source": "PowerShell",
      "icon": "terminal-powershell"
    },
    "Command Prompt": {
      "path": "C:\\Windows\\System32\\cmd.exe",
      "args": [],
      "icon": "terminal-cmd"
    },
    "Git Bash": {
      "path": "C:\\Program Files\\Git\\bin\\bash.exe",
      "args": [],
      "icon": "terminal-bash"
    }
  }
}
```

## Solución Manual

Si el terminal no funciona correctamente:

1. **Abrir VS Code**
2. **Ctrl+Shift+P** (Comando: Terminal: Select Default Profile)
3. **Seleccionar "Ubuntu (WSL)"**
4. **Reiniciar VS Code**

## Verificación

Para verificar que funciona:
1. Abrir VS Code
2. Ctrl+` (abrir terminal)
3. Debería mostrar `kevin@Argos` en lugar de `PS C:\>`

## Alternativas

### Cambiar temporalmente:
- **Ctrl+Shift+P** → "Terminal: Select Default Profile"
- Elegir el terminal deseado

### Crear terminal específico:
- **Ctrl+Shift+P** → "Terminal: Create New Terminal (With Profile)"
- Seleccionar "Ubuntu (WSL)"

## Troubleshooting

### Terminal no aparece Ubuntu:
1. Verificar que WSL está instalado: `wsl --list`
2. Verificar que Ubuntu está instalado: `wsl --list --verbose`
3. Reinstalar Ubuntu desde Microsoft Store

### Error "wsl.exe no encontrado":
1. Verificar que WSL está habilitado
2. Ejecutar en PowerShell Admin: `wsl --install`
3. Reiniciar el sistema

### Terminal abre pero no funciona:
1. Verificar distribución WSL: `wsl --set-default Ubuntu`
2. Actualizar WSL: `wsl --update`
3. Reiniciar VS Code

Esta configuración asegura que Copilot y todos los terminales integrados usen bash por defecto.
