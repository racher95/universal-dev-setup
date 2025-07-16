#!/usr/bin/env powershell
# DISPATCHER UNIVERSAL - Windows Development Setup
# Despachador inteligente para configuracion de desarrollo

# Configurar el manejo de errores de forma mas permisiva para evitar que el script se cierre abruptamente
$ErrorActionPreference = "Continue"
$ProgressPreference = "SilentlyContinue"

# Funciones de Display
function Show-Banner {
    Clear-Host
    Write-Host ""
    Write-Host "Windows Development Setup 3.0" -ForegroundColor Cyan
    Write-Host "Despachador Inteligente para Configuracion Universal" -ForegroundColor White
    Write-Host ""
}

function Show-Success {
    param([string]$Message)
    Write-Host "[OK] $Message" -ForegroundColor Green
}

function Show-Warning {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor Yellow
}

function Show-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

function Show-Info {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Blue
}

function Show-Step {
    param([string]$Message)
    Write-Host "[STEP] $Message" -ForegroundColor Magenta
}

# Funciones de Deteccion del Sistema
function Get-WindowsInfo {
    try {
        Show-Step "Obteniendo informacion del sistema..."
        $os = Get-CimInstance -ClassName Win32_OperatingSystem

        return @{
            Version = $os.Version
            Build = $os.BuildNumber
            ProductName = $os.Caption
            Edition = "Professional"
            IsWindows10 = $os.Version -like "10.*"
            IsWindows11 = $os.Version -like "10.*" -and $os.BuildNumber -ge 22000
        }
    } catch {
        Show-Error "Error al obtener informacion del sistema: $_"
        return $null
    }
}

function Test-WSLCompatibility {
    param([hashtable]$WindowsInfo)

    if (-not $WindowsInfo) {
        return @{ Compatible = $false; Reason = "No se pudo detectar Windows" }
    }

    if ($WindowsInfo.Build -lt 19041) {
        return @{
            Compatible = $false
            Reason = "Windows 10 version 2004 (Build 19041) o superior requerida"
        }
    }

    return @{
        Compatible = $true
        WSL2Available = $true
        Reason = "WSL2 completamente compatible"
    }
}

function Get-WSLStatus {
    try {
        $wslFeature = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -ErrorAction SilentlyContinue
        $wslEnabled = $wslFeature -and $wslFeature.State -eq "Enabled"

        if (-not $wslEnabled) {
            return @{ Installed = $false; HasDistributions = $false }
        }

        $distributions = @()
        try {
            $wslOutput = & wsl -l -v 2>$null
            if ($LASTEXITCODE -eq 0 -and $wslOutput) {
                $distributions = $wslOutput | Select-Object -Skip 1 | Where-Object { $_.Trim() -ne "" }
            }
        } catch {
            # WSL comando no disponible
        }

        return @{
            Installed = $true
            HasDistributions = $distributions.Count -gt 0
        }
    } catch {
        return @{ Installed = $false; HasDistributions = $false }
    }
}

function Test-AdminPrivileges {
    try {
        $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
        $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
        return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    } catch {
        return $false
    }
}

# Funciones de Menu
function Show-SystemInfo {
    param(
        [hashtable]$WindowsInfo,
        [hashtable]$WSLCompatibility,
        [hashtable]$WSLStatus,
        [bool]$IsAdmin
    )

    Show-Info "Sistema detectado: $($WindowsInfo.ProductName)"
    Show-Info "Build: $($WindowsInfo.Build)"

    if ($IsAdmin) {
        Show-Success "Ejecutandose con permisos de administrador"
    } else {
        Show-Warning "Sin permisos de administrador"
    }

    if ($WSLStatus.Installed) {
        if ($WSLStatus.HasDistributions) {
            Show-Success "WSL instalado con distribuciones"
        } else {
            Show-Warning "WSL instalado pero sin distribuciones"
        }
    } else {
        Show-Info "WSL no instalado"
    }

    Write-Host ""
}

function Get-WSLInstallationChoice {
    Write-Host "WSL no esta instalado en tu sistema." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Quieres instalar WSL?" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "1. Si, instalar WSL" -ForegroundColor Green
    Write-Host "2. No, continuar con configuracion normal de Windows" -ForegroundColor Blue
    Write-Host ""
    Write-Host "Opcion (1-2): " -ForegroundColor Yellow -NoNewline

    do {
        $choice = Read-Host
        switch ($choice) {
            "1" { return "InstallWSL" }
            "2" { return "WindowsNative" }
            default {
                Write-Host "Opcion invalida. Intenta nuevamente (1-2): " -ForegroundColor Red -NoNewline
            }
        }
    } while ($true)
}

