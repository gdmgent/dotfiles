# import: . ./dotfiles.ps1

Set-Variable -Name DotfilesConfigPath -Value (Join-Path -Path $Home -ChildPath '.dotfiles' | Join-Path -ChildPath 'config.json') -Option Constant -Scope Global
Set-Variable -Name DotfilesVersion -Value (Get-Content (Join-Path -Path $Global:DotfilesInstallPath -ChildPath 'VERSION') | Select-Object -First 1 -Skip 1) -Option Constant -Scope Global

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

function ReadConfig([string] $Name) {
    if (Get-Member -InputObject $Global:DotfilesConfig -Name $Name -MemberType NoteProperty) {
        return $Global:DotfilesConfig.$Name
    } else {
        return $null
    }
}

function SaveConfig {
    ConvertTo-Json -InputObject $Global:DotfilesConfig | Out-File $Global:DotfilesConfigPath
}

function WriteConfig([string] $Name, [string] $Value) {
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
        $Path = @(
            "$HOME\AppData\Roaming\Composer\vendor\bin",
            'C:\php'
        )

        # [System.Environment]::SetEnvironmentVariable('Path', $Path -join ';')
    }
}
SetEnvironment

function Dotfiles {
    if ($IsOSX) {
        $os = 'macOS'
    } elseif ($IsWindows) {
        $os = 'Windows'
    } elseif ($IsLinux) {
        $os = 'Linux'
    } else {
        $os = 'unknown operation system'
    }
    Write-Host " Artevelde Dotfiles $Global:DotfilesVersion " -ForegroundColor Black -BackgroundColor DarkYellow -NoNewline
    $PSVersion = $PSVersionTable.GitCommitId # $PSVersionTable.PSVersion.ToString()
    Write-Host " on PowerShell $PSVersion for $os" -ForegroundColor DarkGray
}
New-Alias -Name dot -Value Dotfiles

# Install Functions

function InstallArtestead {
    Write-Host 'Installing Artestead (Artevelde Laravel Homestead)...'
    if (Get-Command vagrant -errorAction SilentlyContinue) {
        vagrant plugin install vagrant-hostsupdater
    }
    if (Get-Command cgr -errorAction SilentlyContinue) {
        cgr gdmgent/artestead
    }
}

function InstallBrew {
    Write-Host 'Using Ruby to install Homebrew...'
    sh -c 'ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"'
    Write-Host 'Installed version of Homebrew: ' -NoNewline
    brew --version
}


function InstallBundler {
    Write-Host 'Using Ruby Gem to install the Bundler Gem...'
    gem install bundler
    
    Write-Host 'Installed version of Bundler: ' -NoNewline
    bundler --version
}

