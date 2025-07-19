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

function Install-WindowsTerminal {
    Show-Step "Instalando terminal de Windows..."
    try {
        $terminalPackage = "Microsoft.WindowsTerminal"
        $installed = Get-AppxPackage -Name $terminalPackage -ErrorAction SilentlyContinue
        if ($installed) {
            Show-Success "Terminal de Windows ya está instalado."
            return $true
        }

        # Intentar instalar con winget si está disponible
        $wingetAvailable = Get-Command winget -ErrorAction SilentlyContinue
        if ($wingetAvailable) {
            Show-Info "Intentando instalar Windows Terminal con winget..."
            $wingetCmd = "winget install --id Microsoft.WindowsTerminal -e --source msstore --accept-package-agreements --accept-source-agreements"
            $job = Start-Job -ScriptBlock { param($cmd) Invoke-Expression $cmd } -ArgumentList $wingetCmd
            $timeout = 60 # segundos
            $elapsed = 0
            while ($job.State -eq 'Running' -and $elapsed -lt $timeout) {
                Start-Sleep -Seconds 2
                $elapsed += 2
                if ($elapsed -eq 20) {
                    Show-Info "La instalación puede requerir interacción. Si ves una ventana de instalación, acéptala o revisa la Microsoft Store."
                }
            }
            if ($job.State -eq 'Running') {
                Show-Warning "La instalación de Windows Terminal con winget está tardando demasiado. Puedes cancelar la ventana o instalar manualmente."
                Stop-Job $job | Out-Null
            }
            Receive-Job $job | Out-Null
            Remove-Job $job | Out-Null
            $installed = Get-AppxPackage -Name $terminalPackage -ErrorAction SilentlyContinue
            if ($installed) {
                Show-Success "Terminal de Windows instalado correctamente con winget."
                return $true
            } else {
                Show-Warning "No se pudo instalar automáticamente con winget."
            }
        }

        # Si winget falla, abrir la Microsoft Store en la página de Windows Terminal
        Show-Info "Abriendo Microsoft Store para instalar Windows Terminal manualmente..."
        Start-Process "ms-windows-store://pdp/?ProductId=9N0DX20HK701"
        Show-Warning "Por favor, instala Windows Terminal manualmente desde la ventana de la tienda que se abrió."
        Show-Info "Si la tienda no se abre, visita: https://aka.ms/terminal-preview"
        return $false
    } catch {
        Show-Error "Error al instalar el terminal de Windows: $_"
        Show-Info "Instala manualmente desde: https://aka.ms/terminal-preview"
        return $false
    }
}

function Ensure-GitInstalled {
    Show-Step "Verificando instalación de Git..."
    $gitAvailable = Get-Command git -ErrorAction SilentlyContinue
    if ($gitAvailable) {
        Show-Success "Git ya está instalado."
        return $true
    }
    Show-Info "Instalando Git..."
    try {
        $wingetAvailable = Get-Command winget -ErrorAction SilentlyContinue
        if ($wingetAvailable) {
            & winget install --id Git.Git -e --source winget
            if ($LASTEXITCODE -eq 0) {
                Show-Success "Git instalado correctamente."
                return $true
            } else {
                Show-Warning "Error al instalar Git con winget."
            }
        }
        Show-Warning "No se pudo instalar Git automáticamente. Instálalo manualmente desde https://git-scm.com/download/win"
        return $false
    } catch {
        Show-Error "Error al instalar Git: $_"
        Show-Info "Instala manualmente desde: https://git-scm.com/download/win"
        return $false
    }
}

