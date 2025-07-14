# Universal Development Setup - PowerShell Bootstrap
# Este script instala Git Bash automaticamente y relanza el script principal

param(
    [switch]$Force,
    [switch]$Help
)

function Write-Info {
    param([string]$Message)
    Write-Host $Message -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host $Message -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host $Message -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host $Message -ForegroundColor Red
}

function Test-AdminRights {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Find-GitBash {
    $paths = @(
        "C:\Program Files\Git\bin\bash.exe",
        "C:\Program Files (x86)\Git\bin\bash.exe"
    )

    foreach ($path in $paths) {
        if (Test-Path $path) {
            return $path
        }
    }
    return $null
}

function Install-GitBash {
    Write-Info "Instalando Git Bash..."

    # Intentar con Chocolatey
    if (Get-Command choco -ErrorAction SilentlyContinue) {
        Write-Info "Usando Chocolatey para instalar Git..."
        try {
            choco install git -y
            Start-Sleep -Seconds 3
            return Find-GitBash
        }
        catch {
            Write-Warning "Error con Chocolatey, intentando winget..."
        }
    }

    # Intentar con winget
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-Info "Usando winget para instalar Git..."
        try {
            winget install Git.Git --silent
            Start-Sleep -Seconds 3
            return Find-GitBash
        }
        catch {
            Write-Warning "Error con winget, instalando Chocolatey..."
        }
    }

    # Instalar Chocolatey primero
    Write-Info "Instalando Chocolatey..."
    try {
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

        Write-Info "Instalando Git con Chocolatey..."
        choco install git -y
        Start-Sleep -Seconds 3
        return Find-GitBash
    }
    catch {
        Write-Error "Error instalando Git: $($_.Exception.Message)"
        return $null
    }
}

function Start-BashScript {
    param([string]$BashPath)

    Write-Info "Lanzando script principal en Git Bash..."
    $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
    $unixPath = $scriptDir -replace "\\", "/" -replace "C:", "/c"

    # Ejecutar instalación completa automáticamente
    & $BashPath -c "cd '$unixPath' && ./install.sh --auto"

    if ($LASTEXITCODE -eq 0) {
        Write-Success "Instalacion completada exitosamente!"
    } else {
        Write-Warning "La instalacion encontro algunos problemas"
    }
}

function Show-Help {
    Write-Info "USO:"
    Write-Info "  .\install.ps1        Instalacion automatica completa"
    Write-Info "  .\install.ps1 -Force Forzar instalacion"
    Write-Info "  .\install.ps1 -Help  Mostrar esta ayuda"
    Write-Host ""
    Write-Info "Este script instala Git Bash automaticamente y ejecuta el setup completo."
}

# === INICIO DEL SCRIPT PRINCIPAL ===
Clear-Host
Write-Info "================================================================"
Write-Info "       UNIVERSAL DEVELOPMENT SETUP - WINDOWS BOOTSTRAP        "
Write-Info "                    Auto-instalacion de Git Bash              "
Write-Info "================================================================"
Write-Host ""

if ($Help) {
    Show-Help
    Read-Host "Presiona Enter para salir"
    exit
}

Write-Success "PowerShell $($PSVersionTable.PSVersion) detectado"

if (Test-AdminRights) {
    Write-Success "Ejecutandose con permisos de administrador"
} else {
    Write-Warning "Ejecutandose sin permisos de administrador"
    if (-not $Force) {
        $response = Read-Host "Continuar sin permisos de administrador? (s/n)"
        if ($response -ne "s" -and $response -ne "S") {
            Write-Info "Reinicia PowerShell como administrador para instalacion completa"
            Read-Host "Presiona Enter para salir"
            exit
        }
    }
}

Write-Host ""
Write-Info "Verificando Git Bash..."

$bashPath = Find-GitBash

if ($bashPath) {
    Write-Success "Git Bash encontrado en: $bashPath"
    Write-Host ""
    Start-BashScript -BashPath $bashPath
} else {
    Write-Warning "Git Bash no encontrado"
    Write-Info "Iniciando instalacion automatica..."
    Write-Host ""

    $bashPath = Install-GitBash

    if ($bashPath) {
        Write-Success "Git Bash instalado correctamente"
        Write-Host ""
        Start-BashScript -BashPath $bashPath
    } else {
        Write-Error "No se pudo instalar Git Bash automaticamente"
        Write-Warning "Por favor, instala Git manualmente desde: https://git-scm.com/download/win"
    }
}

Write-Host ""
Read-Host "Presiona Enter para salir"
