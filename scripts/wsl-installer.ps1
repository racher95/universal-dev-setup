#!/usr/bin/env powershell
# ═══════════════════════════════════════════════════════════════════════════════
# 🐧 WSL INSTALLER - Windows Subsystem for Linux
# ═══════════════════════════════════════════════════════════════════════════════
#
# Instalador inteligente de WSL que:
# - Detecta capacidades del sistema (WSL1 vs WSL2)
# - Maneja instalación en Windows Home vs Pro
# - Instala distribución Ubuntu por defecto
# - Configura WSL2 cuando está disponible
# - Maneja errores de Hyper-V en Windows Home
#
# Autor: Kevin Camara (racher95)
# Versión: 1.0
# Compatible: Windows 10 (2004+), Windows 11
# ═══════════════════════════════════════════════════════════════════════════════

param(
    [switch]$ConfigureTerminal = $false,
    [switch]$Force = $false,
    [string]$Distribution = "Ubuntu"
)

# Configuración de PowerShell
$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

# ═══════════════════════════════════════════════════════════════════════════════
# 🎨 FUNCIONES DE DISPLAY Y LOGGING
# ═══════════════════════════════════════════════════════════════════════════════

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
}

function Show-Banner {
    Write-Host ""
    Write-Host "╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║            🐧 WSL INSTALLER & CONFIGURATOR                  ║" -ForegroundColor Cyan
    Write-Host "║                                                              ║" -ForegroundColor Cyan
    Write-Host "║     Instalación inteligente de Windows Subsystem for Linux  ║" -ForegroundColor White
    Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
}

# ═══════════════════════════════════════════════════════════════════════════════
# 🔍 FUNCIONES DE DETECCIÓN
# ═══════════════════════════════════════════════════════════════════════════════

function Test-AdminPrivileges {
    try {
        $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
        $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
        return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    } catch {
        return $false
    }
}

function Get-WindowsEdition {
    try {
        $os = Get-CimInstance -ClassName Win32_OperatingSystem
        $edition = $os.OperatingSystemSKU

        $editionName = switch ($edition) {
            101 { "Home" }
            100 { "Home Single Language" }
            4   { "Enterprise" }
            1   { "Ultimate" }
            48  { "Professional" }
            49  { "Professional N" }
            default { "Unknown" }
        }

        return @{
            Name = $editionName
            Build = $os.BuildNumber
            IsHome = $editionName -like "*Home*"
            IsPro = $editionName -like "*Professional*" -or $editionName -like "*Enterprise*"
        }
    } catch {
        return @{ Name = "Unknown"; Build = 0; IsHome = $false; IsPro = $false }
    }
}

function Test-HyperVAvailability {
    try {
        # Intentar verificar Hyper-V
        $hyperVFeature = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All -ErrorAction SilentlyContinue
        return $hyperVFeature -and ($hyperVFeature.State -eq "Enabled" -or $hyperVFeature.State -eq "Disabled")
    } catch {
        return $false
    }
}

function Get-WSLStatus {
    try {
        # Verificar WSL Feature
        $wslFeature = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -ErrorAction SilentlyContinue
        $wslEnabled = $wslFeature -and $wslFeature.State -eq "Enabled"

        # Verificar WSL2 Feature
        $wsl2Feature = Get-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -ErrorAction SilentlyContinue
        $wsl2Enabled = $wsl2Feature -and $wsl2Feature.State -eq "Enabled"

        # Verificar distribuciones instaladas
        $distributions = @()
        try {
            if ($wslEnabled) {
                $wslOutput = & wsl -l -v 2>$null
                if ($LASTEXITCODE -eq 0 -and $wslOutput) {
                    $distributions = $wslOutput | Select-Object -Skip 1 | Where-Object { $_.Trim() -ne "" }
                }
            }
        } catch {
            # WSL comando no disponible
        }

        return @{
            WSLEnabled = $wslEnabled
            WSL2Enabled = $wsl2Enabled
            Distributions = $distributions
            HasDistributions = $distributions.Count -gt 0
        }
    } catch {
        return @{
            WSLEnabled = $false
            WSL2Enabled = $false
            Distributions = @()
            HasDistributions = $false
        }
    }
}

# ═══════════════════════════════════════════════════════════════════════════════
# 🛠️ FUNCIONES DE INSTALACIÓN
# ═══════════════════════════════════════════════════════════════════════════════

