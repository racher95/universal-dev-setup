#!/usr/bin/env powershell
# DISPATCHER UNIVERSAL - Windows Development Setup
# Despachador inteligente para configuracion de desarrollo

$ErrorActionPreference = "Stop"
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
    Write-Host "¿Quieres instalar WSL?" -ForegroundColor Cyan
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
    Write-Host "¿Quieres configurar el terminal y herramientas de desarrollo?" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "1. Si, configurar terminal completo" -ForegroundColor Green
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
        Write-Host "¿Quieres reiniciar ahora? (y/n): " -ForegroundColor Yellow -NoNewline
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
    Write-Host "¿Quieres configurar VS Code y el terminal ahora?" -ForegroundColor Cyan
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
    Show-Info "Ejecutando configuracion de terminal en WSL..."

    try {
        $wslPath = (wsl.exe wslpath -a $scriptDir).Trim()
        
        Show-Info "Ejecutando: wsl bash -c 'cd $wslPath ; ./install.sh'"
        & wsl bash -c "cd '$wslPath' ; ./install.sh"

        Show-Success "Configuracion de terminal completada"
        return $true
    } catch {
        Show-Error "Error durante la configuracion del terminal: $_"
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
        Show-Info "Reiniciando como administrador..."
        
        $currentScript = $MyInvocation.MyCommand.Path
        Start-Process powershell -ArgumentList "-ExecutionPolicy Bypass -File `"$currentScript`"" -Verb RunAs
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
                # Después de instalar WSL, preguntar si quiere configurar VS Code y terminal
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
            
            # Después de instalar Ubuntu, preguntar si quiere configurar VS Code y terminal
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
