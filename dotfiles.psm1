Set-Variable -Name DotfilesConfigPath -Value (Join-Path -Path $Home -ChildPath '.dotfiles' | Join-Path -ChildPath 'config.json') -Option Constant -Scope Global -ErrorAction SilentlyContinue
Set-Variable -Name DotfilesVersion -Value (Get-Content (Join-Path -Path $Global:DotfilesInstallPath -ChildPath 'VERSION') | Select-Object -First 1 -Skip 1) -Option Constant -Scope Global -ErrorAction SilentlyContinue

# Config Functions

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
    ConvertTo-Json -InputObject $Global:DotfilesConfig | Out-File $Global:DotfilesConfigPath
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
        $AndroidSdkPath = "$HOME/Library/Android/sdk/tools"
        if (Test-Path $AndroidSdkPath) {
            $Path += $AndroidSdkPath
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
        $Path += "$HOME/.composer/vendor/bin"

        [System.Environment]::SetEnvironmentVariable('PATH', $Path -join ':')
    } elseif ($IsWindows) {
        $Path = [System.Environment]::GetEnvironmentVariable('Path') -split ';'
        $Path += @(
            "$HOME\AppData\Roaming\Composer\vendor\bin",
            'C:\php'
        )

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
        [Int16]
        [Parameter(Mandatory=$true)]
        $Port
    )
    if ($IsOSX) {
        (netstat -ao | Where-Object { $_ -match 'Proto' -or ($_ -match ":$Port " -and $_ -match 'LISTENING') })
    } elseif ($IsWindows) {
        (NETSTAT.EXE -ao | Where-Object { $_ -match 'Proto' -or ($_ -match ":$Port " -and $_ -match 'LISTENING') })
    }
}

# Install Functions

function InstallArtestead {
    Write-Host 'Installing Artestead (Artevelde Laravel Homestead)...'
    if (Get-Command vagrant -ErrorAction SilentlyContinue) {
        vagrant plugin install vagrant-hostsupdater
    }
    if (Get-Command cgr -ErrorAction SilentlyContinue) {
        cgr gdmgent/artestead
    }
}

function InstallBrew {
    Write-Host 'Using Ruby to install Homebrew...'
    sh -c 'ruby -e \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)\"'
    if (Get-Command brew -ErrorAction SilentlyContinue) {
        Write-Host 'Installed version of Homebrew: ' -NoNewline
        brew --version
    } else {
        Write-Warning -Message 'Homebrew was not installed.'
    }
}

function InstallBundler {
    Write-Host 'Using Ruby Gem to install the Bundler Gem...'
    gem install bundler
    if (Get-Command bundler -ErrorAction SilentlyContinue) {
        Write-Host 'Installed version of Bundler: ' -NoNewline
        bundler --version
    } else {
        Write-Warning -Message 'Bundler was not installed.'
    }
}