function InstallComposer {
    if ($IsOSX) {
        Write-Host 'Using PHP to install Composer...'
        sh -c 'curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer'
        Write-Host 'Installed version of Composer: ' -NoNewline
        composer --version
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
    if (Get-Command composer -errorAction SilentlyContinue) {
        InstallComposer
    }
    composer global require consolidation/cgr
}

function InstallComposerPrestissimo {
    Write-Host 'Using Composer to install Prestissimo...'
    if (Get-Command composer -errorAction SilentlyContinue) {
        InstallComposer
    }
    composer global require hirak/prestissimo
}

function InstallGit {
    if ($IsOSX) {
        Write-Host 'Using Homebrew to install Git...'
        sh -c 'brew install git'
        Write-Host 'Installed version of Git: ' -NoNewline
        git --version
    } elseif ($IsWindows) {
        Write-Host 'Downloading Git installer...'
        $Version = 'v2.9.2.windows.1'
        $Urn = 'Git-2.9.2-64-bit.exe'
        $Uri = "https://github.com/git-for-windows/git/releases/download/$Version/$Urn"
        $InstallerFile = Join-Path -Path $env:TEMP -ChildPath $Urn
        Invoke-WebRequest -Uri $Uri -OutFile $InstallerFile
        if (Test-Path $InstallerFile) {
            Write-Host 'Running Git installer...'
            Invoke-Expression $InstallerFile
            Remove-Item $InstallerFile
        }
    }
}

function InstallGitIgnoreGlobal {
    if (Get-Command git -errorAction SilentlyContinue) {
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
        $Response = Invoke-RestMethod -Method Get -Uri https://api.github.com/repos/coreybutler/nvm-windows/releases?per_page=1
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
        $Url = 'http://windows.php.net/download'
        $RelativeUrl = ((Invoke-WebRequest –Uri $Url).Links | Where-Object { $_.href -match '/downloads/releases/php-7.0.\d+-nts-Win32-VC14-x64.zip' } | Select-Object -First 1).href
        $Uri = "$UrlRelativeUrl"
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
    if (Get-Command php -errorAction SilentlyContinue) {
        Write-Host 'Installed version of PHP: ' -NoNewline
        php -v
    }
}

# @TODO
function InstallPowerShell {
    $Response = Invoke-RestMethod -Method Get -Uri https://api.github.com/repos/powershell/powershell/releases?per_page=1
    $Version = $Response.tag_name
    Write-Host $Version
    if ($IsOSX) {
        $OS = '.pkg$'
        $Uri = ($Response.assets | Where-Object { $_.name -matches $OS }).browser_download_url
        $Urn = 'powershell.pkg'
        $InstallerFile = Join-Path -Path $env:TEMP -ChildPath $Urn
        Invoke-WebRequest -Uri $Uri -OutFile $InstallerFile

        Remove-Item -Path $InstallerFile
    } elseif ($IsWindows) {
        $OS = 'win10-x64.zip$'
        $Uri = ($Response.assets | Where-Object { $_.name -matches $OS }).browser_download_url
        $Urn = 'powershell-win10-x64.zip'
        $InstallerFile = Join-Path -Path $env:TMPDIR -ChildPath $Urn
        Invoke-WebRequest -Uri $Uri -OutFile $InstallerFile

        Remove-Item -Path $InstallerFile
    } elseif ($IsLinux) {
        $OS = 'ubuntu1.16.04.1_amd64.deb$'
        $Uri = ($Response.assets | Where-Object { $_.name -matches $OS }).browser_download_url
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
        $Uri = ((Invoke-WebRequest –Uri $Url).Links | Where-Object { $_.href -match "rubyinstaller-$Version-x64.exe$" } | Select-Object -First 1).href
        $Urn = "rubyinstaller.exe"
        $InstallerFile = Join-Path -Path $env:TEMP -ChildPath $Urn
        Invoke-WebRequest -Uri $Uri -OutFile $InstallerFile
        if (Test-Path $InstallerFile) {
            Write-Host 'Running Ruby installer...'
            Invoke-Expression $InstallerFile
            Remove-Item $InstallerFile
        }
        Write-Host 'Downloading Ruby DevKit installer...'
        $Version = 'mingw64-64'
        $Uri = ((Invoke-WebRequest –Uri $Url).Links | Where-Object { $_.href -match "DevKit-$Version-(\S+)-sfx.exe$" } | Select-Object -First 1).href
        $Urn = "DevKit-sfx.exe"
        $InstallerFile = Join-Path -Path $env:TEMP -ChildPath $Urn
        Invoke-WebRequest -Uri $Uri -OutFile $InstallerFile
        if (Test-Path $InstallerFile) {
            Write-Host 'Running Ruby DevKit installer...'
            Invoke-Expression $InstallerFile
            Remove-Item $InstallerFile
        }
    }
    if (Get-Command ruby -errorAction SilentlyContinue) {
        Write-Host 'Installed version of Ruby: ' -NoNewline
        ruby --version
        if (Get-Command gem -errorAction SilentlyContinue) {
            Write-Host 'Installed version of Gem: ' -NoNewline
            gem --version
        }
    } else {
        Write-Warning -Message 'Ruby is not correctly installed.'
    }
}

function InstallVisualStudioCode {
    if ($IsOSX) {
        $Path = '/usr/local/Cellar/openssl/1.0.2h_1/lib'
        $Destination = '/usr/local/lib'
        Copy-Item -Path $Path/libcrypto.dylib -Destination $Destination/libcrypto.1.0.0.dylib
        Copy-Item -Path $Path/libssl.dylib -Destination $Destination/libssl.1.0.0.dylib
    }
}

function RemoveLocalArtestead {
    $File = 'Artestead.yaml'
    if (Test-Path $File) {
        Write-Host 'Removing Local Artestead...'
        if (Test-Path Vagrantfile) {
            vagrant destroy
            Remove-Item -Path .vagrant -Recurse
            Remove-Item -Path Vagrantfile
        }
        Remove-Item -Path .gitignore
        Remove-Item -Path *.sh
        Remove-Item -Path composer.*
        Remove-Item -Path vendor -Recurse
        Remove-Item -Path $File
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
    sh -c 'ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/uninstall)"'
}

function UpdateBundler {
    $File = 'Gemfile'
    if (Test-Path $File) {
        if (Get-Command bundler -errorAction SilentlyContinue) {
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
        [switch]
        $Force
    )
    Write-Host 'Updating Homebrew...'
    if ($IsOSX -and (Get-Command brew -errorAction SilentlyContinue)) {
        if ($Force) {
            sh -c 'sudo chown -R $(whoami):admin /usr/local'
        }
        sh -c 'brew update && brew upgrade && brew cleanup'
    }
}

function UpdateComposer {
    Param(
        [switch]
        $Force
    )
    Write-Host 'Updating Composer and CGR installed packages...'
    if (Get-Command composer -errorAction SilentlyContinue) {
        composer self-update
        composer global update
        if (Get-Command cgr -errorAction SilentlyContinue) {
            $Packages                 = @{}
            $Packages['drush']        = 'drush/drush'
            $Packages['php-cs-fixer'] = 'friendsofphp/php-cs-fixer'
            $Packages['artestead']    = 'gdmgent/artestead'
            $Packages['laravel']      = 'laravel/installer'
            $Packages['psysh']        = 'psy/psysh'
            $Packages['symfony']      = 'symfony/symfony-installer'
            $Packages['wp']           = 'wp-cli/wp-cli'
            foreach ($Package in $Packages.GetEnumerator()) {
                if ($Force -or (Get-Command $Package.Key -errorAction SilentlyContinue)) {
                    cgr $Package.Value
                }
            }
        }
    } else {
        Write-Warning -Message 'Composer is not installed. Run InstallComposer or InstallComposerCgr.'
    }
}

function ShowDotCommands {
    Get-Command "$args" | Where-Object { $_.Source -eq 'dotfiles' }
    Get-Alias  "$args" | Where-Object { $_.Source -eq 'dotfiles' -or $_.Source -like 'aliases*' }
}

function UpdateSyllabi {
    Push-Location
    GoToPathSyllabi
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
        [string]
        $Syllabus
    )
    GoToPathSyllabi
    git clone https://github.com/gdmgent/$Syllabus
}

function X {
    exit
}