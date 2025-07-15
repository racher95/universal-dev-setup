# 🐺 ARGOS - Sistema de Bienvenida Visual

ARGOS es un sistema de bienvenida visual personalizado para terminal que combina una imagen (lobo) con información del sistema en un formato elegante.

## 🎯 Características

- **Imagen visual adaptativa**:
  - iTerm2: Usa imágenes nativas (mejor calidad)
  - Otros terminales: Usa `chafa` para ASCII art
- **Información del sistema**: Usuario, hostname, OS, kernel, uptime
- **Rutas portables**: Funciona en cualquier sistema sin hardcodear rutas
- **Carga automática**: Se ejecuta automáticamente al abrir la terminal
- **Prevención de bucles**: Solo se ejecuta una vez por sesión
- **Detección inteligente**: Adapta la visualización según el terminal

## 📁 Estructura de Archivos

```
$HOME/.local/bin/argos-fetch          # Script ejecutable
$HOME/.local/share/argos/
├── Argos-FetchWU.png                 # Imagen principal
$HOME/.config/argos/
├── Argos-FetchWU.png                 # Imagen fallback
```

## 🔧 Dependencias

### **iTerm2 (macOS)**

- ✅ **Sin dependencias adicionales**: Soporte nativo de imágenes
- ✅ **Mejor calidad**: Muestra imágenes reales, no ASCII art
- ✅ **Descarga**: https://iterm2.com/

### **Otros Terminales**

- **chafa**: Para renderizar imágenes como ASCII art
  - Ubuntu/Debian: `sudo apt install chafa`
  - macOS: `brew install chafa`
  - Fedora: `sudo dnf install chafa`

## 🚀 Instalación

La instalación se hace automáticamente con `terminal-setup.sh` y detecta automáticamente tu terminal:

```bash
# El script detectará automáticamente:
# - iTerm2: No instalará chafa (no necesario)
# - Otros terminales: Instalará chafa
./scripts/terminal-setup.sh
```

### Instalación Manual

```bash
# 1. Instalar dependencias (solo si no usas iTerm2)
sudo apt install chafa  # Ubuntu/Debian
brew install chafa      # macOS (Terminal.app)

# 2. Crear directorios
mkdir -p $HOME/.local/bin
mkdir -p $HOME/.local/share/argos
mkdir -p $HOME/.config/argos

# 3. Copiar archivos
cp configs/argos-fetch-portable $HOME/.local/bin/argos-fetch
cp configs/Argos-FetchWU.png $HOME/.local/share/argos/
cp configs/Argos-FetchWU.png $HOME/.config/argos/

# 4. Hacer ejecutable
chmod +x $HOME/.local/bin/argos-fetch
```

## 🎮 Uso

```bash
# Ejecutar manualmente
argos-fetch

# O usando el comando completo
$HOME/.local/bin/argos-fetch
```

## 🔧 Configuración en .zshrc

El script se carga automáticamente en cada nueva terminal mediante este código en `.zshrc`:

```bash
# Ejecuta el script épico híbrido ARGOS al iniciar la terminal
ARGOS_SCRIPT="$HOME/.local/bin/argos-fetch"
if [[ -x "$ARGOS_SCRIPT" ]]; then
    if [[ $- == *i* ]] && [[ -z $ARGOS_SHOWN ]]; then
        # Marcar que ya se mostró para evitar bucles
        export ARGOS_SHOWN=1
        # Ejecutar directamente
        "$ARGOS_SCRIPT"
    fi
fi
```

## 🎨 Personalización

### Cambiar la imagen

1. Coloca tu imagen en `$HOME/.local/share/argos/` con el nombre `Argos-FetchWU.png`
2. O modifica la variable `ARGOS_IMAGE_PATH` en el script

### Modificar el tamaño de la imagen

Edita el script `argos-fetch` y cambia la línea:

```bash
mapfile -t wolf_lines < <(chafa --symbols=block --size=30x18 "$ARGOS_IMAGE")
```

### Cambiar la información mostrada

Modifica las arrays `argos_lines` e `info_lines` en el script para personalizar el contenido.

## 🎨 Comparación Visual por Terminal

### **iTerm2 (macOS)**

```
✅ Imagen real PNG/JPG
✅ Colores verdaderos
✅ Resolución completa
✅ Transparencia
✅ Sin dependencias
```

### **Terminal Estándar + chafa**

```
⚠️ ASCII art con caracteres
⚠️ Colores limitados
⚠️ Resolución reducida
❌ Sin transparencia
⚠️ Requiere chafa
```

### **Recomendación**

- **macOS**: Usa iTerm2 para mejor experiencia visual
- **Linux/WSL**: Terminal estándar con chafa funciona bien
- **Windows**: WSL con Windows Terminal + chafa

## 🔧 Configuración Avanzada

### Variables de Entorno

```bash
# Forzar modo chafa (incluso en iTerm2)
export ARGOS_FORCE_CHAFA=1

# Cambiar tamaño de imagen para chafa
export ARGOS_CHAFA_SIZE="40x24"

# Desactivar imagen (solo texto)
export ARGOS_NO_IMAGE=1
```

### Personalización por Terminal

El script detecta automáticamente tu terminal usando `$TERM_PROGRAM`:

```bash
# Detectar iTerm2
if [[ "$TERM_PROGRAM" == "iTerm.app" ]]; then
    # Usar protocolo nativo
    display_image_native "$image_path"
else
    # Usar chafa
    display_image_chafa "$image_path"
fi
```

## 🔍 Solución de Problemas

### La imagen no se muestra

1. Verifica que `chafa` esté instalado: `command -v chafa`
2. Verifica que la imagen existe: `ls -la $HOME/.local/share/argos/Argos-FetchWU.png`
3. Prueba el script manualmente: `$HOME/.local/bin/argos-fetch`

### El script no se ejecuta automáticamente

1. Verifica que el script sea ejecutable: `ls -la $HOME/.local/bin/argos-fetch`
2. Verifica que `$HOME/.local/bin` esté en el PATH: `echo $PATH`
3. Recarga la configuración: `source ~/.zshrc`

### Bucles infinitos

El script usa la variable `ARGOS_SHOWN` para prevenir bucles. Si experimentas problemas:

```bash
unset ARGOS_SHOWN  # Resetear la variable
```

## 🎯 Integración con Terminal Setup

ARGOS se instala automáticamente cuando ejecutas `terminal-setup.sh`. El script:

1. Instala `chafa` como dependencia
2. Crea los directorios necesarios
3. Copia los archivos a las ubicaciones correctas
4. Configura los permisos
5. Verifica que todo funcione correctamente

## 🔄 Actualización

Para actualizar ARGOS:

1. Actualiza los archivos en `configs/`
2. Ejecuta `terminal-setup.sh` nuevamente
3. O copia manualmente los archivos actualizados

## 🐛 Debugging

Para debug, puedes ejecutar el script con más verbose:

```bash
bash -x $HOME/.local/bin/argos-fetch
```

O verificar las variables:

```bash
echo "ARGOS_SHOWN: $ARGOS_SHOWN"
echo "PATH: $PATH"
```