function InstallComposer {
    if ($IsOSX) {
        Write-Host 'Using PHP to install Composer...'
        sh -c 'curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer'
        if (Get-Command bundler -ErrorAction SilentlyContinue) {
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
        if (Test-Path $InstallerFile) {
            Write-Host 'Running Composer Installer...'
            Invoke-Expression $InstallerFile
            Remove-Item $InstallerFile
        }
    }
}

function InstallComposerCgr {
    Write-Host 'Using Composer to install CGR (Composer Global Require)...'
    if (Get-Command composer -ErrorAction SilentlyContinue) {
        composer global require consolidation/cgr
    } else {
        InstallComposer
    }
    
}

function InstallComposerPrestissimo {
    Write-Host 'Using Composer to install Prestissimo...'
    if (Get-Command composer -ErrorAction SilentlyContinue) {
        composer global require hirak/prestissimo
    } else {
        InstallComposer
    }
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
        if (Test-Path $OutFile) {
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
        if (Test-Path $OutFile) {
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
        if (Test-Path $OutFile) {
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
        if (Test-Path $OutFile) {
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
        if (Test-Path $OutFile) {
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
        if (Test-Path $OutFile) {
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
        $Version = 'v2.9.2.windows.1'
        $Urn = 'Git-2.9.2-64-bit.exe'
        $Uri = "https://github.com/git-for-windows/git/releases/download/$Version/$Urn"
        $InstallerFile = Join-Path -Path $env:TEMP -ChildPath $Urn
        Invoke-WebRequest -Uri $Uri -OutFile $InstallerFile
        if (Test-Path $InstallerFile) {
            Write-Host 'Running Git installer...'
            Write-Host ' - [Next >]'
            Write-Host ' - [Next >]'
            Write-Host " - 'Use Git and optional Unix tools from the Windows Command Prompt', [Next >]"
            Write-Host " - 'Checkout Windows-style, commit Unix-style line endings', [Next >]"
            Write-Host " - Use Windows' default console window, [Next >]"
            Write-Host ' - [Install]'
            Write-Host ' - [Finish]'
            Invoke-Expression $InstallerFile
            Remove-Item $InstallerFile
        }
    }
    if (Get-Command git -ErrorAction SilentlyContinue) {
            Write-Host 'Installed version of Git: ' -NoNewline
            git --version
    } else {
        Write-Warning -Message 'Git was not installed.'
    }
}

function InstallGitIgnoreGlobal {
    if (Get-Command git -ErrorAction SilentlyContinue) {
        InstallGit
    }
    Write-Host 'Installing GitIgnore Global...'
    $GitIgnoreSource = Join-Path -Path $Global:DotfilesInstallPath -ChildPath 'preferences' | Join-Path -ChildPath 'gitignore_global'
    $GitIgnoreDestination = Join-Path -Path $HOME -ChildPath '.gitignore_global'
    if (Test-Path $GitIgnoreSource) {
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
        if (Test-Path $InstallerArchive) {
            Write-Host 'Running Node Version Manager installer...'
            Expand-Archive -Path $InstallerArchive -DestinationPath $env:TEMP -Force
            $InstallerFile = Join-Path -Path $env:TEMP -ChildPath $Urn.Replace('zip', 'exe')
            if (Test-Path $InstallerFile) {
                Remove-Item -Path $InstallerArchive
                Invoke-Expression $InstallerFile
                Remove-Item $InstallerFile
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
    if ($IsOSX) {
        Write-Host 'Using Homebrew to install PHP 7.0...'
        sh -c 'brew tap homebrew/php && brew install php70 php70-mcrypt'
    } elseif ($IsWindows) {
        Write-Host 'Downloading PHP 7.0...'
        $Url = 'http://windows.php.net'
        $RelativeUrl = ((Invoke-WebRequest -Uri "$Url/download").Links | Where-Object { $_.href -match '/php-7.0.\d+-nts-Win32-VC14-x64.zip$' } | Select-Object -First 1).href
        $Uri = "$Url$RelativeUrl"
        $OutFile = Join-Path -Path $env:TEMP -ChildPath 'php.zip'
        Invoke-WebRequest -Uri $Uri -OutFile $OutFile
        if (Test-Path $OutFile) {
            $DestinationPath = 'C:\php'
            if ((Test-Path $DestinationPath) -and !(Test-Path "$DestinationPath.bak")) {
                Write-Host "Making a backup of previously installed version..."
                Move-Item -Path $DestinationPath -Destination "$DestinationPath.bak"
            }
            Write-Host 'Installing PHP 7.0...'
            Expand-Archive -Path $OutFile -DestinationPath $DestinationPath -Force
            Remove-Item -Path $OutFile
            Write-Host 'Configuring PHP 7.0...'
            $ConfigFile = Get-Content C:\php\php.ini-development
            $Replacements = @(
                'extension=php_curl.dll'
                'extension=php_mbstring.dll'
                'extension=php_openssl.dll'
            )
            foreach ($Replacement in $Replacements) {
                $ConfigFile = $ConfigFile.Replace(";$Replacement", $Replacement)
            }
            Set-Content -Path (Join-Path -Path $DestinationPath -ChildPath 'php.ini') -Value $ConfigFile
        }
    }
    if (Get-Command php -ErrorAction SilentlyContinue) {
        Write-Host 'Installed version of PHP: ' -NoNewline
        php -v
    }
}

# @TODO
function InstallPowerShell {
    $Response = Invoke-RestMethod -Method Get -Uri https://api.github.com/repos/powershell/powershell/releases/latest
    $Version = $Response.tag_name
    Write-Host $Version
    if ($IsOSX) {
        $OS = '.pkg$'
        $Uri = ($Response.assets | Where-Object { $_.name -match $OS }).browser_download_url
        $Urn = 'powershell.pkg'
        $InstallerFile = Join-Path -Path $env:TMPDIR -ChildPath $Urn
        Invoke-WebRequest -Uri $Uri -OutFile $InstallerFile
        if (Test-Path -Path $InstallerFile) {
            Invoke-Expression -Command $InstallerFile
            Remove-Item -Path $InstallerFile
       }
    } elseif ($IsWindows) {
        $OS = 'win10-x64.msi$'
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
            Write-Host ' - ConEmu > Startup > Tasks > 6 {Shells::PowerShell (Admin)} >'
            Write-Host '   C:\Program Files\PowerShell\6.0.0.10\powershell.exe -NoLogo'
            msiexec.exe /i $InstallerFile
            Remove-Item -Path $InstallerFile
       }
    } elseif ($IsLinux) {
        $OS = 'ubuntu1.16.04.1_amd64.deb$'
        $Uri = ($Response.assets | Where-Object { $_.name -match $OS }).browser_download_url
        $Urn = 'powershell-ubuntu1.16.04.1_amd64.deb'
        $InstallerFile = Join-Path -Path $env:TEMP -ChildPath $Urn
        Invoke-WebRequest -Uri $Uri -OutFile $InstallerFile

        Remove-Item -Path $InstallerFile
    }
}

function InstallRuby {
    if ($IsOSX) {
        Write-Host 'Using Homebrew to install Ruby...'
        sh -c 'brew install ruby'
    } elseif ($IsWindows) {
        $Url = 'http://rubyinstaller.org/downloads/'
        Write-Host 'Downloading Ruby installer...'
        $Version = '2.2.\d+' # Jekyll is not compatible with newer versions of Ruby
        $DirectoryName = 'Ruby22-x64'
        $Uri = ((Invoke-WebRequest -Uri $Url).Links | Where-Object { $_.href -match "rubyinstaller-$Version-x64.exe$" } | Select-Object -First 1).href
        $Urn = "$DirectoryName.exe"
        $InstallerFile = Join-Path -Path $env:TEMP -ChildPath $Urn
        Invoke-WebRequest -Uri $Uri -OutFile $InstallerFile
        if (Test-Path $InstallerFile) {
            Write-Host 'Running Ruby installer...'
            Write-Host " - 'English', [OK]"
            Write-Host " - 'I accept the License', [Next>]"
            Write-Host " - 'C:\$DirectoryName', 'Add Ruby executables to your PATH', [Install]"
            Write-Host ' - [Finish]'
            Invoke-Expression $InstallerFile
            Remove-Item $InstallerFile
        }
        Write-Host 'Downloading Ruby DevKit installer...'
        $Version = 'mingw64-64'
        $DirectoryName = 'DevKit'
        $Uri = ((Invoke-WebRequest -Uri $Url).Links | Where-Object { $_.href -match "DevKit-$Version-(\S+)-sfx.exe$" } | Select-Object -First 1).href
        $Urn = "$DirectoryName-DevKit.exe"
        $InstallerFile = Join-Path -Path $env:TEMP -ChildPath $Urn
        Invoke-WebRequest -Uri $Uri -OutFile $InstallerFile
        if (Test-Path $InstallerFile) {
            Write-Host 'Running Ruby DevKit installer...'
            Invoke-Expression "$InstallerFile -o'C:\$DirectoryName' -y"
            Remove-Item $InstallerFile
            Set-Location C:\$DirectoryName
            ruby dk.rb init
            ruby dk.rb install
        }
    }
    if (Get-Command ruby -ErrorAction SilentlyContinue) {
        Write-Host 'Installed version of Ruby: ' -NoNewline
        ruby --version
        if (Get-Command gem -ErrorAction SilentlyContinue) {
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

function OpenUri {
    Param(
        [String]
        [Parameter(Mandatory=$true)]
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
    if (Test-Path $File) {
        Write-Host 'Removing Local Artestead...'
        if (Test-Path Vagrantfile) {
            vagrant destroy
            Remove-Item -Path .vagrant -Recurse -Force -ErrorAction SilentlyContinue
            Remove-Item -Path Vagrantfile -Force -ErrorAction SilentlyContinue
        }
        Remove-Item -Path .gitignore -Force -ErrorAction SilentlyContinue
        Remove-Item -Path *.sh -Force -ErrorAction SilentlyContinue
        Remove-Item -Path composer.* -Force -ErrorAction SilentlyContinue
        Remove-Item -Path vendor -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item -Path $File -Force -ErrorAction SilentlyContinue
    } else {
        Write-Warning -Message "This is not an Artestead project. Could not find '$File' in this directory."
    }
}

function RemoveAndroidStudio {
    if ($IsOSX) {
        # rm -Rf /Applications/Android\ Studio.app
        # rm -Rf ~/Library/Preferences/AndroidStudio*
        # rm ~/Library/Preferences/com.google.android.studio.plist
        # rm -Rf ~/Library/Application\ Support/AndroidStudio*
        # rm -Rf ~/Library/Logs/AndroidStudio*
        # rm -Rf ~/Library/Caches/AndroidStudio*

        # # Projects
        # rm -Rf ~/AndroidStudioProjects

        # # Gradle
        # rm -Rf ~/.gradle

        # # Android Virtual Devices
        # rm -Rf ~/.android

        # # Android SDK
        # rm -Rf ~/Library/Android*
    }
}

function UninstallBrew {
    Write-Host 'Using Ruby to uninstall Homebrew...'
    sh -c 'ruby -e \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/uninstall)\"'
}

function UninstallRuby {
    if ($IsOSX) {
        Write-Host 'Using Homebrew to uninstall Ruby...'
        if (Get-Command brew -ErrorAction SilentlyContinue) {
            brew uninstall ruby
        }
    } elseif ($IsWindows) {
        Write-Host 'Uninstalling Ruby...'
        Remove-Item -Recurse -Force C:\DevKit
        Remove-Item -Recurse -Force C:\Ruby22-x64
    }
}

function UpdateBundler {
    $File = 'Gemfile'
    if (Test-Path $File) {
        if (Get-Command bundler -ErrorAction SilentlyContinue) {
            bundler update
            gem cleanup
        } else {
            Write-Warning -Message 'Bundler Ruby Gem is not installed. Run InstallBundler.'
        }
    } else {
        Write-Warning -Message "Cannot run Bundler in this directory because a '$File' is required."
    }
}

function UpdateBrew {
    Param(
        [Switch]
        $Force
    )
    Write-Host 'Updating Homebrew...'
    if ($IsOSX -and (Get-Command brew -ErrorAction SilentlyContinue)) {
        if ($Force) {
            sh -c 'sudo chown -R $(whoami):admin /usr/local'
        }
        sh -c 'brew update && brew upgrade && brew cleanup'
    }
}

function UpdateComposer {
    Param(
        [Switch]
        $Force
    )
    Write-Host 'Updating Composer and CGR installed packages...'
    if (Get-Command composer -ErrorAction SilentlyContinue) {
        composer self-update
        composer global update
        if (Get-Command cgr -ErrorAction SilentlyContinue) {
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
    Get-Alias  "$args" | Where-Object { $_.Source -eq 'dotfiles' -or $_.Source -like 'aliases*' }
}

function UpdateSyllabi {
    Push-Location
    SetLocationPathSyllabi
    $Directories = Get-ChildItem -Directory -Name | Where-Object { $_ -match '^((\d{4}|utl|mod)_|syllabus)' }

    foreach ($Directory in $Directories) {
        Push-Location $Directory
        if (Test-Path .git) {
            Write-Host " $Directory " -BackgroundColor Blue -ForegroundColor White
            git pull | Write-Host -ForegroundColor DarkGray
        }
        Pop-Location
    }
    Pop-Location
}

function CloneSyllabus {
    Param(
        [String]
        [Parameter(Mandatory=$true)]
        $Name,
        [String]
        $DestinationName
    )
    $DestinationName = $DestinationName.ToLower()
    SetLocationPathSyllabi
    git clone https://github.com/gdmgent/$Name $DestinationName
    if ($DestinationName) {
        SetLocationPathSyllabi $DestinationName
    } else {
        SetLocationPathSyllabi $Name
    }
    GitCheckoutGitHubPages
}

function X {
    exit
}