function Get-TerminalConfigurationChoice {
    Write-Host "WSL esta instalado en tu sistema." -ForegroundColor Green
    Write-Host ""
    Write-Host "Quieres configurar VS Code y el terminal completo?" -ForegroundColor Cyan
    Write-Host "Esto incluye:"
    Write-Host "  - Instalacion y configuracion de VS Code"
    Write-Host "  - Configuracion completa del terminal (Zsh, Oh My Zsh, Powerlevel10k)"
    Write-Host "  - Instalacion de fuentes de desarrollo"
    Write-Host "  - Herramientas de desarrollo y extensiones"
    Write-Host ""
    Write-Host "1. Si, configurar todo el entorno de desarrollo" -ForegroundColor Green
    Write-Host "2. No, continuar con configuracion normal de Windows" -ForegroundColor Blue
    Write-Host ""
    Write-Host "Opcion (1-2): " -ForegroundColor Yellow -NoNewline

    do {
        $choice = Read-Host
        switch ($choice) {
            "1" { return "ConfigureTerminal" }
            "2" { return "WindowsNative" }
            default {
                Write-Host "Opcion invalida. Intenta nuevamente (1-2): " -ForegroundColor Red -NoNewline
            }
        }
    } while ($true)
}

# Funciones de Ejecucion
function Invoke-WSLInstallation {
    Show-Step "Iniciando instalacion de WSL..."

    try {
        Show-Info "Instalando WSL con Ubuntu..."
        & wsl --install -d Ubuntu

        Show-Success "WSL instalado correctamente"
        Show-Warning "Es necesario reiniciar el sistema para completar la instalacion"
        Show-Info "Despues del reinicio, ejecuta este script nuevamente para continuar"

        Write-Host ""
        Write-Host "Quieres reiniciar ahora? (y/n): " -ForegroundColor Yellow -NoNewline
        $restart = Read-Host

        if ($restart -eq "y" -or $restart -eq "Y") {
            Show-Info "Reiniciando sistema..."
            Restart-Computer -Force
        }

        return $true
    } catch {
        Show-Error "Error durante la instalacion de WSL: $_"

        Show-Info "Intentando metodo alternativo..."
        try {
            Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart
            Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart

            Show-Success "WSL habilitado correctamente"
            Show-Warning "Reinicio requerido para completar la instalacion"

            return $true
        } catch {
            Show-Error "Error durante la instalacion alternativa de WSL: $_"
            return $false
        }
    }
}

function Get-PostWSLInstallChoice {
    Write-Host ""
    Write-Host "WSL ha sido instalado exitosamente." -ForegroundColor Green
    Write-Host ""
    Write-Host "Quieres configurar VS Code y el terminal ahora?" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "1. Si, configurar VS Code y terminal" -ForegroundColor Green
    Write-Host "2. No, finalizar instalacion" -ForegroundColor Blue
    Write-Host ""
    Write-Host "Opcion (1-2): " -ForegroundColor Yellow -NoNewline

    do {
        $choice = Read-Host
        switch ($choice) {
            "1" { return "ConfigureAll" }
            "2" { return "Finish" }
            default {
                Write-Host "Opcion invalida. Intenta nuevamente (1-2): " -ForegroundColor Red -NoNewline
            }
        }
    } while ($true)
}

