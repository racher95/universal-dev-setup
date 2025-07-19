# Silencia el aviso de Powerlevel10k
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet

# Habilita el "Instant Prompt" de Powerlevel10k (debe estar al principio).
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ==============================================================================
# CONFIGURACIÓN DE OH MY ZSH Y PLUGINS
# ==============================================================================
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

# Plugins habilitados:
# - git: Funcionalidades de git integradas
# - z: Navegación rápida a directorios frecuentes
# - zsh-autosuggestions: Sugerencias automáticas basadas en historial
# - zsh-syntax-highlighting: Resaltado de sintaxis en tiempo real
# - zsh-completions: Completado mejorado de comandos
# - zsh-history-substring-search: Búsqueda en historial con flechas
# - zsh-autopair: Autocompletado de paréntesis, llaves, etc.
# - zsh-you-should-use: Recordatorio de usar aliases definidos
# - zsh-nvm: Gestión lazy de Node Version Manager
plugins=(
  git
  z
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-completions
  zsh-history-substring-search
  zsh-autopair
  zsh-you-should-use
  zsh-nvm
)
source $ZSH/oh-my-zsh.sh

# ==============================================================================
# EXPORTACIÓN DE VARIABLES DE ENTORNO (PATH, etc.)
# ==============================================================================
# Añade el directorio de binarios locales de Python al PATH
export PATH="$HOME/.local/bin:$PATH"

# Activa colores
export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced

# Configuración del historial de comandos
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_ALL_DUPS HIST_REDUCE_BLANKS

# ==============================================================================
# CARGA DE CONFIGURACIONES Y HERRAMIENTAS ADICIONALES
# ==============================================================================
# Carga las configuraciones de Powerlevel10k
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Configuración para el plugin zsh-nvm (carga lazy de NVM)
export NVM_LAZY_LOAD=true
export NVM_COMPLETION=true
export NVM_AUTO_USE=true

# Carga manual de NVM (solo si zsh-nvm no está disponible)
if ! command -v nvm &> /dev/null; then
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
fi

# Carga "The Fuck" (corrector de comandos)
eval "$(thefuck --alias)"

# Carga Autojump (dependiente del SO)
if [[ "$(uname)" == "Darwin" ]]; then # macOS
    # Asume que se instaló con Homebrew en Apple Silicon/Intel
    [ -f "$(brew --prefix)/etc/profile.d/autojump.sh" ] && . "$(brew --prefix)/etc/profile.d/autojump.sh"
elif [[ "$(uname)" == "Linux" ]]; then # Linux
    [ -s /usr/share/autojump/autojump.sh ] && source /usr/share/autojump/autojump.sh
fi

# ==============================================================================
# CARGA DE ALIAS Y FUNCIONES PERSONALES (¡MANTENER AL FINAL!)
# ==============================================================================
# Carga tus alias y funciones personalizadas desde un archivo separado.
if [ -f ~/.zsh_personal ]; then
    source ~/.zsh_personal
fi

# Ejecuta el script épico híbrido ARGOS al iniciar la terminal
if grep -qiE 'microsoft|wsl' /proc/version 2>/dev/null; then
    ARGOS_SCRIPT="$HOME/.local/bin/argosfetch-wsl"
else
    ARGOS_SCRIPT="$HOME/.local/bin/argos-fetch"
fi
if [[ -x "$ARGOS_SCRIPT" ]]; then
    # Solo ejecutar en terminales interactivas y si no se ha mostrado antes
    if [[ $- == *i* ]] && [[ -z $ARGOS_SHOWN ]]; then
        # Marcar que ya se mostró para evitar bucles
        export ARGOS_SHOWN=1
        # Ejecutar con timeout para evitar cuelgues (usar gtimeout en macOS)
        if command -v gtimeout &> /dev/null; then
            gtimeout 10s "$ARGOS_SCRIPT" 2>/dev/null || {
                echo "⚠️  ARGOS script timeout o error - continuando..."
            }
        elif command -v timeout &> /dev/null; then
            timeout 10s "$ARGOS_SCRIPT" 2>/dev/null || {
                echo "⚠️  ARGOS script timeout o error - continuando..."
            }
        else
            # Sin timeout disponible, ejecutar directamente
            "$ARGOS_SCRIPT" 2>/dev/null || {
                echo "⚠️  ARGOS script error - continuando..."
            }
        fi
    fi
fi








# ==============================================================================
# ==============================================================================
#
#                GUÍA DE INSTALACIÓN Y DEPENDENCIAS
#
# Este bloque es un comentario y no ejecuta nada. Sirve como una guía
# para configurar esta misma terminal en un nuevo sistema (Linux o macOS).
#
# ==============================================================================
# ==============================================================================