# Funciones de Configuracion
function Invoke-TerminalConfiguration {
    Show-Step "Iniciando configuracion completa de WSL con Windows Terminal..."

    # Verificar que WSL esta funcionando
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

    # Paso 1: Instalar Windows Terminal
    Show-Info "Paso 1: Instalando Windows Terminal..."
    $wtInstalled = Install-WindowsTerminal
    if (-not $wtInstalled) {
        Show-Warning "Windows Terminal no pudo ser instalado. Continuando con terminal predeterminado..."
    }

    # Paso 2: Configurar VS Code para WSL
    Show-Info "Paso 2: Configurando VS Code para WSL..."
    $vscodeConfigured = Configure-VSCodeForWSL
    if (-not $vscodeConfigured) {
        Show-Warning "VS Code no pudo ser configurado completamente. Continuando..."
    }
    # Paso 2.5: Instalar Git
    Show-Info "Paso 2.5: Verificando e instalando Git..."
    $gitInstalled = Ensure-GitInstalled
    if (-not $gitInstalled) {
        Show-Warning "Git no pudo ser instalado automáticamente."
    }

    # Paso 3: Copiar proyecto a WSL
    Show-Info "Paso 3: Copiando proyecto a entorno WSL..."
    $scriptDir = $PSScriptRoot
    if (-not $scriptDir) {
        Show-Error "No se pudo determinar el directorio del script."
        return $false
    }

    $projectCopied = Copy-ProjectToWSL -SourcePath $scriptDir
    if (-not $projectCopied) {
        Show-Error "No se pudo copiar el proyecto a WSL"
        return $false
    }

    # Paso 4: Abrir Windows Terminal en WSL con ejecucion automatica
    Show-Info "Paso 4: Abriendo Windows Terminal en WSL Ubuntu..."
    Show-Info "Se ejecutara install.sh automaticamente desde ~/universal-dev-setup"
    Show-Info "Esto instalara y configurara todas las herramientas de desarrollo"
    try {
        $wtAvailable = Get-Command "wt.exe" -ErrorAction SilentlyContinue
        if ($wtAvailable -and $wtInstalled) {
            Show-Info "Usando Windows Terminal para mejor experiencia..."
            try {
                Start-Process -FilePath "wt.exe" -ArgumentList "-p", "Ubuntu", "bash", "-c", "cd ~/universal-dev-setup && ./install.sh --auto" -WindowStyle Normal
                Show-Success "Windows Terminal abierto con instalacion automatica"
            } catch {
                Show-Warning "Error con Windows Terminal: $_"
                throw "Fallback to WSL"
            }
        } else {
            throw "Windows Terminal no disponible"
        }
    } catch {
        Show-Info "Usando terminal WSL predeterminado..."
        try {
            # Usar WSL directo para ejecutar install.sh automáticamente
            Start-Process -FilePath "wsl.exe" -ArgumentList "-d", "Ubuntu", "bash", "-c", "cd ~/universal-dev-setup && ./install.sh --auto" -WindowStyle Normal
            Show-Success "Terminal WSL abierto con instalacion automatica (bash -c)"
        } catch {
            Show-Error "Error al abrir terminal WSL: $_"
            Show-Info "Por favor, abre manualmente WSL Ubuntu y ejecuta:"
            Show-Info "   cd ~/universal-dev-setup"
            Show-Info "   ./install.sh --auto"
            return $false
        }
    }

    # Paso 5: Abrir VS Code en el directorio del proyecto WSL
    if ($vscodeConfigured) {
        Show-Info "Paso 5: Abriendo VS Code en el directorio del proyecto WSL..."

        try {
            # Esperar un poco para que el proyecto se configure
            Start-Sleep -Seconds 3

            # Abrir VS Code en el directorio WSL
            Start-Process -FilePath "code" -ArgumentList "--remote", "wsl+Ubuntu", "~/universal-dev-setup" -WindowStyle Normal
            Show-Success "VS Code abierto en entorno WSL"
        } catch {
            Show-Warning "Error al abrir VS Code en WSL: $_"
            Show-Info "Puedes abrir VS Code manualmente y usar 'Remote-WSL: Open Folder in WSL'"
            Show-Info "Selecciona la carpeta ~/universal-dev-setup"
        }
    }

    Show-Success "Configuracion completa iniciada!"
    Show-Info "Resumen de lo configurado:"
    Show-Info "  ✓ Windows Terminal: $(if ($wtInstalled) { 'Instalado' } else { 'No disponible' })"
    Show-Info "  ✓ VS Code WSL: $(if ($vscodeConfigured) { 'Configurado' } else { 'No configurado' })"
    Show-Info "  ✓ Proyecto en WSL: ~/universal-dev-setup"
    Show-Info "  ✓ Instalacion automatica: En progreso"
    Show-Info ""
    Show-Info "La instalacion se ejecutara automaticamente en el terminal de WSL"
    Show-Info "Una vez completada, tendras un entorno de desarrollo completo configurado"
    Show-Info "Puedes cerrar esta ventana de PowerShell cuando termine la instalacion"

    return $true
}

