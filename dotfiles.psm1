# import: . ./dotfiles.ps1

function InitConfig {
    $Global:DotfilesConfigPath = "$HOME/.dotfiles/config.json"
    if (Test-Path $Global:DotfilesConfigPath) {
        Write-Host 'Reading config file...'
        $Global:DotfilesConfig = Get-Content -Raw -Path $Global:DotfilesConfigPath | ConvertFrom-Json
    } else {
        Write-Host 'Creating a new config file...'
        New-Item -Path $Global:DotfilesConfigPath -Force
        $Global:DotfilesConfig = New-Object -TypeName PSObject
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
        $Path = @(
            # first
            "$HOME/Library/Android/sdk/tools",

            # user
            '/usr/local/bin',
            '/usr/bin',
            '/bin',

            # superuser
            '/usr/local/sbin',
            '/usr/sbin',
            '/sbin'

            # last
            "$HOME/.composer/vendor/bin"
        )
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
    $DotfilesVersion = Get-Content "${Global:DotfilesInstallPath}/VERSION" | select -First 1 -Skip 1
    if ($IsOSX) {
        $os = 'macOS'
    } elseif ($IsWindows) {
        $os = 'Windows'
    } elseif ($IsLinux) {
        $os = 'Linux'
    } else {
        $os = 'unknown operation system'
    }
    Write-Host " Artevelde Dotfiles $DotfilesVersion " -ForegroundColor Black -BackgroundColor DarkYellow -NoNewline
    $PSVersion = $PSVersionTable.GitCommitId # $PSVersionTable.PSVersion.ToString()
    Write-Host " on PowerShell $PSVersion for $os" -ForegroundColor DarkGray
}
New-Alias -Name dot -Value Dotfiles

function InstallArtestead {
    Write-Host 'Installing Artestead (Artevelde Laravel Homestead)...'
    vagrant plugin install vagrant-hostsupdater
    cgr gdmgent/artestead
}

function InstallBrew {
    Write-Host 'Using Ruby to install Homebrew...'
    sh -c 'ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"'
    Write-Host 'Installed version of Homebrew: ' -NoNewline
    brew --version
}

function InstallRuby {
    Write-Host 'Using Homebrew to install Ruby...'
    sh -c 'brew install ruby'
    Write-Host 'Installed version of Ruby: ' -NoNewline
    ruby --version
    Write-Host 'Installed version of Gem: ' -NoNewline
    gem --version
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
    } else {
        Write-Warning -Message 'This is for macOS only.'
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
    Write-Host 'Using Homebrew to install Git...'
    sh -c 'brew install git'
    Write-Host 'Installed version of Git: ' -NoNewline
    git --version
}

function InstallNvm {
    if ($IsOSX) {
        Write-Host 'Using Homebrew to install Node Version Manager...'
        sh -c 'brew install nvm'
        Write-Host 'Installed version of NVM: ' -NoNewline
        nvm --version
    } elseif ($IsWindows) {
        
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
        Write-Host 'Installed version of PHP: ' -NoNewline
        php -v
    } else {
        Write-Warning -Message 'This is for macOS only.'
    }
}

function RemoveLocalArtestead {
    $file = 'Artestead.yaml'
    if (Test-Path $file) {
        Write-Host 'Removing Local Artestead...'
        Get-Command artestead
    } else {
        Write-Warning -Message "This is not an Artestead project. Could not find '$file' in this directory."
    }

}

function RemoveAndroidStudio {
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

function UninstallBrew {
    Write-Host 'Using Ruby to uninstall Homebrew...'
    sh -c 'ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/uninstall)"'
}

function UpdateBundler {
    $file = 'Gemfile'
    if (Test-Path $file) {
        if (Get-Command bundler -errorAction SilentlyContinue) {
            bundler update
            gem cleanup
        } else {
            Write-Warning -Message 'Bundler Ruby Gem is not installed. Run InstallBundler.'
        }
    } else {
        Write-Warning -Message "Cannot run Bundler in this directory because a '$file' is required."
    }
}

function UpdateBrew {
    Write-Host 'Updating Homebrew...'
    if ($IsOSX -and (Get-Command brew -errorAction SilentlyContinue)) {
        sh -c 'sudo chown -R $(whoami):admin /usr/local'
        sh -c 'brew update && brew upgrade && brew cleanup'
    }
}

function UpdateComposer {
    Write-Host 'Updating Composer and CGR installed packages...'
    if (Get-Command composer -errorAction SilentlyContinue) {
        composer self-update
        composer global update
        if (Get-Command cgr -errorAction SilentlyContinue) {
            $packages = @{}
            $packages["drush"]        = "drush/drush"
            $packages["php-cs-fixer"] = "friendsofphp/php-cs-fixer"
            $packages["artestead"]    = "gdmgent/artestead"
            $packages["laravel"]      = "laravel/installer"
            $packages["psysh"]        = "psy/psysh"
            $packages["symfony"]      = "symfony/symfony-installer"
            $packages["wp"]           = "wp-cli/wp-cli"
            foreach ($package in $packages.GetEnumerator()) {
                if (Get-Command $package.Key -errorAction SilentlyContinue) {
                    cgr $package.Value
                }
            }
        }
    } else {
        Write-Warning -Message 'Composer is not installed. Run InstallComposer or InstallComposerCgr.'
    }
}

function ShowDotCommands {
    Get-Command "$args" | Where-Object {$_.Source -eq 'dotfiles'}
    Get-Alias  "$args" | Where-Object {$_.Source -eq 'dotfiles' -or $_.Source -like 'aliases*'}
}

function UpdateSyllabi {
    Push-Location
    GoToPathSyllabi
    $directories = Get-ChildItem -Directory -Name | Where-Object {$_ -match '^((\d{4}|utl|mod)_)'}

    foreach ($directory in $directories) {
        Push-Location $directory
        if (Test-Path .git) {
            Write-Host " $directory " -BackgroundColor Blue -ForegroundColor White
            git pull | Write-Host -ForegroundColor DarkGray
        }
        Pop-Location
    }
    Pop-Location
}

function CloneSyllabus {
    Param(
        [string]
        $syllabus
    )
    s
    git clone https://github.com/gdmgent/$syllabus
}