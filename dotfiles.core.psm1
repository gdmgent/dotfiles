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
        Write-Host 'Reading config file...'
        Set-Variable -Name DotfilesConfig -Value (Get-Content -Raw -Path $Global:DotfilesConfigPath | ConvertFrom-Json) -Scope Global
    } else {
        Write-Host 'Creating a new config file...'
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
    $Locale = 'nl_BE.UTF-8'
    if ($IsOSX) {
        [System.Environment]::SetEnvironmentVariable('LANG', $Locale)
        [System.Environment]::SetEnvironmentVariable('LC_ALL', $Locale)

        $Path = @()

        # First
        $Path += @(
            "$HOME/.rbenv/shims"
        )

        $AndroidSdkPath = "$HOME/Library/Android/sdk/tools"
        if (Test-Path -Path $AndroidSdkPath) {
            $Path += $AndroidSdkPath
        }
        $DotNetCore = '/usr/local/share/dotnet/dotnet'
        if (Test-Path -Path $DotNetCore) {
            $Path += $DotNetCore
        }

        # User Paths
        $Path += @(
            '/usr/local/bin',
            '/usr/bin',
            '/bin'
        )

        # Superuser Paths
        $Path += @(
            '/usr/local/sbin',
            '/usr/sbin',
            '/sbin'
        )

        # Last
        $Path += @(
            "$HOME/.config/yarn/global/node_modules/.bin",
            "$HOME/.composer/vendor/bin"
        )

        [System.Environment]::SetEnvironmentVariable('PATH', $Path -join ':')
    } elseif ($IsWindows) {
        $Path = [System.Environment]::GetEnvironmentVariable('Path') -split ';'
        $Path += @(
            'C:\cygwin64\bin',
            "$HOME\AppData\Roaming\Composer\vendor\bin",
            'C:\php',
            'C:\Program Files (x86)\Yarn\bin',
            "$HOME\AppData\Local\Yarn\config\global\node_modules\.bin"
        )
        $PowerShellPath = 'C:\Program Files\PowerShell'
        if (Test-Path -Path $PowerShellPath) {
            $Path += (Get-ChildItem $PowerShellPath | Select-Object -Last 1).FullName
        }
        $DotNetCorePath = 'C:\Program Files\dotnet'
        if (Test-Path -Path $DotNetCorePath) {
            $Path += $DotNetCorePath
        }
        [System.Environment]::SetEnvironmentVariable('Path', $Path -join ';')
    }
}
SetEnvironment

function Dotfiles {
    if ($IsOSX) {
        $OS = 'macOS'
    } elseif ($IsWindows) {
        $OS = 'Windows'
    } elseif ($IsLinux) {
        $OS = 'Linux'
    } else {
        $OS = 'unknown operation system'
    }
    Write-Host " Artevelde Dotfiles $Global:DotfilesVersion " -ForegroundColor Black -BackgroundColor DarkYellow -NoNewline
    $PSVersion = $PSVersionTable.GitCommitId # $PSVersionTable.PSVersion.ToString()
    Write-Host " on PowerShell $PSVersion for $OS" -ForegroundColor DarkGray
}
New-Alias -Name dot -Value Dotfiles

function FindConnectionListeningOn {
    Param(
        [Parameter(Mandatory=$true)]
        [Int16]
        $Port
    )
    if ($IsOSX) {
        (netstat -ao | Where-Object { $_ -match 'Proto' -or ($_ -match ":$Port " -and $_ -match 'LISTENING') })
    } elseif ($IsWindows) {
        (NETSTAT.EXE -ao | Where-Object { $_ -match 'Proto' -or ($_ -match ":$Port " -and $_ -match 'LISTENING') })
    }
}

function OpenUri {
    Param(
        [Parameter(Mandatory=$true)]
        [String]
        $Uri,

        [Switch]
        [Alias('https')]
        $Secure,

        [Switch]
        [Alias('b')]
        $Blisk,

        [Switch]
        [Alias('c')]
        $Chrome,

        [Switch]
        [Alias('cx')]
        $ChromeCanary,

        [Switch]
        [Alias('e')]
        $Edge,

        [Switch]
        [Alias('f')]
        $Firefox,

        [Switch]
        [Alias('fx')]
        $FirefoxDeveloperEdition,

        [Switch]
        [Alias('o')]
        $Opera,

        [Switch]
        [Alias('ox')]
        $OperaDeveloper,

        [Switch]
        [Alias('s')]
        $Safari,

        [Switch]
        [Alias('sx')]
        $SafariTechnologyPreview,

        [Switch]
        [Alias('v')]
        $Vivaldi
    )
    if (! ($Uri -match '^http(s)?://')) {
        $Protocol = 'http';
        if ($Secure) {
            $Protocol += 's' 
        }
        $Uri = $Protocol + '://' + $Uri
    }
    if ($IsOSX) {
        $Command = "open $Uri"
        if ($Blisk) {
            $Command += ' -a Blisk'
        } elseif ($Chrome) {
            $Command += ' -a "Google Chrome"'
        } elseif ($ChromeCanary) {
            $Command += ' -a "Google Chrome Canary"'
        } elseif ($Firefox) {
            $Command += ' -a Firefox'
        } elseif ($FirefoxDeveloperEdition) {
            $Command += ' -a FirefoxDeveloperEdition'
        } elseif ($Opera) {
            $Command += ' -a Opera'
        } elseif ($OperaDeveloper) {
            $Command += ' -a "Opera Developer"'
        } elseif ($Safari) {
            $Command += ' -a Safari'
        } elseif ($SafariTechnologyPreview) {
            $Command += ' -a "Safari Technology Preview"'
        } elseif ($Vivaldi) {
            $Command += ' -a Vivaldi'
        }
        Invoke-Expression -Command $Command
    } elseif ($IsWindows) {
        if ($Blisk) {
            $Browser = 'blisk.exe'
        } elseif ($Chrome) {
            $Browser = "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe"
        } elseif ($ChromeCanary) {
            $Browser = "$HOME\AppData\Local\Google\Chrome SxS\Application\chrome.exe"
        } elseif ($Edge) {
            $Command = "microsoft-edge:$Uri"
        } elseif ($Firefox) {
            $Browser = "${env:ProgramFiles}\Mozilla Firefox\firefox.exe"
        } elseif ($FirefoxDeveloperEdition) {
            $Browser = "${env:ProgramFiles}\Firefox Developer Edition\firefox.exe"
         } elseif ($Opera) {
             $Browser = "${env:ProgramFiles(x86)}\Opera\launcher.exe"
         } elseif ($OperaDeveloper) {
             $Browser = "${env:ProgramFiles(x86)}\Opera developer\launcher.exe"
        } elseif ($Vivaldi) {
             $Browser = 'vivaldi.exe'
        } else {
            $Command = $Uri;
        }
        if ($Browser) {
            Start-Process -FilePath $Browser -ArgumentList $Uri
        } elseif ($Command) {
            Start-Process -FilePath $Command
        }
    }
}
New-Alias -Name o -Value OpenUri

function SearchDotfilesCommands {
    Get-Command "$args" | Where-Object { $_.Source -eq 'dotfiles' }
    Get-Alias   "$args" | Where-Object { $_.Source -eq 'dotfiles' -or $_.Source -like 'aliases*' }
}

function X {
    exit
}

InitConfig