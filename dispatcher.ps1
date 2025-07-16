#!/usr/bin/env powershell
# ═══════════════════════════════════════════════════════════════════════════════
# 🎯 DISPATCHER UNIVERSAL - Windows Development Setup
# ═══════════════════════════════════════════════════════════════════════════════
#
# Despachador inteligente para Windows que:
# - Detecta versión y edición de Windows
# - Verifica compatibilidad con WSL/WSL2
# - Presenta menú interactivo según capacidades del sistema
# - Deriva a scripts especializados según la elección del usuario
#
# Autor: Kevin Camara (racher95)
# Versión: 1.0
# Compatible: Windows 10 (2004+), Windows 11
# ═══════════════════════════════════════════════════════════════════════════════

# Configuración de PowerShell
$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

# Colores para output
$Global:Colors = @{
    Red     = "Red"
    Green   = "Green"
    Yellow  = "Yellow"
    Blue    = "Blue"
    Purple  = "Magenta"
    Cyan    = "Cyan"
    White   = "White"
}

# ═══════════════════════════════════════════════════════════════════════════════
# 🎨 FUNCIONES DE DISPLAY Y LOGGING
# ═══════════════════════════════════════════════════════════════════════════════

function Show-Banner {
    Clear-Host
    Write-Host ""
    Write-Host "╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "│            🪟 WINDOWS DEVELOPMENT SETUP 3.0                │" -ForegroundColor Cyan
    Write-Host "│                                                              │" -ForegroundColor Cyan
    Write-Host "│     Despachador Inteligente para Configuración Universal    │" -ForegroundColor White
    Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
}

function Show-Success {
    param([string]$Message)
    Write-Host "✅ $Message" -ForegroundColor Green
}

function Show-Warning {
    param([string]$Message)
    Write-Host "⚠️  $Message" -ForegroundColor Yellow
}

function Show-Error {
    param([string]$Message)
    Write-Host "❌ $Message" -ForegroundColor Red
}

function Show-Info {
    param([string]$Message)
    Write-Host "ℹ️  $Message" -ForegroundColor Blue
}

function Show-Step {
    param([string]$Message)
    Write-Host "🔧 $Message" -ForegroundColor Magenta
} # Missing closing brace was here

# ═══════════════════════════════════════════════════════════════════════════════
# 🔍 FUNCIONES DE DETECCIÓN DEL SISTEMA
# ═══════════════════════════════════════════════════════════════════════════════

function Get-WindowsInfo {
    try {
        $os = Get-CimInstance -ClassName Win32_OperatingSystem
        $version = $os.Version
        $buildNumber = $os.BuildNumber
        $productName = $os.Caption
        $edition = $os.OperatingSystemSKU

        # Detectar edición específica
        $editionName = switch ($edition) {
            101 { "Home" }
            100 { "Home Single Language" }
            4   { "Enterprise" }
            1   { "Ultimate" }
            48  { "Professional" }
            49  { "Professional N" }
            default { "Unknown ($edition)" }
        }

        return @{
            Version = $version
            Build = $buildNumber
            ProductName = $productName
            Edition = $editionName
            IsWindows10 = $version -like "10.*"
            IsWindows11 = $version -like "10.*" -and $buildNumber -ge 22000
        }
    } catch {
        Show-Error "No se pudo obtener información del sistema"
        return $null
    }
}

function Test-WSLCompatibility {
    param([hashtable]$WindowsInfo)

    if (-not $WindowsInfo) {
        return @{ Compatible = $false; Reason = "No se pudo detectar Windows" }
    }

    # Verificar versión mínima
    if ($WindowsInfo.Build -lt 19041) {
        return @{
            Compatible = $false
            Reason = "Windows 10 versión 2004 (Build 19041) o superior requerida"
        }
    }

    # Verificar Hyper-V para WSL2
    $hyperVAvailable = $false
    try {
        $hyperVFeature = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All -ErrorAction SilentlyContinue
        $hyperVAvailable = $hyperVFeature -and $hyperVFeature.State -eq "Enabled"
    } catch {
        # Hyper-V no disponible (típico en Home)
        $hyperVAvailable = $false
    }

    # Verificar si es edición Home
    $isHomeEdition = $WindowsInfo.Edition -like "*Home*"

    if ($isHomeEdition -and -not $hyperVAvailable) {
        return @{
            Compatible = $true
            WSL2Available = $false
            Reason = "Windows Home: Solo WSL1 disponible (sin Hyper-V)"
            Recommendation = "Actualizar a Windows Pro para WSL2 completo"
        }
    } elseif ($hyperVAvailable -or -not $isHomeEdition) {
        return @{
            Compatible = $true
            WSL2Available = $true
            Reason = "WSL2 completamente compatible"
            Recommendation = "Configuración completa recomendada"
        }
    } else {
        return @{
            Compatible = $true
            WSL2Available = $false
            Reason = "WSL1 disponible"
            Recommendation = "Funcional pero limitado"
        }
    }
}