function Configure-VSCodeForWSL {
    Show-Step "Configurando VS Code para WSL..."

    # Verificar si VS Code esta instalado
    $vscodeInstalled = $false
    $vscodePaths = @(
        "${env:LOCALAPPDATA}\Programs\Microsoft VS Code\Code.exe",
        "${env:PROGRAMFILES}\Microsoft VS Code\Code.exe",
        "${env:PROGRAMFILES(X86)}\Microsoft VS Code\Code.exe"
    )

    foreach ($path in $vscodePaths) {
        if (Test-Path $path) {
            $vscodeInstalled = $true
            $vscodePath = $path
            break
        }
    }

    if (-not $vscodeInstalled) {
        Show-Warning "VS Code no esta instalado"
        Show-Info "Instalando VS Code..."

        try {
            & winget install Microsoft.VisualStudioCode 2>$null
            if ($LASTEXITCODE -eq 0) {
                Show-Success "VS Code instalado correctamente"
                # Esperar un poco para que se complete la instalacion
                Start-Sleep -Seconds 5
                $vscodeInstalled = $true
            } else {
                Show-Warning "Error al instalar VS Code con winget"
            }
        } catch {
            Show-Warning "No se pudo instalar VS Code automaticamente"
        }
    } else {
        Show-Success "VS Code ya esta instalado"
    }

    if ($vscodeInstalled) {
        Show-Info "Instalando extension WSL para VS Code..."

        try {
            # Instalar extension WSL
            & code --install-extension ms-vscode-remote.remote-wsl --force 2>$null
            if ($LASTEXITCODE -eq 0) {
                Show-Success "Extension WSL instalada correctamente"
            } else {
                Show-Warning "Error al instalar extension WSL"
            }

            # Instalar extension Remote Development (incluye WSL, SSH, Containers)
            & code --install-extension ms-vscode-remote.vscode-remote-extensionpack --force 2>$null
            if ($LASTEXITCODE -eq 0) {
                Show-Success "Extension Remote Development instalada correctamente"
            } else {
                Show-Warning "Error al instalar extension Remote Development"
            }

            # Configurar VS Code para usar WSL como terminal por defecto
            $vscodeSettings = @{
                "terminal.integrated.defaultProfile.windows" = "Ubuntu (WSL)"
                "terminal.integrated.profiles.windows" = @{
                    "Ubuntu (WSL)" = @{
                        "path" = "wsl.exe"
                        "args" = @("-d", "Ubuntu")
                    }
                }
            }

            $settingsPath = "${env:APPDATA}\Code\User\settings.json"
            $settingsDir = Split-Path $settingsPath -Parent

            if (-not (Test-Path $settingsDir)) {
                New-Item -ItemType Directory -Path $settingsDir -Force | Out-Null
            }

            $currentSettings = @{}
            if (Test-Path $settingsPath) {
                try {
                    $currentSettings = Get-Content $settingsPath -Raw | ConvertFrom-Json -AsHashtable
                } catch {
                    Show-Warning "Error al leer configuracion existente de VS Code"
                }
            }

            # Fusionar configuraciones
            foreach ($key in $vscodeSettings.Keys) {
                $currentSettings[$key] = $vscodeSettings[$key]
            }

            # Guardar configuracion
            $currentSettings | ConvertTo-Json -Depth 10 | Set-Content $settingsPath -Encoding UTF8
            Show-Success "VS Code configurado para usar WSL como terminal por defecto"

            return $true
        } catch {
            Show-Warning "Error al configurar VS Code: $_"
            return $false
        }
    }

    return $false
}