function Invoke-TerminalConfiguration {
    Show-Step "Configurando terminal y herramientas de desarrollo..."

    try {
        & wsl --list --verbose 2>$null | Out-Null
        if ($LASTEXITCODE -ne 0) {
            Show-Error "WSL no esta funcionando correctamente"
            return $false
        }
    } catch {
        Show-Error "WSL no esta disponible"
        return $false
    }

    $scriptDir = $PSScriptRoot
    if (-not $scriptDir) {
        Show-Error "No se pudo determinar el directorio del script."
        return $false
    }

    Show-Info "Abriendo terminal de WSL Ubuntu para configuracion completa..."

    try {
        # Obtener la ruta de WSL
        $wslPath = $null
        try {
            $wslPathOutput = & wsl.exe wslpath -a "$scriptDir" 2>$null
            if ($LASTEXITCODE -eq 0 -and $wslPathOutput) {
                $wslPath = $wslPathOutput.ToString().Trim()
                Show-Info "Ruta convertida de WSL: $wslPath"
            }
        } catch {
            Show-Warning "Error al convertir ruta con wslpath: $_"
        }

        if (-not $wslPath) {
            # Metodo alternativo: usar la ruta directamente
            $wslPath = $scriptDir -replace '^([A-Za-z]):', '/mnt/$1' -replace '\\', '/'
            $wslPath = $wslPath.ToLower()
            Show-Info "Ruta alternativa de WSL: $wslPath"
        }

        # Preparar el directorio completo de instalacion
        Show-Info "Preparando directorio completo de instalacion..."

        # Verificar que el archivo install.sh existe en la ruta de Windows
        $installShPath = Join-Path $scriptDir "install.sh"
        if (-not (Test-Path $installShPath)) {
            Show-Error "Archivo install.sh no encontrado en: $installShPath"
            return $false
        }

        # Copiar toda la carpeta universal-dev-setup al directorio WSL
        Show-Info "Copiando toda la carpeta universal-dev-setup a WSL..."
        $projectName = "universal-dev-setup"

        # Eliminar directorio existente si existe
        $removeCommand = "rm -rf ~/$projectName"
        & wsl bash -c $removeCommand 2>$null

        # Copiar toda la carpeta manteniendo la estructura
        $copyAllCommand = "cp -r '$wslPath' ~/$projectName"
        $copyResult = & wsl bash -c $copyAllCommand 2>&1
        if ($LASTEXITCODE -ne 0) {
            Show-Error "Error al copiar el directorio completo: $copyResult"
            return $false
        }
        Show-Success "Directorio completo copiado correctamente"

        # Verificar que el directorio se copio correctamente
        $verifyDirCommand = "ls -la ~/$projectName/"
        $verifyDirResult = & wsl bash -c $verifyDirCommand 2>&1
        if ($LASTEXITCODE -ne 0) {
            Show-Error "El directorio $projectName no se copio correctamente: $verifyDirResult"
            return $false
        }
        Show-Info "Contenido del directorio copiado:"
        Show-Info "$verifyDirResult"

        # Convertir terminaciones de linea y asignar permisos
        Show-Info "Configurando permisos y formato de archivos..."
        $prepareCommand = "cd ~/$projectName && find . -name '*.sh' -exec sed -i 's/\r$//' {} \; && find . -name '*.sh' -exec chmod +x {} \;"
        $prepareResult = & wsl bash -c $prepareCommand 2>&1
        if ($LASTEXITCODE -ne 0) {
            Show-Error "Error al preparar archivos: $prepareResult"
            return $false
        }
        Show-Success "Archivos preparados correctamente"

        Show-Info "Abriendo terminal de WSL Ubuntu..."
        Show-Info "Se ejecutara install.sh desde el directorio completo del proyecto"
        Show-Info "Esto instalara VS Code, configurara el terminal y todas las herramientas de desarrollo"

        # Ejecutar directamente el script install.sh en WSL desde el directorio del proyecto
        try {
            Show-Info "Ejecutando install.sh en WSL Ubuntu..."

            # Verificar que el directorio y archivo existen antes de ejecutarlo
            $checkCommand = "cd ~/$projectName && ls -la install.sh"
            $checkResult = & wsl bash -c $checkCommand 2>&1
            if ($LASTEXITCODE -ne 0) {
                Show-Error "El archivo install.sh no esta disponible en el directorio del proyecto: $checkResult"
                throw "Archivo no encontrado"
            }

            # Metodo simple: abrir terminal de WSL que se mantenga abierto en el directorio correcto
            try {
                Show-Info "Abriendo terminal de WSL Ubuntu en el directorio del proyecto..."

                # Intentar abrir WSL directamente en el directorio del proyecto con ejecucion automatica
                try {
                    # Metodo 1: Usar --cd y despues ejecutar el script
                    Start-Process -FilePath "wsl.exe" -ArgumentList "-d", "Ubuntu", "--cd", "~/universal-dev-setup", "-e", "bash", "-c", "./install.sh --auto; exec bash" -WindowStyle Normal
                    Show-Success "Terminal de WSL Ubuntu abierta con instalacion automatica"
                    Show-Info "El script install.sh se ejecutara automaticamente"
                    Show-Info "Una vez completado, tendras un terminal bash activo"
                } catch {
                    Show-Warning "Error con metodo de ejecucion automatica: $_"
                    Show-Info "Intentando abrir solo en directorio correcto..."

                    # Metodo 1b: Solo abrir en directorio correcto
                    Start-Process -FilePath "wsl.exe" -ArgumentList "-d", "Ubuntu", "--cd", "~/universal-dev-setup" -WindowStyle Normal
                    Show-Success "Terminal de WSL Ubuntu abierta en ~/universal-dev-setup"
                    Show-Info "En la terminal que se acaba de abrir, ejecuta:"
                    Show-Info "   ./install.sh --auto"
                }
            } catch {
                Show-Warning "Error al abrir terminal con --cd: $_"
                Show-Info "Intentando metodo alternativo..."

                # Metodo alternativo: usar bash -c para cambiar directorio y ejecutar script
                try {
                    Show-Info "Abriendo terminal con ejecucion automatica del script..."
                    Start-Process -FilePath "wsl.exe" -ArgumentList "-d", "Ubuntu", "bash", "-c", "cd ~/universal-dev-setup && ./install.sh --auto; exec bash" -WindowStyle Normal

                    Show-Success "Terminal de WSL Ubuntu abierta con instalacion automatica"
                    Show-Info "El script install.sh se ejecutara automaticamente"
                    Show-Info "Una vez completado, tendras un terminal bash activo en ~/universal-dev-setup"
                } catch {
                    Show-Warning "Error con metodo alternativo: $_"

                    # Metodo 3: Usar cmd para ejecutar con ejecucion automatica
                    try {
                        Show-Info "Intentando con cmd y ejecucion automatica..."
                        Start-Process -FilePath "cmd.exe" -ArgumentList "/c", "start", "cmd", "/k", "wsl -d Ubuntu bash -c 'cd ~/universal-dev-setup && ./install.sh --auto; exec bash'"
                        Show-Success "Terminal WSL abierta con cmd y ejecucion automatica"
                        Show-Info "El script install.sh se ejecutara automaticamente"
                    } catch {
                        Show-Error "Error con cmd: $_"
                        throw "Fallback a metodo manual"
                    }
                }
            }

        } catch {
            Show-Warning "Error al abrir terminal con instalacion automatica: $_"
            Show-Info "Intentando apertura manual de terminal..."

            # Fallback: metodo simple de apertura con ejecucion automatica
            try {
                Show-Info "Metodo de respaldo: apertura con ejecucion automatica..."
                Start-Process -FilePath "wsl.exe" -ArgumentList "-d", "Ubuntu", "bash", "-c", "cd ~/universal-dev-setup && ./install.sh --auto; exec bash"
                Show-Info "Terminal de WSL Ubuntu abierta con instalacion automatica"
                Show-Info "El script install.sh se ejecutara automaticamente"
            } catch {
                Show-Error "No se pudo abrir terminal de WSL: $_"
                Show-Info "Como ultimo recurso, abre manualmente una terminal de WSL Ubuntu y ejecuta:"
                Show-Info "   cd ~/universal-dev-setup"
                Show-Info "   ./install.sh --auto"
                return $false
            }
        }

        Show-Info "Proyecto completo instalado en WSL"
        Show-Info "Directorio: ~/universal-dev-setup"
        Show-Info "La instalacion se ejecutara automaticamente en el terminal de WSL"
        Show-Info "Espera a que termine la instalacion completa"
        Show-Info "Una vez completada la instalacion, puedes cerrar esta ventana de PowerShell"

        return $true
    } catch {
        Show-Error "Error durante la configuracion del terminal: $_"
        Show-Info "Continuando con configuracion de Windows nativo como respaldo..."
        Invoke-WindowsNativeSetup
        return $false
    }
}

