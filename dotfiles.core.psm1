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

function RemoveError {
    $Error.Remove($Error[$Error.Count - 1])
}

# Config Functions
# ----------------

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
    if ($IsOSX) {
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

# Install Functions
# -----------------

function InstallArtestead {
    Write-Host 'Installing Artestead (Artevelde Laravel Homestead)...'
    if (ExistCommand -Name vagrant) {
        vagrant plugin install vagrant-hostsupdater
    }
    if (ExistCommand -Name cgr) {
        cgr gdmgent/artestead
    }
}

function InstallBrew {
    Write-Host 'Using Ruby to install Homebrew...'
    sh -c 'ruby -e \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)\"'
    if (ExistCommand -Name brew) {
        Write-Host 'Installed version of Homebrew: ' -NoNewline
        brew --version
    } else {
        Write-Warning -Message 'Homebrew was not installed.'
    }
}

function InstallBundler {
    Write-Host 'Using Ruby Gem to install the Bundler Gem...'
    gem install bundler
    if (ExistCommand -Name bundle) {
        Write-Host 'Installed version of Bundler: ' -NoNewline
        bundle --version
    } else {
        Write-Warning -Message 'Bundler was not installed.'
    }
}

function InstallComposer {
    if ($IsOSX) {
        Write-Host 'Using PHP to install Composer...'
        sh -c 'curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer'
        if (ExistCommand -Name bundler) {
            Write-Host 'Installed version of Composer: ' -NoNewline
            composer --version
        } else {
            Write-Warning -Message 'Composer was not installed.'
        }
    } elseif ($IsWindows) {
        Write-Host 'Downloading Composer installer...'
        $Urn = 'Composer-Setup.exe'
        $Uri = "https://getcomposer.org/$Urn"
        $InstallerFile = Join-Path -Path $env:TEMP -ChildPath $Urn
        Invoke-WebRequest -Uri $Uri -OutFile $InstallerFile
        if (Test-Path -Path $InstallerFile) {
            Write-Host 'Running Composer Installer...'
            Invoke-Expression -Command $InstallerFile
            Remove-Item -Path $InstallerFile
        }
    }
}

function InstallComposerCgr {
    Write-Host 'Using Composer to install CGR (Composer Global Require)...'
    if (!(ExistCommand -Name composer)) {
        InstallComposer
    }
    composer global require consolidation/cgr
}

function InstallComposerPrestissimo {
    Write-Host 'Using Composer to install Prestissimo...'
    if (!(ExistCommand -Name composer)) {
        InstallComposer
    }
    composer global require hirak/prestissimo
}

function InstallFontFiraCode {
    Write-Host 'Downloading Fira Code typeface by Nikita Prokopov...'
    $Response = Invoke-RestMethod -Method Get -Uri https://api.github.com/repos/tonsky/FiraCode/releases/latest
    $Name = 'FiraCode'
    $Urn = "$Name.zip"
    $Uri = $Response.assets.browser_download_url
    if ($IsOSX) {
        $OutFile = Join-Path -Path $env:TMPDIR -ChildPath $Urn
        Invoke-WebRequest -Uri $Uri -OutFile $OutFile
        if (Test-Path -Path $OutFile) {
            Write-Host 'Installing Fira Code typeface...'
            $DestinationPath = "$HOME/Library/Fonts/"
            $TempPath = "$env:TMPDIR$Name/"
            $output = unzip $OutFile **/*.otf -d $TempPath -o
            Remove-Item -Path $OutFile
            Move-Item -Path ${TempPath}otf/*.otf -Destination $DestinationPath -Force
            Remove-Item -Path $TempPath -Recurse -Force
        }
    } elseif ($IsWindows) {
        $OutFile = Join-Path -Path $env:TEMP -ChildPath $Urn
        Invoke-WebRequest -Uri $Uri -OutFile $OutFile
        if (Test-Path -Path $OutFile) {
            Write-Host 'Installing Fira Code typeface...'
            $DestinationPath = "C:\Windows\Fonts\"
            $TempPath = "$env:TEMP$Name\"
            Expand-Archive -Path $OutFile -DestinationPath $TempPath -Force
            Remove-Item -Path $OutFile
            $Output = Get-ChildItem -Path ${TempPath}otf\*.otf | Select-Object { (New-Object -ComObject Shell.Application).Namespace(0x14).CopyHere($_.FullName) }
            Remove-Item -Path $TempPath -Recurse -Force
        }
    }
}

function InstallFontHack {
    Write-Host 'Downloading Hack typeface by Chris Simpkins...'
    $Response = Invoke-RestMethod -Method Get -Uri https://api.github.com/repos/chrissimpkins/Hack/releases/latest
    $Name = 'Hack'
    $Urn = "$Name.zip"
    $Uri = ($Response.assets | Where-Object { $_.name -match '^Hack-(.+)-otf.zip$' }).browser_download_url
    if ($IsOSX) {
        $OutFile = Join-Path -Path $env:TMPDIR -ChildPath $Urn
        Invoke-WebRequest -Uri $Uri -OutFile $OutFile
        if (Test-Path -Path $OutFile) {
            Write-Host 'Installing Hack typeface...'
            $DestinationPath = "$HOME/Library/Fonts/"
            $TempPath = "$env:TMPDIR$Name/"
            $output = unzip $OutFile *.otf -d $TempPath -o
            Remove-Item -Path $OutFile
            Move-Item -Path ${TempPath}*.otf -Destination $DestinationPath -Force
            Remove-Item -Path $TempPath -Recurse -Force
        }
    } elseif ($IsWindows) {
        $OutFile = Join-Path -Path $env:TEMP -ChildPath $Urn
        Invoke-WebRequest -Uri $Uri -OutFile $OutFile
        if (Test-Path -Path $OutFile) {
            Write-Host 'Installing Hack typeface...'
            $DestinationPath = "C:\Windows\Fonts\"
            $TempPath = "$env:TEMP$Name\"
            Expand-Archive -Path $OutFile -DestinationPath $TempPath -Force
            Remove-Item -Path $OutFile
            $Output = Get-ChildItem -Path ${TempPath}*.otf | Select-Object { (New-Object -ComObject Shell.Application).Namespace(0x14).CopyHere($_.FullName) }
            Remove-Item -Path $TempPath -Recurse -Force
        }
    }
}

function InstallFontHasklig {
    Write-Host 'Downloading Hasklig typeface by Ian Tuomi...'
    $Response = Invoke-RestMethod -Method Get -Uri https://api.github.com/repos/i-tu/Hasklig/releases?per_page=1
    # $Response = Invoke-RestMethod -Method Get -Uri https://api.github.com/repos/i-tu/Hasklig/releases/latest
    $Name = 'Hasklig'
    $Urn = "$Name.zip"
    $Uri = $Response.assets.browser_download_url
    if ($IsOSX) {
        $OutFile = Join-Path -Path $env:TMPDIR -ChildPath $Urn
        Invoke-WebRequest -Uri $Uri -OutFile $OutFile
        if (Test-Path -Path $OutFile) {
            Write-Host 'Installing Hasklig typeface...'
            $DestinationPath = "$HOME/Library/Fonts/"
            $TempPath = "$env:TMPDIR$Name/"
            $output = unzip $OutFile *.otf -d $TempPath -o
            Remove-Item -Path $OutFile
            Move-Item -Path ${TempPath}*.otf -Destination $DestinationPath -Force
            Remove-Item -Path $TempPath -Recurse -Force
        }
    } elseif ($IsWindows) {
        $OutFile = Join-Path -Path $env:TEMP -ChildPath $Urn
        Invoke-WebRequest -Uri $Uri -OutFile $OutFile
        if (Test-Path -Path $OutFile) {
            Write-Host 'Installing Hasklig typeface...'
            $DestinationPath = "C:\Windows\Fonts\"
            $TempPath = "$env:TEMP$Name\"
            Expand-Archive -Path $OutFile -DestinationPath $TempPath -Force
            Remove-Item -Path $OutFile
            $Output = Get-ChildItem -Path ${TempPath}*.otf | Select-Object { (New-Object -ComObject Shell.Application).Namespace(0x14).CopyHere($_.FullName) }
            Remove-Item -Path $TempPath -Recurse -Force
        }
    }
}

function InstallGit {
    if ($IsOSX) {
        Write-Host 'Using Homebrew to install Git...'
        sh -c 'brew install git'
    } elseif ($IsWindows) {
        Write-Host 'Downloading Git installer...'
        $Response = Invoke-RestMethod -Method Get -Uri https://api.github.com/repos/git-for-windows/git/releases/latest
        $Version = $Response.tag_name
        $OS = '-64-bit.exe$'
        $Uri = ($Response.assets | Where-Object { $_.name -match $OS }).browser_download_url
        $Urn = 'git-64-bit.exe'
        $InstallerFile = Join-Path -Path $env:TEMP -ChildPath $Urn
        Invoke-WebRequest -Uri $Uri -OutFile $InstallerFile
        if (Test-Path -Path $InstallerFile) {
            Write-Host 'Running Git installer...'
            Write-Host ' - [Next >]'
            Write-Host ' - [Next >]'
            Write-Host " - 'Use Git and optional Unix tools from the Windows Command Prompt', [Next >]"
            Write-Host " - 'Checkout Windows-style, commit Unix-style line endings', [Next >]"
            Write-Host " - 'Use Windows' default console window', [Next >]"
            Write-Host ' - [Install]'
            Write-Host ' - [Finish]'
            Start-Process -FilePath $InstallerFile -Wait
            Remove-Item -Path $InstallerFile
        }
    }
    if (ExistCommand -Name git) {
        git config --global credential.helper wincred
        Write-Host 'Installed version of Git: ' -NoNewline
        git --version
    } else {
        Write-Warning -Message 'Git was not installed.'
    }
}

function InstallGitIgnoreGlobal {
    if (!(ExistCommand -Name git)) {
        InstallGit
    }
    Write-Host 'Installing GitIgnore Global...'
    $GitIgnoreSource = Join-Path -Path $Global:DotfilesInstallPath -ChildPath 'preferences' | Join-Path -ChildPath 'gitignore_global'
    $GitIgnoreDestination = Join-Path -Path $HOME -ChildPath '.gitignore_global'
    if (Test-Path -Path $GitIgnoreSource) {
        Copy-Item -Path $GitIgnoreSource -Destination $GitIgnoreDestination
    }
}

function InstallNvm {
    if ($IsOSX) {
        Write-Host 'Using Homebrew to install Node Version Manager...'
        sh -c 'brew install nvm'
        Write-Host 'Installed version of NVM: ' -NoNewline
        nvm --version
    } elseif ($IsWindows) {
        $Response = Invoke-RestMethod -Method Get -Uri https://api.github.com/repos/coreybutler/nvm-windows/releases/latest
        $Version = $Response.name
        Write-Host "Downloading Node Version Manager $Version..."
        $Urn = 'nvm-setup.zip'
        $Uri = ($Response.assets | Where-Object { $_.name.Equals($Urn) }).browser_download_url
        $InstallerArchive = Join-Path -Path $env:TEMP -ChildPath $Urn
        Invoke-WebRequest -Uri $Uri -OutFile $InstallerArchive
        if (Test-Path -Path $InstallerArchive) {
            Write-Host 'Running Node Version Manager installer...'
            Expand-Archive -Path $InstallerArchive -DestinationPath $env:TEMP -Force
            $InstallerFile = Join-Path -Path $env:TEMP -ChildPath $Urn.Replace('zip', 'exe')
            if (Test-Path -Path $InstallerFile) {
                Remove-Item -Path $InstallerArchive
                Start-Process -FilePath $InstallerFile -Wait
                Remove-Item -Path $InstallerFile
            }
        }
    }
}

function InstallOhMyZsh {
    if ($IsOSX) {
        Write-Host 'Using Homebrew to install Zsh...'
        sh -c 'brew install zsh'
        Write-Host 'Installed version of Zsh: ' -NoNewline
        zsh --version
        Write-Host 'Using Bash to install Oh-My-Zsh...'
        sh -c '$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)'
    } else {
        Write-Warning -Message 'This is for macOS only.'
    }
}

function InstallPhp {
    $Version = '7.1'
    if ($IsOSX) {
        Write-Host "Using Homebrew to install PHP $Version..."
        sh -c 'brew tap homebrew/php && brew install php71 php71-mcrypt'
    } elseif ($IsWindows) {
        Write-Host "Downloading PHP $Version..."
        $Url = 'http://windows.php.net'
        $RelativeUrl = ((Invoke-WebRequest -Uri "$Url/download").Links | Where-Object { $_.href -match "/php-$Version.\d+-nts-Win32-VC14-x64.zip$" } | Select-Object -First 1).href
        $Uri = "$Url$RelativeUrl"
        $OutFile = Join-Path -Path $env:TEMP -ChildPath 'php.zip'
        Invoke-WebRequest -Uri $Uri -OutFile $OutFile
        if (Test-Path -Path $OutFile) {
            $DestinationPath = 'C:\php'
            if ((Test-Path -Path $DestinationPath) -and !(Test-Path -Path "$DestinationPath.bak")) {
                Write-Host "Making a backup of previously installed version..."
                Move-Item -Path $DestinationPath -Destination "$DestinationPath.bak"
            }
            Write-Host 'Installing PHP...'
            Expand-Archive -Path $OutFile -DestinationPath $DestinationPath -Force
            Remove-Item -Path $OutFile
            Write-Host 'Configuring PHP...'
            $ConfigFile = Get-Content -Path C:\php\php.ini-development
            $Replacements = @(
                'extension=php_curl.dll'
                'extension=php_gd2.dll'
                'extension=php_mbstring.dll'
                'extension=php_openssl.dll'
                'extension=php_pdo_sqlite.dll'
            )
            foreach ($Replacement in $Replacements) {
                $ConfigFile = $ConfigFile.Replace(";$Replacement", $Replacement)
            }
            # Adding CA Root Certificates for SSL
            $ConfigFile = $ConfigFile.Replace(';openssl.cafile=', 'openssl.cafile=' + $Global:DotfilesInstallPath + '\ssl\cacert.pem')
            Set-Content -Path (Join-Path -Path $DestinationPath -ChildPath 'php.ini') -Value $ConfigFile
        }
    }
    if (ExistCommand -Name php) {
        Write-Host 'Installed version of PHP: ' -NoNewline
        php -v
    }
}

function InstallPowerShell {
    $Response = Invoke-RestMethod -Method Get -Uri https://api.github.com/repos/powershell/powershell/releases/latest
    $Version = $Response.tag_name
    if ($IsOSX) {
        $OS = '.pkg$'
        $Uri = ($Response.assets | Where-Object { $_.name -match $OS }).browser_download_url
        $Urn = 'powershell.pkg'
        $InstallerFile = Join-Path -Path $env:TMPDIR -ChildPath $Urn
        Invoke-WebRequest -Uri $Uri -OutFile $InstallerFile
        if (Test-Path -Path $InstallerFile) {
            Write-Host "Installing PowerShell $Version..."
            Invoke-Expression -Command "sudo installer -pkg $InstallerFile -target /"
            Remove-Item -Path $InstallerFile
       }
    } elseif ($IsWindows) {
        $OS = 'win10-win2k16-x64.msi$'
        $Uri = ($Response.assets | Where-Object { $_.name -match $OS }).browser_download_url
        $Urn = 'powershell-win10-x64.msi'
        $InstallerFile = Join-Path -Path $env:TEMP -ChildPath $Urn
        Invoke-WebRequest -Uri $Uri -OutFile $InstallerFile
        if (Test-Path -Path $InstallerFile) {
            Write-Host "Installing PowerShell $Version..."
            Write-Host ' - [Next]'
            Write-Host " - 'I accept the terms in the License Agreement', [next]"
            Write-Host " - 'C:\Program Files\PowerShell\', [Next]"
            Write-Host ' - [Finish]'
            Write-Host ' - ConEmu > Settings... > Startup > Tasks > 6 {Shells::PowerShell (Admin)} >'
            Write-Host ('   C:\Program Files\PowerShell\' + ($Version.Substring(1) -replace '[a-zA-Z\-]+','') + '\powershell.exe -NoLogo')
            Start-Process -FilePath 'msiexec.exe' -ArgumentList "/i $InstallerFile" -Wait
            Remove-Item -Path $InstallerFile
       }
    } elseif ($IsLinux) {
        $OS = 'ubuntu1.16.04.1_amd64.deb$'
        $Uri = ($Response.assets | Where-Object { $_.name -match $OS }).browser_download_url
        $Urn = 'powershell-ubuntu1.16.04.1_amd64.deb'
        $InstallerFile = Join-Path -Path $env:TEMP -ChildPath $Urn
        Invoke-WebRequest -Uri $Uri -OutFile $InstallerFile
        # @TODO implement
        Remove-Item -Path $InstallerFile
    }
}

function InstallRuby {
    if ($IsOSX) {
        Write-Host 'Using Homebrew and rbenv to install Ruby...'
        sh -c 'brew install rbenv && rbenv install 2.3.3 && rbenv global 2.3.3'
    } elseif ($IsWindows) {
        $Url = 'http://rubyinstaller.org/downloads/'
        Write-Host 'Downloading Ruby installer...'
        $Version = '2.3.\d+' # Jekyll is not compatible with newer versions of Ruby
        $RubyDirectoryName = 'Ruby23-x64'
        $Uri = ((Invoke-WebRequest -Uri $Url).Links | Where-Object { $_.href -match "rubyinstaller-$Version-x64.exe$" } | Select-Object -First 1).href
        $Urn = "$RubyDirectoryName.exe"
        $InstallerFile = Join-Path -Path $env:TEMP -ChildPath $Urn
        Invoke-WebRequest -Uri $Uri -OutFile $InstallerFile
        if (Test-Path -Path $InstallerFile) {
            Write-Host 'Running Ruby installer...'
            Write-Host " - 'English', [OK]"
            Write-Host " - 'I accept the License', [Next>]"
            Write-Host " - 'C:\$RubyDirectoryName', 'Add Ruby executables to your PATH', [Install]"
            Write-Host ' - [Finish]'
            Start-Process -FilePath $InstallerFile -Wait
            Remove-Item -Path $InstallerFile
        }
        Write-Host 'Downloading Ruby DevKit installer...'
        $Version = 'mingw64-64'
        $DevKitDirectoryName = 'DevKit'
        $Uri = ((Invoke-WebRequest -Uri $Url).Links | Where-Object { $_.href -match "DevKit-$Version-(\S+)-sfx.exe$" } | Select-Object -First 1).href
        $Urn = "$DevKitDirectoryName.exe"
        $InstallerFile = Join-Path -Path $env:TEMP -ChildPath $Urn
        Invoke-WebRequest -Uri $Uri -OutFile $InstallerFile
        if (Test-Path -Path $InstallerFile) {
            Write-Host 'Running Ruby DevKit installer...'
            Start-Process -FilePath $InstallerFile -ArgumentList "-oC:\$DevKitDirectoryName -y" -Wait
            Remove-Item -Path $InstallerFile
            Set-Location -Path C:\$DevKitDirectoryName
            # ruby dk.rb init
            "---`n- C:\$RubyDirectoryName`n" | Out-File -FilePath 'config.yml' -Encoding utf8
            ruby dk.rb install
        }
    }
    if (ExistCommand -Name ruby) {
        Write-Host 'Installed version of Ruby: ' -NoNewline
        ruby --version
        if (ExistCommand -Name gem) {
            Write-Host 'Installed version of Gem: ' -NoNewline
            gem --version
        }
    } else {
        Write-Warning -Message 'Ruby is not correctly installed.'
    }
}

function InstallVisualStudioCode {
    if ($IsOSX) {
        # Fixes a PowerShell extension in Visual Studio Code
        $Path = '/usr/local/Cellar/openssl/1.0.2h_1/lib'
        $Destination = '/usr/local/lib'
        Copy-Item -Path $Path/libcrypto.dylib -Destination $Destination/libcrypto.1.0.0.dylib
        Copy-Item -Path $Path/libssl.dylib -Destination $Destination/libssl.1.0.0.dylib
    }
}

function InstallYarn {
    if ($IsOSX) {
        Write-Host "Using Homebrew to install Yarn..."
        sh -c 'brew install yarn'
    } elseif ($IsWindows) {
        $Response = Invoke-RestMethod -Method Get -Uri https://api.github.com/repos/yarnpkg/yarn/releases/latest
        $Version = $Response.tag_name
        $OS = '.msi$'
        $Uri = ($Response.assets | Where-Object { $_.name -match $OS }).browser_download_url
        $Urn = 'yarn.msi'
        $InstallerFile = Join-Path -Path $env:TEMP -ChildPath $Urn
        Invoke-WebRequest -Uri $Uri -OutFile $InstallerFile
        if (Test-Path -Path $InstallerFile) {
            Write-Host "Installing Yarn $Version..."
            Write-Host ' - [Next]'
            Write-Host " - 'I accept the terms License Agreement', [Next]"
            Write-Host " - 'C:\Program Files (x86)\Yarn\', [Next]"
            Write-Host ' - [Install]'
            Write-Host ' - [Finish]'
            Start-Process -FilePath 'msiexec.exe' -ArgumentList "/i $InstallerFile" -Wait
            Remove-Item -Path $InstallerFile
       }
    }
}

function OpenUri {
    Param(
        [Parameter(Mandatory=$true)]
        [String]
        $Uri
    )
    if ($IsOSX) {
        Invoke-Expression -Command "open $Uri"
    } elseif ($IsWindows) {
        Invoke-Expression -Command "cmd.exe /C 'start $Uri'"
    }
}

function RemoveLocalArtestead {
    $File = 'Artestead.yaml'
    if (Test-Path -Path $File) {
        Write-Host 'Removing Local Artestead...'
        $ToRemove = @($File)
        if (Test-Path -Path Vagrantfile) {
            vagrant destroy
            $ToRemove += @('.vagrant', 'Vagrantfile')
        }
        $ToRemove += @(
            '.gitignore',
            '*.sh',
            'composer.*',
            'vendor'
        )
        Remove-Item -Path $ToRemove -Recurse -Force -ErrorAction SilentlyContinue
    } else {
        Write-Warning -Message "This is not an Artestead project. Could not find '$File' in this directory."
    }
}

function RemoveAndroidStudio {
    if ($IsOSX) {
        $ToRemove = @(
            '/Applications/Android\ Studio.app',
            '~/.android', # Android Virtual Devices
            '~/.gradle',  # Gradle
            '~/AndroidStudioProjects',
            '~/Library/Application\ Support/AndroidStudio*',
            '~/Library/Android*', # Android SDK
            '~/Library/Caches/AndroidStudio*',
            '~/Library/Logs/AndroidStudio*',
            '~/Library/Preferences/AndroidStudio*',
            '~/Library/Preferences/com.google.android.studio.plist'
        )
        Remove-Item -Path $ToRemove -Recurse -Force -ErrorAction SilentlyContinue
    }
}

function UninstallBrew {
    Write-Host 'Using Ruby to uninstall Homebrew...'
    sh -c 'ruby -e \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/uninstall)\"'
}

function UninstallRuby {
    if ($IsOSX) {
        Write-Host 'Using Homebrew to uninstall Ruby...'
        if (ExistCommand -Name brew) {
            brew uninstall ruby
        }
    } elseif ($IsWindows) {
        Write-Host 'Uninstalling Ruby...'
        Remove-Item -Path @('C:\DevKit', 'C:\Ruby23-x64') -Recurse -Force
    }
}

function UpdateBrew {
    Write-Host 'Updating Homebrew...'
    if ($IsOSX -and (ExistCommand -Name brew)) {
        sh -c 'brew update && brew upgrade && brew cleanup'
    }
}

function UpdateBundler {
    $File = 'Gemfile'
    if (Test-Path $File) {
        if (ExistCommand -Name bundle) {
            bundle update
            gem cleanup
        } else {
            Write-Warning -Message 'Bundler Ruby Gem is not installed. Run InstallBundler.'
        }
    } else {
        Write-Warning -Message "Cannot run Bundler in this directory because a '$File' is required."
    }
}

function UpdateComposer {
    Param(
        [Switch]
        $Force
    )
    Write-Host 'Updating Composer and CGR installed packages...'
    if (ExistCommand -Name composer) {
        composer self-update
        composer global update
        if (ExistCommand -Name cgr) {
            $Packages                 = @{}
            $Packages['drush']        = 'drush/drush'
            $Packages['php-cs-fixer'] = 'friendsofphp/php-cs-fixer'
            $Packages['artestead']    = 'gdmgent/artestead'
            $Packages['laravel']      = 'laravel/installer'
            $Packages['psysh']        = 'psy/psysh'
            $Packages['symfony']      = 'symfony/symfony-installer'
            $Packages['wp']           = 'wp-cli/wp-cli'
            foreach ($Package in $Packages.GetEnumerator()) {
                if ($Force -or (Get-Command $Package.Key -ErrorAction SilentlyContinue)) {
                    cgr $Package.Value
                }
            }
        }
    } else {
        Write-Warning -Message 'Composer is not installed. Run InstallComposer or InstallComposerCgr.'
    }
}

function SearchDotfilesCommands {
    Get-Command "$args" | Where-Object { $_.Source -eq 'dotfiles' }
    Get-Alias   "$args" | Where-Object { $_.Source -eq 'dotfiles' -or $_.Source -like 'aliases*' }
}

function CloneProject {
    Param(
        [Parameter(Mandatory=$true)]
        [String]
        $Name,
        [String]
        $DestinationName,
        [String]
        $Service = 'github.com/gdmgent'
    )
    $DestinationName = $DestinationName.ToLower()
    SetLocationPathCode
    git clone https://$Service/$Name $DestinationName
    if ($DestinationName) {
        SetLocationPathCode $DestinationName
    } else {
        SetLocationPathCode $Name
    }
}

function CloneSyllabus {
    Param(
        [Parameter(Mandatory=$true)]
        [String]
        $Name,
        [String]
        $DestinationName,
        [Switch]
        $Master
    )
    $Branch = if ($Master) { 'master' } else { 'gh-pages' }
    $DestinationName = $DestinationName.ToLower()
    SetLocationPathSyllabi
    git clone https://github.com/gdmgent/$Name --branch $Branch --single-branch $DestinationName
    if ($DestinationName) {
        SetLocationPathSyllabi $DestinationName
    } else {
        SetLocationPathSyllabi $Name
    }
}

function NewSyllabus {
    Param(
        [Parameter(Mandatory=$true)]
        [String]
        $Name
    )
    $Name = $Name.ToLower()
    SetLocationPathSyllabi
    New-Item -Path $Name -ItemType Directory
    Set-Location -Path $Name
    git init
    git checkout -b gh-pages
    git remote add origin https://github.com/gdmgent/$Name.git
    New-Item -Path README.md -ItemType File
    git add .
    git commit -m [WIP]
    git push --set-upstream origin gh-pages
}

function PullSyllabi {
    Param(
        [Switch]
        $Force
    )
    Push-Location
    SetLocationPathSyllabi
    $Directories = Get-ChildItem -Directory -Name | Where-Object { $_ -match '^((\d{4}|utl|mod)_|syllabus)|.github.io$' }
    foreach ($Directory in $Directories) {
        Push-Location $Directory
        if (Test-Path -Path .git) {
            Write-Host " $Directory " -BackgroundColor Blue -ForegroundColor White
            git add . | Write-Host -ForegroundColor DarkGray
            if ($Force) {
                git stash | Write-Host -ForegroundColor DarkGray
                git stash drop | Write-Host -ForegroundColor DarkGray
                git pull | Write-Host -ForegroundColor DarkGray
            } else {
                git pull | Write-Host -ForegroundColor DarkGray
            }
        }
        Pop-Location
    }
    Pop-Location
}

function PushSyllabi {
    Push-Location
    SetLocationPathSyllabi
    $Directories = Get-ChildItem -Directory -Name | Where-Object { $_ -match '^((\d{4}|utl|mod)_|syllabus)|.github.io$' }
    foreach ($Directory in $Directories) {
        Push-Location $Directory
        if (Test-Path -Path .git) {
            Write-Host " $Directory " -BackgroundColor Blue -ForegroundColor White
            git add . | Write-Host -ForegroundColor DarkGray
            git commit -a -m [WIP] | Write-Host -ForegroundColor DarkGray
            git push | Write-Host -ForegroundColor DarkGray
        }
        Pop-Location
    }
    Pop-Location
}

function StatusSyllabi {
    Push-Location
    SetLocationPathSyllabi
    $Directories = Get-ChildItem -Directory -Name | Where-Object { $_ -match '^((\d{4}|utl|mod)_|syllabus)|.github.io$' }
    foreach ($Directory in $Directories) {
        Push-Location $Directory
        if (Test-Path -Path .git) {
            Write-Host " $Directory " -BackgroundColor Blue -ForegroundColor White
            git status | Write-Host -ForegroundColor DarkGray
        }
        Pop-Location
    }
    Pop-Location
}

function X {
    exit
}