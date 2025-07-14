# Universal Development Setup - PowerShell Bootstrap
# Este script instala Git Bash automáticamente y relanza el script principal

param(
    [switch]$Force,
    [switch]$SkipBashInstall,
    [switch]$Help
)

# Colores para PowerShell
$ColorInfo = "Cyan"
$ColorSuccess = "Green"
$ColorWarning = "Yellow"
$ColorError = "Red"

function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

function Test-AdminRights {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Find-GitBash {
    $gitBashPaths = @(
        "C:\Program Files\Git\bin\bash.exe",
        "C:\Program Files (x86)\Git\bin\bash.exe",
        "${env:ProgramFiles}\Git\bin\bash.exe",
        "${env:ProgramFiles(x86)}\Git\bin\bash.exe",
        "${env:USERPROFILE}\AppData\Local\Programs\Git\bin\bash.exe"
    )
    
    foreach ($path in $gitBashPaths) {
        if (Test-Path $path) {
            return $path
        }
    }
    return $null
}

function Install-Chocolatey {
    Write-ColorOutput "Instalando Chocolatey Package Manager..." $ColorInfo
    
    try {
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
        
        # Recargar variables de entorno
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
        
        # Verificar instalación
        if (Get-Command choco -ErrorAction SilentlyContinue) {
            Write-ColorOutput "✅ Chocolatey instalado correctamente" $ColorSuccess
            return $true
        } else {
            Write-ColorOutput "❌ Error verificando instalación de Chocolatey" $ColorError
            return $false
        }
    } catch {
        Write-ColorOutput "❌ Error instalando Chocolatey: $($_.Exception.Message)" $ColorError
        return $false
    }
}

function Install-GitBash {
    Write-ColorOutput "Instalando Git Bash..." $ColorInfo
    
    # Método 1: Chocolatey (más rápido si está disponible)
    if (Get-Command choco -ErrorAction SilentlyContinue) {
        Write-ColorOutput "Usando Chocolatey para instalar Git..." $ColorInfo
        try {
            choco install git -y --no-progress
            if ($LASTEXITCODE -eq 0) {
                Write-ColorOutput "✅ Git instalado con Chocolatey" $ColorSuccess
                
                # Actualizar PATH
                $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
                
                # Buscar Git Bash instalado
                Start-Sleep -Seconds 2
                $bashPath = Find-GitBash
                if ($bashPath) {
                    return $bashPath
                }
            }
        } catch {
            Write-ColorOutput "⚠️  Error con Chocolatey, intentando método alternativo..." $ColorWarning
        }
    } else {
        # Instalar Chocolatey primero
        Write-ColorOutput "Chocolatey no encontrado, instalando..." $ColorInfo
        if (Install-Chocolatey) {
            Write-ColorOutput "Reintentatdo instalación de Git con Chocolatey..." $ColorInfo
            try {
                choco install git -y --no-progress
                if ($LASTEXITCODE -eq 0) {
                    Write-ColorOutput "✅ Git instalado con Chocolatey" $ColorSuccess
                    
                    # Actualizar PATH
                    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
                    
                    # Buscar Git Bash instalado
                    Start-Sleep -Seconds 2
                    $bashPath = Find-GitBash
                    if ($bashPath) {
                        return $bashPath
                    }
                }
            } catch {
                Write-ColorOutput "⚠️  Error con Chocolatey, intentando winget..." $ColorWarning
            }
        }
    }
    
    # Método 2: winget (Windows 10 1709+)
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-ColorOutput "Usando winget para instalar Git..." $ColorInfo
        try {
            winget install Git.Git --silent --accept-package-agreements --accept-source-agreements
            if ($LASTEXITCODE -eq 0) {
                Write-ColorOutput "✅ Git instalado con winget" $ColorSuccess
                
                # Actualizar PATH
                $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
                
                # Buscar Git Bash instalado
                Start-Sleep -Seconds 3
                $bashPath = Find-GitBash
                if ($bashPath) {
                    return $bashPath
                }
            }
        } catch {
            Write-ColorOutput "⚠️  Error con winget, intentando descarga directa..." $ColorWarning
        }
    }
    
    # Método 3: Descarga directa
    Write-ColorOutput "Descargando Git desde git-scm.com..." $ColorInfo
    try {
        $gitUrl = "https://git-scm.com/download/win"
        $tempFile = "$env:TEMP\GitInstaller.exe"
        
        # Detectar arquitectura
        $arch = if ([Environment]::Is64BitOperatingSystem) { "64" } else { "32" }
        $directUrl = "https://github.com/git-for-windows/git/releases/latest/download/Git-2.42.0.2-$arch-bit.exe"
        
        Write-ColorOutput "Descargando instalador de Git..." $ColorInfo
        Invoke-WebRequest -Uri $directUrl -OutFile $tempFile -UseBasicParsing
        
        Write-ColorOutput "Ejecutando instalador de Git..." $ColorInfo
        Start-Process -FilePath $tempFile -ArgumentList "/SILENT" -Wait
        
        if ($LASTEXITCODE -eq 0) {
            Write-ColorOutput "✅ Git instalado con descarga directa" $ColorSuccess
            
            # Actualizar PATH
            $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
            
            # Buscar Git Bash instalado
            Start-Sleep -Seconds 3
            $bashPath = Find-GitBash
            if ($bashPath) {
                Remove-Item $tempFile -Force -ErrorAction SilentlyContinue
                return $bashPath
            }
        }
        
        Remove-Item $tempFile -Force -ErrorAction SilentlyContinue
    } catch {
        Write-ColorOutput "❌ Error en descarga directa: $($_.Exception.Message)" $ColorError
    }
    
    # Si llegamos aquí, ningún método funcionó
    return $null
}