function Invoke-WindowsNativeSetup {
    Show-Step "Iniciando configuracion para Windows nativo..."

    $installPath = Join-Path $PSScriptRoot "install.ps1"

    if (Test-Path $installPath) {
        Show-Info "Ejecutando install.ps1..."
        & $installPath
        Show-Success "Configuracion Windows completada"
        return $true
    } else {
        Show-Error "Script install.ps1 no encontrado: $installPath"
        return $false
    }
}

# Funcion Principal
function Main {
    Show-Banner

    Show-Step "Detectando configuracion del sistema..."

    $windowsInfo = Get-WindowsInfo
    if (-not $windowsInfo) {
        Show-Error "No se pudo detectar la informacion del sistema"
        Read-Host "Presiona Enter para salir"
        exit 1
    }

    $wslCompatibility = Test-WSLCompatibility -WindowsInfo $windowsInfo
    $wslStatus = Get-WSLStatus
    $isAdmin = Test-AdminPrivileges

    Show-SystemInfo -WindowsInfo $windowsInfo -WSLCompatibility $wslCompatibility -WSLStatus $wslStatus -IsAdmin $isAdmin

    if (-not $isAdmin) {
        Show-Warning "Este script requiere permisos de administrador para instalar WSL"
        Show-Info "Detectamos que no se abrio la ventana con permisos de administrador. Para continuar con la instalacion, debe abrir este programa manualmente con permisos de administrador."

        try {
            $currentScript = $MyInvocation.MyCommand.Path
            if (-not $currentScript) {
                $currentScript = $PSCommandPath
            }
            if (-not $currentScript) {
                $currentScript = $MyInvocation.ScriptName
            }

            Show-Info "Ruta del script: $currentScript"

            # Usar -File en lugar de -Command para mayor compatibilidad
            Start-Process powershell -ArgumentList "-NoExit", "-ExecutionPolicy", "Bypass", "-File", "`"$currentScript`"" -Verb RunAs
            Show-Info "Ventana de administrador abierta correctamente. Este script finalizara ahora."
        } catch {
            Show-Error "Error al intentar abrir la ventana con permisos de administrador: $_"
            Show-Info "Por favor, intente abrir este programa manualmente con permisos de administrador."
        }

        exit
    }

    if (-not $wslCompatibility.Compatible) {
        Show-Error "WSL no es compatible con este sistema: $($wslCompatibility.Reason)"
        Show-Info "Ejecutando configuracion solo para Windows..."
        Invoke-WindowsNativeSetup
        exit
    }

    if (-not $wslStatus.Installed) {
        $userChoice = Get-WSLInstallationChoice

        if ($userChoice -eq "InstallWSL") {
            Show-Step "Instalando WSL..."
            $success = Invoke-WSLInstallation
            if ($success) {
                # Despues de instalar WSL, preguntar si quiere configurar VS Code y terminal
                $postInstallChoice = Get-PostWSLInstallChoice

                if ($postInstallChoice -eq "ConfigureAll") {
                    Show-Step "Configurando VS Code y terminal..."
                    $configSuccess = Invoke-TerminalConfiguration
                    if (-not $configSuccess) {
                        Show-Error "Error al configurar terminal"
                    }
                } else {
                    Show-Info "Instalacion completada. WSL esta listo para usar."
                }
            } else {
                Show-Error "Error al instalar WSL, continuando con configuracion de Windows"
                Invoke-WindowsNativeSetup
            }
        } else {
            Show-Info "Continuando con configuracion de Windows..."
            Invoke-WindowsNativeSetup
        }
    } elseif ($wslStatus.HasDistributions) {
        $userChoice = Get-TerminalConfigurationChoice

        if ($userChoice -eq "ConfigureTerminal") {
            Show-Step "Configurando terminal..."
            $success = Invoke-TerminalConfiguration
            if (-not $success) {
                Show-Error "Error al configurar terminal, continuando con configuracion de Windows"
                Invoke-WindowsNativeSetup
            }
        } else {
            Show-Info "Continuando con configuracion de Windows..."
            Invoke-WindowsNativeSetup
        }
    } else {
        Show-Info "WSL esta instalado pero no tiene distribuciones"
        Show-Info "Instalando Ubuntu..."

        try {
            & wsl --install -d Ubuntu
            Show-Success "Ubuntu instalado correctamente"
            Show-Warning "Reinicio puede ser necesario"

            # Despues de instalar Ubuntu, preguntar si quiere configurar VS Code y terminal
            $postInstallChoice = Get-PostWSLInstallChoice

            if ($postInstallChoice -eq "ConfigureAll") {
                Show-Step "Configurando VS Code y terminal..."
                $configSuccess = Invoke-TerminalConfiguration
                if (-not $configSuccess) {
                    Show-Error "Error al configurar terminal"
                }
            } else {
                Show-Info "Instalacion completada. WSL esta listo para usar."
            }
        } catch {
            Show-Error "Error al instalar Ubuntu: $_"
            Show-Info "Continuando con configuracion de Windows..."
            Invoke-WindowsNativeSetup
        }
    }

    Write-Host ""
    Show-Success "Configuracion completada!"
    Show-Info "Presiona Enter para salir..."
    Read-Host
}

# Ejecutar funcion principal
try {
    Main
} catch {
    Show-Error "Error inesperado: $_"
    Show-Info "Presiona Enter para salir..."
    Read-Host
    exit 1
}