function Enable-WSLFeature {
    param([bool]$EnableWSL2 = $true)

    Show-Step "Habilitando características de WSL..."

    try {
        # Habilitar WSL
        Show-Info "Habilitando Windows Subsystem for Linux..."
        $wslResult = Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart -All

        if ($wslResult.RestartNeeded) {
            Show-Warning "WSL habilitado - Reinicio requerido"
        } else {
            Show-Success "WSL habilitado correctamente"
        }

        # Intentar habilitar WSL2 si está disponible
        if ($EnableWSL2) {
            try {
                Show-Info "Habilitando Virtual Machine Platform para WSL2..."
                $wsl2Result = Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart -All

                if ($wsl2Result.RestartNeeded) {
                    Show-Warning "WSL2 habilitado - Reinicio requerido"
                } else {
                    Show-Success "WSL2 habilitado correctamente"
                }

                return @{ Success = $true; RestartNeeded = $wslResult.RestartNeeded -or $wsl2Result.RestartNeeded; WSL2Enabled = $true }
            } catch {
                Show-Warning "WSL2 no disponible en esta edición: $($_.Exception.Message)"
                Show-Info "Continuando con WSL1..."
                return @{ Success = $true; RestartNeeded = $wslResult.RestartNeeded; WSL2Enabled = $false }
            }
        } else {
            return @{ Success = $true; RestartNeeded = $wslResult.RestartNeeded; WSL2Enabled = $false }
        }
    } catch {
        Show-Error "Error habilitando WSL: $($_.Exception.Message)"
        return @{ Success = $false; RestartNeeded = $false; WSL2Enabled = $false }
    }
}

function Install-WSLDistribution {
    param([string]$DistributionName = "Ubuntu")

    Show-Step "Instalando distribución $DistributionName..."

    try {
        # Método 1: Usar wsl --install (Windows 11/10 reciente)
        Show-Info "Intentando instalación con wsl --install..."

        $installOutput = & wsl --install -d $DistributionName 2>&1
        if ($LASTEXITCODE -eq 0) {
            Show-Success "Distribución $DistributionName instalada correctamente"
            return @{ Success = $true; Method = "wsl --install" }
        } else {
            Show-Warning "Método wsl --install falló, intentando método alternativo..."
            Show-Info "Salida: $installOutput"
        }

        # Método 2: Instalación manual desde Microsoft Store
        Show-Info "Intentando descarga desde Microsoft Store..."

        # URLs de descarga directa para diferentes distribuciones
        $distributionUrls = @{
            "Ubuntu" = "https://aka.ms/wslubuntu"
            "Ubuntu-20.04" = "https://aka.ms/wslubuntu2004"
            "Ubuntu-22.04" = "https://aka.ms/wslubuntu2204"
            "Debian" = "https://aka.ms/wsl-debian-gnulinux"
        }

        if ($distributionUrls.ContainsKey($DistributionName)) {
            $downloadUrl = $distributionUrls[$DistributionName]
            $tempFile = "$env:TEMP\$DistributionName.appx"

            Show-Info "Descargando $DistributionName desde $downloadUrl..."

            try {
                Invoke-WebRequest -Uri $downloadUrl -OutFile $tempFile -UseBasicParsing
                Show-Success "Descarga completada"

                Show-Info "Instalando paquete AppX..."
                Add-AppxPackage -Path $tempFile

                Show-Success "Distribución $DistributionName instalada correctamente"
                Remove-Item $tempFile -Force -ErrorAction SilentlyContinue

                return @{ Success = $true; Method = "Manual AppX" }
            } catch {
                Show-Error "Error en instalación manual: $($_.Exception.Message)"
                Remove-Item $tempFile -Force -ErrorAction SilentlyContinue
            }
        }

        # Método 3: Usar winget si está disponible
        Show-Info "Intentando instalación con winget..."

        try {
            $wingetOutput = & winget install Canonical.Ubuntu 2>&1
            if ($LASTEXITCODE -eq 0) {
                Show-Success "Distribución instalada con winget"
                return @{ Success = $true; Method = "winget" }
            } else {
                Show-Warning "Instalación con winget falló"
            }
        } catch {
            Show-Warning "winget no disponible"
        }

        # Si todos los métodos fallan
        Show-Error "No se pudo instalar la distribución automáticamente"
        Show-Info "Instalación manual requerida:"
        Show-Info "1. Abre Microsoft Store"
        Show-Info "2. Busca 'Ubuntu' o tu distribución preferida"
        Show-Info "3. Instala la distribución"
        Show-Info "4. Vuelve a ejecutar este script"

        return @{ Success = $false; Method = "Manual requerida" }

    } catch {
        Show-Error "Error durante la instalación: $($_.Exception.Message)"
        return @{ Success = $false; Method = "Error" }
    }
}