# ------------------------------------------------------------------------------
# PASO 1: INSTALAR LA FUENTE (¡CRUCIAL!)
# ------------------------------------------------------------------------------
# Para que los iconos y el tema se vean bien, necesitas una "Nerd Font".
# La recomendada para Powerlevel10k es MesloLGS NF.
# ---
# ▼▼▼ EN macOS (CON HOMEBREW) ▼▼▼
# brew tap homebrew/cask-fonts
# brew install --cask font-meslo-lg-nerd-font
# ---
# ▼▼▼ EN UBUNTU / DEBIAN ▼▼▼
# (Este script descarga y las instala en el sistema)
# FONT_DIR="/usr/local/share/fonts/meslolgs"
# sudo mkdir -p "$FONT_DIR"
# (cd "$FONT_DIR" && \
#   sudo wget https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf && \
#   sudo wget https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf && \
#   sudo wget https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf && \
#   sudo wget https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf)
# sudo fc-cache -f -v
# ---
# Después de instalar, **configura tu aplicación de terminal** para que use "MesloLGS NF".

# ------------------------------------------------------------------------------
# PASO 2: INSTALAR ZSH Y HERRAMIENTAS BASE
# ------------------------------------------------------------------------------
# ▼▼▼ EN macOS (CON HOMEBREW) ▼▼▼
# # Homebrew es el gestor de paquetes para macOS. Instálalo desde https://brew.sh
# /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
# # Instala Zsh y otras herramientas. Git y curl suelen venir con las herramientas de Xcode.
# brew install zsh git curl
# ---
# ▼▼▼ EN UBUNTU / DEBIAN ▼▼▼
# sudo apt update && sudo apt upgrade -y
# sudo apt install -y zsh git curl wget build-essential
# ---
# Al final, cambia tu shell por defecto a zsh: `chsh -s $(which zsh)`

# ------------------------------------------------------------------------------
# PASO 3: INSTALAR OH MY ZSH Y PLUGINS
# ------------------------------------------------------------------------------
# 1. Instalar Oh My Zsh (el comando es el mismo para ambos SO)
# sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
#
# 2. Instalar Tema Powerlevel10k
# git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
#
# 3. Instalar Plugins de Zsh
# git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
# git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
# git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-completions
# git clone https://github.com/zsh-users/zsh-history-substring-search ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-history-substring-search
# git clone https://github.com/hlissner/zsh-autopair ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autopair

# ------------------------------------------------------------------------------
# PASO 4: INSTALAR HERRAMIENTAS ADICIONALES DE CLI
# ------------------------------------------------------------------------------
# ▼▼▼ EN macOS (CON HOMEBREW) ▼▼▼
# brew install eza bat fd fzf ripgrep neofetch autojump thefuck
# ---
# ▼▼▼ EN UBUNTU / DEBIAN ▼▼▼
# sudo apt install -y eza bat fd-find fzf ripgrep neofetch autojump python3-pip
# # En Ubuntu, 'bat' a veces se instala como 'batcat'. Si es así, crea un enlace:
# # sudo ln -s /usr/bin/batcat /usr/local/bin/bat
# # 'fd' se instala como 'fdfind'. Crea un enlace para usarlo como 'fd':
# # sudo ln -s $(which fdfind) /usr/local/bin/fd
# # Instala The Fuck via pip
# pip install thefuck --user
#
# ------------------------------------------------------------------------------
# PASO 5: INSTALAR ENTORNO NODE.JS
# ------------------------------------------------------------------------------
# 1. Instalar NVM (el comando es el mismo para ambos SO)
# curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
#
# 2. Instalar Node.js (LTS) y paquetes globales
# (Cierra y reabre la terminal para que nvm esté disponible, luego ejecuta)
# nvm install --lts
# npm install -g yarn serve live-server http-server eslint prettier typescript npm-check-updates create-react-app vite nodemon

# ------------------------------------------------------------------------------
# PASO 6: INSTALAR EXTENSIONES DE VS CODE
# ------------------------------------------------------------------------------
# (Estos comandos funcionan en ambos sistemas si 'code' está en el PATH)
# code --install-extension esbenp.prettier-vscode
# code --install-extension dbaeumer.vscode-eslint
# code --install-extension ritwickdey.LiveServer
# code --install-extension xabikos.JavaScriptSnippets
# code --install-extension eamodio.gitlens
# code --install-extension christian-kohler.path-intellisense
# code --install-extension formulahendry.auto-rename-tag
# code --install-extension bradlc.vscode-tailwindcss
# code --install-extension PKief.material-icon-theme
# code --install-extension dracula-theme.theme-dracula
# code --install-extension github.copilot
#
# Nota: "Bracket Pair Colorizer" ya no es necesario, ahora es una función nativa de VS Code.

# ------------------------------------------------------------------------------
# PASO 7: COPIAR ARCHIVOS DE CONFIGURACIÓN ("DOTFILES")
# ------------------------------------------------------------------------------
# Copia tus archivos .zshrc, .zsh_personal y .p10k.zsh a la carpeta home (~/)
# de la nueva máquina. Al final, reinicia la terminal. ¡Listo!
