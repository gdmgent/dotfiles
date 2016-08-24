# import: . ./dotfiles.ps1

function SetEnvironment {
    if ($IsOSX) {
        $path = @(
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

        # # Write-Output ($path -join ':')
        # [System.Environment]::SetEnvironmentVariable('PATH', $path -join ':')

        # $PATH = [System.Environment]::GetEnvironmentVariable('PATH')
        # [System.Environment]::SetEnvironmentVariable("PATH", "/usr/local/bin:$PATH")
    
        # /Users/olivier/.nvm/versions/node/v4.5.0/bin
        # /Users/olivier/Code/dotfiles/scripts/sh
        # /Users/olivier/Library/Android/sdk/tools
        # /usr/local/sbin
        # /usr/local/bin
        # /usr/bin
        # /bin
        # /usr/sbin
        # /sbin
        # /Users/olivier/.composer/vendor/bin
        [System.Environment]::SetEnvironmentVariable('PATH', $path -join ':')
    } elseif ($IsWindows) {
        $path = @(
            "$HOME\AppData\Roaming\Composer\vendor\bin",
            'C:\php'
        )

        # [System.Environment]::SetEnvironmentVariable('Path', $path -join ';')
    }
}
SetEnvironment

# Node Version Manager
# function nvm {
#     Invoke-Expression "sh -c 'export NVM_DIR=~/.nvm && source $(brew --prefix nvm)/nvm.sh && nvm $args'"
# }

function Dotfiles {
    $version = '4.0.0-alpha2'
    if ($IsOSX) {
        $os = 'macOS'
    } elseif ($IsWindows) {
        $os = 'Windows'
    } elseif ($IsLinux) {
        $os = 'Linux'
    } else {
        $os = 'unknown operation system'
    }
    Write-Host " Artevelde Dotfiles v$version " -ForegroundColor Black -BackgroundColor DarkYellow -NoNewline
    Write-Host " on PowerShell for $os" -ForegroundColor DarkGray
}
New-Alias -Name dot -Value Dotfiles

function InstallArtestead {
    Write-Host 'Installing Artestead (Artevelde Laravel Homestead)...'
    vagrant plugin install vagrant-hostsupdater
    cgr gdmgent/artestead
}

function InstallBrew {
    Write-Host 'Installing Homebrew...'
    sh -c 'ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"'
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
    Write-Host 'Installing Node Version Manager...'
    if ($IsOSX) {
        sh -c 'brew install nvm'
    } elseif ($IsWindows) {
        
    }
}
New-Alias -Name node -Value Node
function UseNode4 {
    UseNode -Version 4.5.0
}

function UseNode6 {
    UseNode -Version 6.4.0
}

function UseNode([string] $Version) {
    $env:PATH = @("$HOME/.nvm/versions/node/v$Version/bin", $env:PATH) -join ':'
    Set-Alias -Name node -Value $(Get-Command -Name node -Type Application | Select-Object -First 1).Source -Scope Global
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
    Write-Host 'Removing Local Artestead...'
    Get-ChildItem
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
    if ((Test-Path $file)) {
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