function Set-WSL2AsDefault {
    Show-Step "Configurando WSL2 como versión por defecto..."

    try {
        & wsl --set-default-version 2 2>&1
        if ($LASTEXITCODE -eq 0) {
            Show-Success "WSL2 configurado como versión por defecto"
            return $true
        } else {
            Show-Warning "No se pudo configurar WSL2 como por defecto"
            return $false
        }
    } catch {
        Show-Warning "Error configurando WSL2: $($_.Exception.Message)"
        return $false
    }
}

function Update-WSLKernel {
    Show-Step "Actualizando kernel de WSL2..."

    try {
        & wsl --update 2>&1
        if ($LASTEXITCODE -eq 0) {
            Show-Success "Kernel WSL2 actualizado"
            return $true
        } else {
            Show-Warning "No se pudo actualizar el kernel WSL2"
            return $false
        }
    } catch {
        Show-Warning "Error actualizando kernel: $($_.Exception.Message)"
        return $false
    }
}

function Initialize-WSLDistribution {
    param([string]$DistributionName = "Ubuntu")

    Show-Step "Inicializando distribución $DistributionName..."

    try {
        Show-Info "Iniciando $DistributionName por primera vez..."
        Show-Info "NOTA: Se abrirá una ventana para configurar usuario y contraseña"

        # Ejecutar la distribución para configuración inicial
        & wsl -d $DistributionName -- echo "Distribución inicializada"

        if ($LASTEXITCODE -eq 0) {
            Show-Success "Distribución $DistributionName inicializada correctamente"
            return $true
        } else {
            Show-Warning "Distribución requiere configuración manual"
            Show-Info "Ejecuta: wsl -d $DistributionName para configurar"
            return $false
        }
    } catch {
        Show-Warning "Error inicializando distribución: $($_.Exception.Message)"
        return $false
    }
}

# ═══════════════════════════════════════════════════════════════════════════════
# 🎯 FUNCIÓN PRINCIPAL DE INSTALACIÓN
# ═══════════════════════════════════════════════════════════════════════════════

function Install-WSL {
    param(
        [string]$Distribution = "Ubuntu",
        [bool]$ConfigureTerminal = $false
    )

    Show-Banner

    # Verificar permisos de administrador
    if (-not (Test-AdminPrivileges)) {
        Show-Error "Este script requiere permisos de administrador"
        Show-Info "Ejecuta PowerShell como administrador y vuelve a intentar"
        return $false
    }

    # Obtener información del sistema
    $windowsEdition = Get-WindowsEdition
    $hyperVAvailable = Test-HyperVAvailability
    $wslStatus = Get-WSLStatus

    Show-Info "Sistema detectado: Windows $($windowsEdition.Name) (Build $($windowsEdition.Build))"

    if ($hyperVAvailable) {
        Show-Success "Hyper-V disponible - WSL2 completamente compatible"
    } else {
        Show-Warning "Hyper-V no disponible - Solo WSL1 soportado"
        if ($windowsEdition.IsHome) {
            Show-Info "Windows Home detectado - WSL1 es funcional para desarrollo"
        }
    }

    # Verificar estado actual de WSL
    if ($wslStatus.WSLEnabled -and $wslStatus.HasDistributions) {
        Show-Success "WSL ya está instalado y configurado"
        Show-Info "Distribuciones disponibles:"
        $wslStatus.Distributions | ForEach-Object { Show-Info "  - $_" }

        if (-not $Force) {
            Show-Info "Usa -Force para reinstalar o configura una nueva distribución"
            return $true
        }
    }

    # Paso 1: Habilitar características de WSL
    if (-not $wslStatus.WSLEnabled) {
        $enableResult = Enable-WSLFeature -EnableWSL2 $hyperVAvailable

        if (-not $enableResult.Success) {
            Show-Error "No se pudo habilitar WSL"
            return $false
        }

        if ($enableResult.RestartNeeded) {
            Show-Warning "----------------- REINICIO REQUERIDO -----------------"
            Show-Info "Se han habilitado características de Windows que necesitan un reinicio."

            # Crear tarea programada para continuar después del reinicio
            $taskCreated = New-PostRebootTask

            if ($taskCreated) {
                Show-Info "✅ Tarea programada creada - el setup continuará automáticamente después del reinicio"
                Show-Info "Reinicia tu computadora y el despachador se ejecutará automáticamente"
            } else {
                Show-Info "⚠️ Deberás ejecutar manualmente después del reinicio:"
                Show-Info "Comando: .\dispatcher.ps1"
            }

            Show-Warning "----------------- REINICIO REQUERIDO -----------------"
            return $false
        }
    } else {
        Show-Success "WSL ya está habilitado"
    }

    # Paso 2: Configurar WSL2 como por defecto (si está disponible)
    if ($hyperVAvailable -and $wslStatus.WSL2Enabled) {
        Set-WSL2AsDefault
        Update-WSLKernel
    }

    # Paso 3: Instalar distribución
    if (-not $wslStatus.HasDistributions -or $Force) {
        $installResult = Install-WSLDistribution -DistributionName $Distribution

        if (-not $installResult.Success) {
            Show-Error "No se pudo instalar la distribución"
            return $false
        }

        Show-Success "Distribución instalada con método: $($installResult.Method)"
    } else {
        Show-Success "Distribución ya está instalada"
    }

    # Paso 4: Inicializar distribución
    Start-Sleep 2
    Initialize-WSLDistribution -DistributionName $Distribution

    # Paso 5: Configurar terminal si se solicita
    if ($ConfigureTerminal) {
        Show-Step "Configurando terminal avanzado..."

        $terminalSetupPath = Join-Path (Split-Path $PSScriptRoot) "scripts\terminal-setup.sh"
        if (Test-Path $terminalSetupPath) {
            Show-Info "Ejecutando configuración de terminal..."
            & wsl bash -c "cd '/mnt/c/$(($PSScriptRoot -replace '\\', '/') -replace 'C:', '')' && ./scripts/terminal-setup.sh"
        } else {
            Show-Warning "Script de configuración de terminal no encontrado"
            Show-Info "Ruta esperada: $terminalSetupPath"
        }
    }

    # Resumen final
    Show-Success "🎉 Instalación de WSL completada!"

    # Limpiar tarea programada si existe
    Remove-PostRebootTask

    Show-Info ""
    Show-Info "📋 RESUMEN:"
    Show-Info "• WSL habilitado: ✅"
    Show-Info "• WSL2 disponible: $(if ($hyperVAvailable) { '✅' } else { '❌ (Solo WSL1)' })"
    Show-Info "• Distribución: $Distribution"
    Show-Info "• Terminal configurado: $(if ($ConfigureTerminal) { '✅' } else { '❌' })"
    Show-Info ""
    Show-Info "🚀 PRÓXIMOS PASOS:"
    Show-Info "1. Ejecuta: wsl -d $Distribution para acceder a Linux"
    Show-Info "2. Configura VS Code para usar WSL"
    Show-Info "3. Instala herramientas de desarrollo en Linux"

    return $true
}

