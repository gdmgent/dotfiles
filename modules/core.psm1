Set-Variable -Name DotfilesConfigPath -Value (Join-Path -Path $Home -ChildPath .dotfiles | Join-Path -ChildPath config.json) -Option Constant -Scope Global -ErrorAction SilentlyContinue
Set-Variable -Name DotfilesVersion -Value (Get-Content -Path (Join-Path -Path $Global:DotfilesInstallPath -ChildPath VERSION) | Select-Object -First 1 -Skip 1) -Option Constant -Scope Global -ErrorAction SilentlyContinue

function ExistCommand {
    Param(
        [Parameter(Mandatory=$true)]
        [String]
        $Name
    )
    return [bool](Get-Command -Name $Name -CommandType Application -ErrorAction SilentlyContinue)
}

# Config Functions
# ----------------

if ($IsWindows) {
    function FindIp {
        ipconfig | Select-String -Pattern '10.5.128.\d+$'
    }
    New-Alias -Name ip -Value FindIp
}

function InitConfig {
    if (Test-Path $Global:DotfilesConfigPath) {
        WriteMessage -Type Info -Message 'Reading config file...'
        Set-Variable -Name DotfilesConfig -Value (Get-Content -Raw -Path $Global:DotfilesConfigPath | ConvertFrom-Json) -Scope Global
    } else {
        WriteMessage -Type Info -Message 'Creating a new config file...'
        New-Item -Path $Global:DotfilesConfigPath -Force
        Set-Variable -Name DotfilesConfig -Value (New-Object -TypeName PSObject) -Scope Global
        SaveConfig
    }
}

function ReadConfig([String] $Name) {
    if (Get-Member -InputObject $Global:DotfilesConfig -Name $Name -MemberType NoteProperty) {
        return $Global:DotfilesConfig.$Name
    } else {
        return $null
    }
}

function SaveConfig {
    ConvertTo-Json -InputObject $Global:DotfilesConfig | Out-File -FilePath $Global:DotfilesConfigPath
}

function WriteConfig([String] $Name, [String] $Value) {
    if (Get-Member -InputObject $Global:DotfilesConfig -Name $Name -MemberType NoteProperty) {
        $Global:DotfilesConfig.$Name = $Value
    } else {
        Add-Member -InputObject $Global:DotfilesConfig -NotePropertyName $Name -NotePropertyValue $Value
    }
    SaveConfig
}

function SetEnvironment {
    if ($IsMacOS) {
        $Locale = 'nl_BE.UTF-8'
        [System.Environment]::SetEnvironmentVariable('LANG', $Locale)
        [System.Environment]::SetEnvironmentVariable('LC_ALL', $Locale)

        $EnvironmentPath = @()

        # First
        $EnvironmentPath += @(
            # "$HOME/.rbenv/shims"
        )

        $AndroidSdkPath = "$HOME/Library/Android/sdk/tools"
        if (Test-Path -Path $AndroidSdkPath) {
            $EnvironmentPath += $AndroidSdkPath
        }

        $DotNetCore = '/usr/local/share/dotnet/dotnet'
        if (Test-Path -Path $DotNetCore) {
            $EnvironmentPath += $DotNetCore
        }

        # User Paths
        $EnvironmentPath += @(
            '/usr/local/bin',
            '/usr/bin',
            '/bin'
        )

        # Superuser Paths
        $EnvironmentPath += @(
            '/usr/local/sbin',
            '/usr/sbin',
            '/sbin'
        )

        # Last
        $EnvironmentPath += @(
            "$HOME/.config/yarn/global/node_modules/.bin",
            "$HOME/.composer/vendor/bin"
        )

        [System.Environment]::SetEnvironmentVariable('PATH', $EnvironmentPath -join ':')
    } elseif ($IsWindows) {
        $EnvironmentPath = [System.Environment]::GetEnvironmentVariable('Path') -split ';'
        $EnvironmentPath += @(
            'C:\cygwin64\bin',
            "$HOME\AppData\Roaming\Composer\vendor\bin",
            'C:\nginx',
            'C:\php',
            'C:\Program Files\MySQL\MySQL Server 5.7\bin',
            'C:\Ruby23-x64\bin',
            "$HOME\AppData\Local\Yarn\config\global\node_modules\.bin"
        )

        # PowerShell Paths @TODO replace with $PSPATH ?
        $PowerShellPath = 'C:\Program Files\PowerShell'
        if (Test-Path -Path $PowerShellPath) {
            $EnvironmentPath += (Get-ChildItem $PowerShellPath | Select-Object -Last 1).FullName
        }
        
        # .Net Core Paths
        $DotNetCorePath = 'C:\Program Files\dotnet'
        if (Test-Path -Path $DotNetCorePath) {
            $EnvironmentPath += $DotNetCorePath
        }

        [System.Environment]::SetEnvironmentVariable('Path', $EnvironmentPath -join ';')
    }
}
SetEnvironment