function Launch-BashScript {
    param(
        [string]$BashPath
    )
    
    Write-ColorOutput "=== LANZANDO SCRIPT PRINCIPAL ===" $ColorInfo
    Write-ColorOutput "Cambiando a Git Bash para continuar..." $ColorInfo
    Write-ColorOutput "Bash: $BashPath" $ColorInfo
    Write-ColorOutput ""
    
    # Cambiar al directorio del script
    $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
    Set-Location $scriptDir
    
    # Convertir ruta de Windows a formato Unix para Git Bash
    $unixPath = $scriptDir -replace "\\", "/" -replace "C:", "/c"
    
    # Ejecutar el script bash
    Write-ColorOutput "Ejecutando: $BashPath -c 'cd `"$unixPath`" && ./install.sh'" $ColorInfo
    Write-ColorOutput "────────────────────────────────────────────────────────────" $ColorInfo
    
    & $BashPath -c "cd '$unixPath' && ./install.sh"
    
    $exitCode = $LASTEXITCODE
    Write-ColorOutput "────────────────────────────────────────────────────────────" $ColorInfo
    
    if ($exitCode -eq 0) {
        Write-ColorOutput "✅ ¡Instalación completada exitosamente!" $ColorSuccess
    } else {
        Write-ColorOutput "❌ Error durante la instalación. Código: $exitCode" $ColorError
    }
    
    return $exitCode
}

function Show-Help {
    Write-ColorOutput "=== UNIVERSAL DEVELOPMENT SETUP - AYUDA ===" $ColorInfo
    Write-ColorOutput ""
    Write-ColorOutput "Este script instala Git Bash automáticamente y ejecuta el setup completo."
    Write-ColorOutput ""
    Write-ColorOutput "OPCIONES:"
    Write-ColorOutput "  -Force           Forzar instalación aunque falten dependencias"
    Write-ColorOutput "  -SkipBashInstall Saltar instalación de Git Bash (usar si ya está instalado)"
    Write-ColorOutput "  -Help            Mostrar esta ayuda"
    Write-ColorOutput ""
    Write-ColorOutput "EJEMPLOS:"
    Write-ColorOutput "  .\install.ps1                    # Instalación completa automática"
    Write-ColorOutput "  .\install.ps1 -Force             # Forzar instalación"
    Write-ColorOutput "  .\install.ps1 -SkipBashInstall   # Saltar instalación de Git Bash"
    Write-ColorOutput ""
    Write-ColorOutput "FLUJO DE INSTALACIÓN:"
    Write-ColorOutput "  1. Verificar permisos de administrador"
    Write-ColorOutput "  2. Instalar Git Bash si no está presente"
    Write-ColorOutput "  3. Relanzar script en Git Bash"
    Write-ColorOutput "  4. Ejecutar instalación completa de herramientas"
    Write-ColorOutput ""
    Write-ColorOutput "REQUISITOS:"
    Write-ColorOutput "  - PowerShell 5.1 o superior"
    Write-ColorOutput "  - Conexión a internet"
    Write-ColorOutput "  - Permisos de administrador (recomendado)"
    Write-ColorOutput ""
}

# Función principal
function Main {
    Clear-Host
    Write-ColorOutput "╔══════════════════════════════════════════════════════════════╗" $ColorInfo
    Write-ColorOutput "║           UNIVERSAL DEVELOPMENT SETUP - WINDOWS             ║" $ColorInfo
    Write-ColorOutput "║                 PowerShell Bootstrap v2.0                   ║" $ColorInfo
    Write-ColorOutput "╚══════════════════════════════════════════════════════════════╝" $ColorInfo
    Write-ColorOutput ""
    
    # Mostrar ayuda si se solicita
    if ($Help) {
        Show-Help
        return
    }
    
    Write-ColorOutput "✅ PowerShell $($PSVersionTable.PSVersion) detectado" $ColorSuccess
    
    # Verificar permisos de administrador
    if (Test-AdminRights) {
        Write-ColorOutput "✅ Ejecutándose con permisos de administrador" $ColorSuccess
    } else {
        Write-ColorOutput "⚠️  Ejecutándose sin permisos de administrador" $ColorWarning
        Write-ColorOutput "   Algunas funciones pueden requerir elevación" $ColorWarning
        
        if (-not $Force) {
            Write-ColorOutput ""
            $response = Read-Host "¿Continuar sin permisos de administrador? (s/n)"
            if ($response -ne "s" -and $response -ne "S") {
                Write-ColorOutput "Reinicia PowerShell como administrador para instalación completa" $ColorInfo
                return
            }
        }
    }
    
    Write-ColorOutput ""
    Write-ColorOutput "🔍 Verificando Git Bash..." $ColorInfo
    
    # Buscar Git Bash existente
    $bashPath = Find-GitBash
    
    if ($bashPath -and -not $Force) {
        Write-ColorOutput "✅ Git Bash encontrado en: $bashPath" $ColorSuccess
        Write-ColorOutput ""
        
        # Lanzar script principal inmediatamente
        $exitCode = Launch-BashScript -BashPath $bashPath
        
        Write-ColorOutput ""
        if ($exitCode -eq 0) {
            Write-ColorOutput "🎉 ¡Configuración completada exitosamente!" $ColorSuccess
        } else {
            Write-ColorOutput "⚠️  La instalación encontró algunos problemas" $ColorWarning
        }
        
    } elseif ($SkipBashInstall) {
        Write-ColorOutput "⚠️  Saltando instalación de Git Bash (parámetro -SkipBashInstall)" $ColorWarning
        Write-ColorOutput "❌ Git Bash no encontrado y instalación omitida" $ColorError
        
    } else {
        Write-ColorOutput "❌ Git Bash no encontrado" $ColorWarning
        Write-ColorOutput "🔄 Iniciando instalación automática..." $ColorInfo
        Write-ColorOutput ""
        
        # Instalar Git Bash
        $bashPath = Install-GitBash
        
        if ($bashPath) {
            Write-ColorOutput ""
            Write-ColorOutput "✅ Git Bash instalado correctamente" $ColorSuccess
            Write-ColorOutput ""
            
            # Lanzar script principal
            $exitCode = Launch-BashScript -BashPath $bashPath
            
            Write-ColorOutput ""
            if ($exitCode -eq 0) {
                Write-ColorOutput "🎉 ¡Configuración completada exitosamente!" $ColorSuccess
            } else {
                Write-ColorOutput "⚠️  La instalación encontró algunos problemas" $ColorWarning
            }
        } else {
            Write-ColorOutput ""
            Write-ColorOutput "❌ No se pudo instalar Git Bash automáticamente" $ColorError
            Write-ColorOutput "Por favor, instala Git manualmente y ejecuta de nuevo" $ColorWarning
        }
    }
    
    Write-ColorOutput ""
    Write-ColorOutput "Presiona Enter para salir..."
    Read-Host
}

# Ejecutar función principal
Main