function Copy-ProjectToWSL {
    param(
        [string]$SourcePath,
        [string]$ProjectName = "universal-dev-setup"
    )

    Show-Step "Copiando proyecto a entorno WSL..."

    try {
        # Obtener la ruta de WSL
        $wslPath = $null
        try {
            $wslPathOutput = & wsl.exe wslpath -a "$SourcePath" 2>$null
            if ($LASTEXITCODE -eq 0 -and $wslPathOutput) {
                $wslPath = $wslPathOutput.ToString().Trim()
                Show-Info "Ruta convertida de WSL: $wslPath"
            }
        } catch {
            Show-Warning "Error al convertir ruta con wslpath: $_"
        }

        if (-not $wslPath) {
            # Metodo alternativo: usar la ruta directamente
            $wslPath = $SourcePath -replace '^([A-Za-z]):', '/mnt/$1' -replace '\\', '/'
            $wslPath = $wslPath.ToLower()
            Show-Info "Ruta alternativa de WSL: $wslPath"
        }

        # Eliminar directorio existente si existe
        $removeCommand = "rm -rf ~/$ProjectName"
        & wsl bash -c $removeCommand 2>$null

        # Copiar toda la carpeta manteniendo la estructura
        $copyAllCommand = "cp -r '$wslPath' ~/$ProjectName"
        $copyResult = & wsl bash -c $copyAllCommand 2>&1
        if ($LASTEXITCODE -ne 0) {
            Show-Error "Error al copiar el directorio completo: $copyResult"
            return $false
        }
        Show-Success "Proyecto copiado a ~/universal-dev-setup"

        # Convertir terminaciones de linea y asignar permisos
        Show-Info "Configurando permisos y formato de archivos..."
        $prepareCommand = "cd ~/$ProjectName && find . -name '*.sh' -exec sed -i 's/\r$//' {} \; && find . -name '*.sh' -exec chmod +x {} \;"
        $prepareResult = & wsl bash -c $prepareCommand 2>&1
        if ($LASTEXITCODE -ne 0) {
            Show-Error "Error al preparar archivos: $prepareResult"
            return $false
        }
        Show-Success "Archivos preparados correctamente (permisos y terminaciones de linea)"

        return $true
    } catch {
        Show-Error "Error al copiar proyecto a WSL: $_"
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

    # Verificar Windows Terminal antes de continuar con WSL
    Show-Info "Verificando Windows Terminal para mejor experiencia de WSL..."
    $wtCheck = Install-WindowsTerminal
    if ($wtCheck) {
        Show-Success "Windows Terminal listo para usar"
    } else {
        Show-Warning "Windows Terminal no disponible, se usara terminal predeterminado"
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
                    Show-Step "Configurando entorno completo de WSL..."
                    $configSuccess = Invoke-TerminalConfiguration
                    if (-not $configSuccess) {
                        Show-Error "Error al configurar entorno WSL"
                        Show-Info "Continuando con configuracion de Windows nativo..."
                        Invoke-WindowsNativeSetup
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
            Show-Step "Configurando entorno completo de WSL..."
            $success = Invoke-TerminalConfiguration
            if (-not $success) {
                Show-Error "Error al configurar entorno WSL, continuando con configuracion de Windows"
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
                Show-Step "Configurando entorno completo de WSL..."
                $configSuccess = Invoke-TerminalConfiguration
                if (-not $configSuccess) {
                    Show-Error "Error al configurar entorno WSL"
                    Show-Info "Continuando con configuracion de Windows nativo..."
                    Invoke-WindowsNativeSetup
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