function AddToEnvironmentPath {
    Param(
        [Parameter(Mandatory=$true)]
        [String]
        $Path,

        [Switch]
        $First
    )
    $EnvironmentPath = [System.Environment]::GetEnvironmentVariable('Path') -split ';'

    if ($First) {
        $EnvironmentPath = @($Path) + $EnvironmentPath
    } else {
        $EnvironmentPath += @($Path)
    }
    
    [System.Environment]::SetEnvironmentVariable('Path', $EnvironmentPath -join ';')
}

# Message Functions
# -----------------

function WriteMessage {
    Param(
        [Parameter(Mandatory=$true)]
        [String]
        $Message,

        [ValidateSet('Danger','Info','Mute','Primary','Strong','Success','Warning')]
        [String]
        $Type,

        [Switch]
        $Inverse,

        [Switch]
        $NoNewline
    )
    switch ($Type) {
        # Black        Cyan         DarkCyan     DarkGreen    DarkRed      Gray         Magenta      White
        # Blue         DarkBlue     DarkGray     DarkMagenta  DarkYellow   Green        Red          Yellow
        'Danger' {
            $Foreground = 'Red'
            if ($Inverse) {
                $Background = $Foreground
                $Foreground = 'White'
            }
        }
        'Info' {
            $Foreground = 'Cyan'
            if ($Inverse) {
                $Background = 'Blue'
                $Foreground = 'White'
            }
        }
        'Mute' {
            $Foreground = 'DarkGray'
            if ($Inverse) {
                $Background = $Foreground
                $Foreground = 'Black'
            }
        }
        'Primary' {
            $Foreground = 'Magenta'
            if ($Inverse) {
                $Background = $Foreground
                $Foreground = 'White'
            }
        }
        'Strong' {
            $Foreground = 'White'
            if ($Inverse) {
                $Background = $Foreground
                $Foreground = 'Black'
            }
        }
        'Success' {
            $Foreground = 'Green'
            if ($Inverse) {
                $Background = $Foreground
                $Foreground = 'Black'
            }
        }
        'Warning' {
            $Foreground = 'Yellow'
            if ($Inverse) {
                $Background = $Foreground
                $Foreground = 'Black'
            }
        }
        Default {
            $Foreground = 'Gray'
            if ($Inverse) {
                $Background = $Foreground
                $Foreground = 'Black'
            }
        }
    }
    if ($Background) {
        Write-Host " $Message " -BackgroundColor $Background -ForegroundColor $Foreground -NoNewline:$NoNewline;
    } else {
        Write-Host "$Message" -ForegroundColor $Foreground -NoNewline:$NoNewline;
    }
}

function Dotfiles {
    if ($IsMacOS) {
        $OS = 'macOS'
    } elseif ($IsWindows) {
        $OS = 'Windows'
    } elseif ($IsLinux) {
        $OS = 'Linux'
    } else {
        $OS = 'unknown operating system'
    }
    WriteMessage -Type Info -Inverse -Message "gdm.gent Dotfiles $Global:DotfilesVersion" -NoNewline
    $PSVersion = $PSVersionTable.GitCommitId # $PSVersionTable.PSVersion.ToString()
    WriteMessage -Type Mute -Message " on PowerShell $PSVersion for $OS"
}
New-Alias -Name dot -Value Dotfiles

function FindListeners {
    Param(
        [Parameter(Mandatory=$true)]
        [Int16]
        $Port
    )
    if ($IsMacOS) {
        (lsof -i ":$Port" | Where-Object { $_ -match 'LISTEN' })
    } elseif ($IsWindows) {
        (NETSTAT.EXE -ao | Where-Object { $_ -match 'Proto' -or ($_ -match ":$Port " -and $_ -match 'LISTENING') })
    }
}

function SearchDotfilesCommands {
    Get-Command "$args" | Where-Object { $_.Source -eq 'dotfiles' }
    Get-Alias   "$args" | Where-Object { $_.Source -eq 'dotfiles' -or $_.Source -like 'aliases*' }
}

function X {
    exit
}

InitConfig