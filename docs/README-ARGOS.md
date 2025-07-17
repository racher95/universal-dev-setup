# 🐺 ARGOS FETCH v2.0 - Sistema de Bienvenida Terminal

![Version](https://img.shields.io/badge/version-2.0-blue.svg)
![Platform](https://img.shields.io/badge/platform-macOS-lightgrey.svg)
![Terminal](https://img.shields.io/badge/terminal-iTerm2-green.svg)

## 📋 Descripción

**Argos Fetch v2.0** es un sistema de bienvenida optimizado para terminal que muestra una imagen y texto ASCII lado a lado con alineación perfecta. Diseñado especialmente para iTerm2 con fallback inteligente para otras terminales.

## ✨ Características

- **🚀 Ejecución Asíncrona**: Terminal inicia instantáneamente
- **🎯 Alineación Perfecta**: Imagen y texto lado a lado sin truncamiento
- **🔍 Detección Automática**: Diferencia entre iTerm2 y otras terminales
- **🔄 Fallback Inteligente**: Usa `chafa` si no hay iTerm2 disponible
- **⚡ Optimizado**: Sin bloqueos ni colgadas del terminal

## 📁 Archivos del Sistema

```
configs/
├── argos-fetch-portable-v2    # Script principal optimizado
├── install-argos-v2.sh        # Instalador automático
├── imgcat                     # Utilidad para display en iTerm2
├── loboMacOS.png             # Imagen principal del sistema
└── README-ARGOS.md           # Esta documentación
```

## 🚀 Instalación

### Instalación Automática (Recomendada)

```bash
cd /Users/kevin/universal-dev-setup/configs
./install-argos-v2.sh
```

### Instalación Manual

```bash
# Crear directorios
mkdir -p ~/.local/share/argos ~/.config/argos ~/.local/bin

# Copiar archivos
cp argos-fetch-portable-v2 ~/.local/bin/argos-fetch
cp imgcat ~/.local/bin/
cp loboMacOS.png ~/.local/share/argos/

# Hacer ejecutables
chmod +x ~/.local/bin/argos-fetch
chmod +x ~/.local/bin/imgcat

# Añadir a PATH si no está
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
```

## 🎯 Uso

### Ejecución Manual
```bash
argos-fetch
```

### Inicio Automático
Añadir a `~/.zshrc`:
```bash
argos-fetch
```

## 🔧 Configuración

### Ajustar Tamaño de Imagen
En `argos-fetch-portable-v2`, modificar las variables:

```bash
# Para iTerm2
IMAGE_WIDTH_ITERM=25
IMAGE_HEIGHT_ITERM=12

# Para otras terminales (chafa)
IMAGE_WIDTH_CHAFA=30
IMAGE_HEIGHT_CHAFA=15
```

### Rutas de Imágenes
El script busca imágenes en estas rutas por orden:
1. `~/.local/share/argos/loboMacOS.png`
2. `~/.config/argos/loboMacOS.png`
3. `~/.local/share/argos/argos-image.png`
4. `~/.config/argos/argos-image.png`

## 🛠️ Tecnologías Utilizadas

- **Bash**: Script principal
- **imgcat**: Display de imágenes en iTerm2
- **chafa**: Fallback para otras terminales
- **tput**: Posicionamiento de cursor

## 🎨 Funcionamiento Técnico

### Para iTerm2
1. Detecta iTerm2 mediante `$TERM_PROGRAM` o `$LC_TERMINAL`
2. Usa `imgcat` para mostrar la imagen
3. Utiliza `tput cup` para posicionamiento absoluto del texto
4. Coloca cada línea del texto en la posición correcta

### Para Otras Terminales
1. Usa `chafa` para convertir imagen a ASCII
2. Utiliza `paste` con process substitution para alinear
3. Fallback a solo texto si no hay visualizador disponible

## 🚨 Troubleshooting

### Imagen no se muestra
- Verificar que `imgcat` esté instalado: `which imgcat`
- Verificar que la imagen exista: `ls -la ~/.local/share/argos/`
- Verificar terminal: `echo $TERM_PROGRAM`

### Problemas de alineación
- Ajustar `IMAGE_WIDTH_ITERM` según el tamaño de tu imagen
- Verificar que `tput` funcione: `tput cup 0 0`

### Terminal lento al iniciar
- El script usa `& disown` para ejecución asíncrona
- Si sigue lento, comentar la línea `argos-fetch` en `~/.zshrc`

## 📝 Changelog

### v2.0 (Julio 2025)
- ✅ Alineación perfecta con `tput cup`
- ✅ Ejecución asíncrona con `& disown`
- ✅ Detección mejorada de iTerm2
- ✅ Fallback inteligente con `chafa`
- ✅ Gestión de múltiples instancias

### v1.0 (Versión inicial)
- ❌ Problemas de alineación
- ❌ Bloqueo del terminal
- ❌ Imagen truncada

## 👤 Autor

Desarrollado para **Wolf System** - Julio 2025

---

**¡Disfruta de tu terminal optimizado!** 🐺✨
