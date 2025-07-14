@echo off
echo ============================================
echo  UNIVERSAL DEVELOPMENT SETUP - WINDOWS
echo ============================================
echo.

:: Verificar si estamos en PowerShell
if defined PSModulePath (
    echo [INFO] PowerShell detectado
    goto :check_bash
) else (
    echo [INFO] Command Prompt detectado
    goto :check_bash
)

:check_bash
:: Verificar si bash está disponible
bash --version >nul 2>&1
if %errorlevel% == 0 (
    echo [OK] Bash encontrado. Ejecutando script principal...
    echo.
    bash install.sh
    pause
    exit /b 0
) else (
    echo [ERROR] Bash no encontrado en el sistema
    echo.
    goto :install_git
)

:install_git
echo ============================================
echo  INSTALACION DE GIT REQUERIDA
echo ============================================
echo.
echo Git Bash es necesario para ejecutar este script.
echo.
echo Opciones disponibles:
echo 1. Instalar Git con Chocolatey (requiere permisos de admin)
echo 2. Instalar Git manualmente
echo 3. Usar WSL (Windows Subsystem for Linux)
echo 4. Salir
echo.
set /p choice="Selecciona una opcion (1-4): "

if "%choice%"=="1" goto :install_with_choco
if "%choice%"=="2" goto :manual_install
if "%choice%"=="3" goto :wsl_info
if "%choice%"=="4" exit /b 0
echo Opcion invalida
goto :install_git

:install_with_choco
echo.
echo Verificando Chocolatey...
choco --version >nul 2>&1
if %errorlevel% == 0 (
    echo [OK] Chocolatey encontrado
    echo Instalando Git...
    choco install git -y
    echo.
    echo Git instalado. Reinicia esta ventana y ejecuta de nuevo.
    pause
    exit /b 0
) else (
    echo [ERROR] Chocolatey no encontrado
    echo.
    echo Instalando Chocolatey primero...
    powershell -Command "Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))"

    if %errorlevel% == 0 (
        echo [OK] Chocolatey instalado
        echo Instalando Git...
        choco install git -y
        echo.
        echo Git instalado. Reinicia esta ventana y ejecuta de nuevo.
        pause
        exit /b 0
    ) else (
        echo [ERROR] Error instalando Chocolatey
        goto :manual_install
    )
)

:manual_install
echo.
echo ============================================
echo  INSTALACION MANUAL DE GIT
echo ============================================
echo.
echo 1. Ve a: https://git-scm.com/download/win
echo 2. Descarga Git for Windows
echo 3. Ejecuta el instalador
echo 4. Asegurate de seleccionar "Git Bash" durante la instalacion
echo 5. Reinicia esta ventana y ejecuta de nuevo
echo.
echo Presiona cualquier tecla para abrir la pagina de descarga...
pause >nul
start https://git-scm.com/download/win
pause
exit /b 0

:wsl_info
echo.
echo ============================================
echo  INFORMACION SOBRE WSL
echo ============================================
echo.
echo WSL (Windows Subsystem for Linux) es una alternativa excelente:
echo.
echo 1. Abre PowerShell como administrador
echo 2. Ejecuta: wsl --install
echo 3. Reinicia tu computadora
echo 4. Abre Ubuntu desde el menu inicio
echo 5. Clona y ejecuta este script dentro de WSL
echo.
echo Mas informacion: https://docs.microsoft.com/en-us/windows/wsl/install
echo.
pause
exit /b 0
