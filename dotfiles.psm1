# import: . ./dotfiles.ps1

function SetEnvironment {
    if ($IsOSX) {
        $path = @(
            # first
            "$HOME/.nvm/versions/node/v4.5.0/bin",
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
function nvm {
    Invoke-Expression "sh -c 'export NVM_DIR=~/.nvm && source $(brew --prefix nvm)/nvm.sh && nvm $args'"
}

function Dotfiles {
    $version = '4.0.0-alpha1'
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
    # composer g require gdmgent/artestead
    cgr gdmgent/artestead
}

function InstallBrew {
    Write-Host 'Installing Brew...'
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
}

function InstallBundler {

}

function InstallComposer {
    Write-Host 'Installing Composer...'
    if ($IsOSX) {
        curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
    } else {
        Write-Warning -Message 'This is for macOS only.'
    }
}

function InstallComposerCgr {
    Write-Host 'Installing CGR (Composer Global Require)...'
    if (Get-Command composer -errorAction SilentlyContinue) {
        InstallComposer
    }
    composer global require consolidation/cgr
}

function InstallComposerPrestissimo {
    Write-Host 'Installing Prestissimo...'
    if (Get-Command composer -errorAction SilentlyContinue) {
        InstallComposer
    }
    composer global require hirak/prestissimo
}

function InstallOhMyZsh {
    Write-Host 'Installing Oh-My-Zsh...'
    if ($IsOSX) {
        brew install zsh
        sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
    } else {
        Write-Warning -Message 'This is for macOS only.'
    }
}

function InstallPhp {
    Write-Host 'Installing PHP 7.0...'
    if ($IsOSX) {
        brew tap homebrew/php
        brew install php70 php70-mcrypt
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

function RemoveBrew {
    Write-Host 'Removing Homebrew...'
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/uninstall)"
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
        brew update
        brew upgrade
        brew cleanup
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

# function NodeVersionManager {
#     Write-Host 'Alias for nvm'
#     nvm
#     zie https://github.com/aaronpowell/ps-nvmw
# }
# New-Alias -Name dotnvm -Value NodeVersionManager

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