# ═══════════════════════════════════════════════════════════════════════════════
# 🔄 FUNCIONES DE CONTINUIDAD POST-REINICIO
# ═══════════════════════════════════════════════════════════════════════════════

function New-PostRebootTask {
    param(
        [string]$TaskName = "WSL-Setup-PostReboot",
        [string]$ScriptPath = $null
    )

    if (-not $ScriptPath) {
        $ScriptPath = Join-Path (Split-Path $PSScriptRoot) "dispatcher.ps1"
    }

    Show-Step "Creando tarea programada para continuar después del reinicio..."

    try {
        # Verificar si la tarea ya existe y eliminarla
        $existingTask = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
        if ($existingTask) {
            Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
            Show-Info "Tarea programada anterior eliminada"
        }

        # Crear la nueva tarea programada
        $Action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File `"$ScriptPath`""
        $Trigger = New-ScheduledTaskTrigger -AtLogOn
        $Principal = New-ScheduledTaskPrincipal -UserId ([System.Security.Principal.WindowsIdentity]::GetCurrent().Name) -RunLevel Highest
        $Settings = New-ScheduledTaskSettingsSet -RunOnlyWhenLoggedOn -StartWhenAvailable -RestartCount 3 -RestartInterval (New-TimeSpan -Minutes 1)

        $Task = New-ScheduledTask -Action $Action -Trigger $Trigger -Principal $Principal -Settings $Settings
        Register-ScheduledTask -TaskName $TaskName -InputObject $Task | Out-Null

        Show-Success "Tarea programada '$TaskName' creada correctamente"
        Show-Info "Se ejecutará automáticamente después del reinicio"

        return $true
    } catch {
        Show-Warning "No se pudo crear la tarea programada: $($_.Exception.Message)"
        Show-Info "Deberás ejecutar manualmente el despachador después del reinicio"
        return $false
    }
}

function Remove-PostRebootTask {
    param([string]$TaskName = "WSL-Setup-PostReboot")

    try {
        $existingTask = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
        if ($existingTask) {
            Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
            Show-Success "Tarea programada '$TaskName' eliminada"
        }
    } catch {
        Show-Warning "No se pudo eliminar la tarea programada: $($_.Exception.Message)"
    }
}

# ═══════════════════════════════════════════════════════════════════════════════
# 🛠️ FUNCIONES DE INSTALACIÓN
# ═══════════════════════════════════════════════════════════════════════════════