function Get-WSLStatus {
    try {
        # Verificar si WSL está habilitado
        $wslFeature = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -ErrorAction SilentlyContinue
        $wslEnabled = $wslFeature -and $wslFeature.State -eq "Enabled"

        if (-not $wslEnabled) {
            return @{ Installed = $false; Distributions = @() }
        }

        # Verificar distribuciones instaladas
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
            Distributions = $distributions
            HasDistributions = $distributions.Count -gt 0
        }
    } catch {
        return @{ Installed = $false; Distributions = @() }
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

# ═══════════════════════════════════════════════════════════════════════════════
# 🎯 FUNCIONES DE MENÚ INTERACTIVO
# ═══════════════════════════════════════════════════════════════════════════════

function Show-SystemInfo {
    param(
        [hashtable]$WindowsInfo,
        [hashtable]$WSLCompatibility,
        [hashtable]$WSLStatus,
        [bool]$IsAdmin
    )

    Show-Info "Sistema detectado: $($WindowsInfo.ProductName)"
    Show-Info "Edición: $($WindowsInfo.Edition)"
    Show-Info "Build: $($WindowsInfo.Build)"

    if ($IsAdmin) {
        Show-Success "Ejecutándose con permisos de administrador"
    } else {
        Show-Warning "Sin permisos de administrador (requeridos para WSL)"
    }

    # Estado WSL
    if ($WSLCompatibility.Compatible) {
        if ($WSLCompatibility.WSL2Available) {
            Show-Success "WSL2 completamente compatible"
        } else {
            Show-Warning "Solo WSL1 disponible ($($WSLCompatibility.Reason))"
        }
    } else {
        Show-Error "WSL no compatible: $($WSLCompatibility.Reason)"
    }

    # Estado actual WSL
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

function Show-MainMenu {
    param(
        [hashtable]$WSLCompatibility,
        [hashtable]$WSLStatus,
        [bool]$IsAdmin
    )

    Write-Host "Selecciona una opción:" -ForegroundColor Yellow
    Write-Host ""

    # Opciones dinámicas basadas en capacidades
    $optionNumber = 1
    $options = @{}

    if ($WSLCompatibility.Compatible -and $IsAdmin) {
        if (-not $WSLStatus.Installed) {
            Write-Host "  $optionNumber. 🐧 Instalar WSL + Configuración completa (RECOMENDADO)" -ForegroundColor Green
            $options[$optionNumber] = "InstallWSLFull"
            $optionNumber++

            Write-Host "  $optionNumber. 🐧 Solo instalar WSL (sin configurar terminal)" -ForegroundColor White
            $options[$optionNumber] = "InstallWSLBasic"
            $optionNumber++
        } elseif ($WSLStatus.HasDistributions) {
            Write-Host "  $optionNumber. 🐧 Usar WSL existente + Configuración completa" -ForegroundColor Green
            $options[$optionNumber] = "UseExistingWSL"
            $optionNumber++
        } else {
            Write-Host "  $optionNumber. 🐧 Configurar WSL (instalar distribución)" -ForegroundColor Green
            $options[$optionNumber] = "ConfigureWSL"
            $optionNumber++
        }

        if (-not $WSLCompatibility.WSL2Available) {
            Write-Host "     ⚠️  Limitado a WSL1 en esta edición de Windows" -ForegroundColor Yellow
        }
    } elseif ($WSLCompatibility.Compatible -and -not $IsAdmin) {
        Write-Host "  $optionNumber. 🐧 Instalar WSL (requiere ejecutar como administrador)" -ForegroundColor Gray
        $options[$optionNumber] = "RequireAdmin"
        $optionNumber++
    }

    Write-Host "  $optionNumber. 🪟 Configuración solo para Windows (sin WSL)" -ForegroundColor Blue
    $options[$optionNumber] = "WindowsNative"
    $optionNumber++

    Write-Host "  $optionNumber. ❌ Cancelar" -ForegroundColor Red
    $options[$optionNumber] = "Cancel"

    Write-Host ""
    Write-Host "Opción (1-$optionNumber): " -ForegroundColor Yellow -NoNewline

    do {
        $choice = Read-Host
        $choiceNum = 0
        if ([int]::TryParse($choice, [ref]$choiceNum) -and $options.ContainsKey($choiceNum)) {
            return $options[$choiceNum]
        }
        Write-Host "Opción inválida. Intenta nuevamente (1-$optionNumber): " -ForegroundColor Red -NoNewline
    } while ($true)
}

# ═══════════════════════════════════════════════════════════════════════════════
# 🚀 FUNCIONES DE EJECUCIÓN
# ═══════════════════════════════════════════════════════════════════════════════

function Invoke-WSLInstallation {
    param([bool]$ConfigureTerminal = $false)

    Show-Step "Iniciando instalación de WSL..."

    # Verificar si existe el script de instalación WSL
    $wslInstallerPath = Join-Path $PSScriptRoot "scripts\wsl-installer.ps1"

    if (Test-Path $wslInstallerPath) {
        Show-Info "Ejecutando script de instalación WSL..."
        if ($ConfigureTerminal) {
            & $wslInstallerPath -ConfigureTerminal
        } else {
            & $wslInstallerPath
        }
    } else {
        Show-Error "Script de instalación WSL no encontrado: $wslInstallerPath"
        Show-Info "Instalando WSL manualmente..."

        try {
            # Habilitar WSL
            Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart

            # Intentar habilitar WSL2 (si está disponible)
            try {
                Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart
                Show-Success "WSL2 habilitado"
            } catch {
                Show-Warning "WSL2 no disponible, usando WSL1"
            }

            # Instalar distribución por defecto
            Show-Info "Instalando Ubuntu..."
            & wsl --install -d Ubuntu

            Show-Success "WSL instalado correctamente"
            Show-Warning "Reinicio requerido para completar la instalación"

        } catch {
            Show-Error "Error durante la instalación manual de WSL: $_"
            return $false
        }
    }

    return $true
}

function Invoke-WSLConfiguration {
    Show-Step "Configurando WSL existente..."

    # Cambiar al directorio del script para ejecutar install.sh
    $currentDir = Get-Location
    $scriptDir = $PSScriptRoot

    Show-Info "Ejecutando configuración principal en WSL..."

    try {
        # Convertir ruta de Windows a formato WSL de forma robusta
        $wslPath = (wsl.exe wslpath -a $scriptDir).Trim()

        # Ejecutar install.sh en WSL
        & wsl bash -c "cd '$wslPath' && ./install.sh --auto"

        Show-Success "Configuración WSL completada"
        return $true
    } catch {
        Show-Error "Error durante la configuración WSL: $_"
        return $false
    }
}

function Invoke-WindowsNativeSetup {
    Show-Step "Iniciando configuración para Windows nativo..."

    # Verificar que install.ps1 existe
    $installPath = Join-Path $PSScriptRoot "install.ps1"

    if (Test-Path $installPath) {
        Show-Info "Ejecutando install.ps1..."
        & $installPath
        Show-Success "Configuración Windows completada"
        return $true
    } else {
        Show-Error "Script install.ps1 no encontrado: $installPath"
        return $false
    }
}

function Request-AdminRestart {
    Show-Warning "Esta operación requiere permisos de administrador"
    Show-Info "Reiniciando script como administrador..."

    $currentScript = $MyInvocation.MyCommand.Path
    Start-Process powershell -ArgumentList "-ExecutionPolicy Bypass -File `"$currentScript`"" -Verb RunAs
    exit
}

# ═══════════════════════════════════════════════════════════════════════════════
# 🎯 FUNCIÓN PRINCIPAL
# ═══════════════════════════════════════════════════════════════════════════════

function Main {
    Show-Banner

    # Detectar información del sistema
    Show-Step "Detectando configuración del sistema..."

    $windowsInfo = Get-WindowsInfo
    if (-not $windowsInfo) {
        Show-Error "No se pudo detectar la información del sistema"
        Read-Host "Presiona Enter para salir"
        exit 1
    }

    $wslCompatibility = Test-WSLCompatibility -WindowsInfo $windowsInfo
    $wslStatus = Get-WSLStatus
    $isAdmin = Test-AdminPrivileges

    # Mostrar información del sistema
    Show-SystemInfo -WindowsInfo $windowsInfo -WSLCompatibility $wslCompatibility -WSLStatus $wslStatus -IsAdmin $isAdmin

    # Mostrar menú y obtener elección
    $userChoice = Show-MainMenu -WSLCompatibility $wslCompatibility -WSLStatus $wslStatus -IsAdmin $isAdmin

    Write-Host ""
    Show-Step "Procesando opción seleccionada..."

    # Ejecutar según la elección
    switch ($userChoice) {
        "InstallWSLFull" {
            $success = Invoke-WSLInstallation -ConfigureTerminal $true
            if ($success) {
                Show-Info "Ejecutando configuración completa..."
                Invoke-WSLConfiguration
            }
        }
        "InstallWSLBasic" {
            $success = Invoke-WSLInstallation -ConfigureTerminal $false
            if ($success) {
                Show-Info "Ejecutando configuración básica..."
                Invoke-WSLConfiguration
            }
        }
        "UseExistingWSL" {
            Invoke-WSLConfiguration
        }
        "ConfigureWSL" {
            Show-Info "Configurando WSL existente..."
            Invoke-WSLConfiguration
        }
        "WindowsNative" {
            Invoke-WindowsNativeSetup
        }
        "RequireAdmin" {
            Request-AdminRestart
        }
        "Cancel" {
            Show-Info "Operación cancelada por el usuario"
            exit 0
        }
        default {
            Show-Error "Opción no reconocida: $userChoice"
            exit 1
        }
    }

    Write-Host ""
    Show-Success "🎉 Configuración completada!"
    Show-Info "Presiona Enter para salir..."
    Read-Host
}

# ═══════════════════════════════════════════════════════════════════════════════
# 🚀 PUNTO DE ENTRADA
# ═══════════════════════════════════════════════════════════════════════════════

# Ejecutar función principal
try {
    Main
} catch {
    Show-Error "Error inesperado: $_"
    Show-Info "Presiona Enter para salir..."
    Read-Host
    exit 1
}
