# import: . ./dotfiles.ps1

function SetEnvironment {
    if (TestMacOS) {
        $PATH = [System.Environment]::GetEnvironmentVariable("PATH")
        [System.Environment]::SetEnvironmentVariable("PATH", "/usr/local/bin:$PATH")
    
        # /Users/olivier/.nvm/versions/node/v4.5.0/bin:/Users/olivier/Code/dotfiles/scripts/sh:/Users/olivier/Library/Android/sdk/tools:/usr/local/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/Users/olivier/.composer/vendor/bin:/Users/olivier/.composer/vendor/bin
    }
}

function PrependPath {
    
}

# Test if operation system is Apple macOS 
function TestMacOS {
    if (Get-Command sw_vers -errorAction SilentlyContinue) {
        $os = sw_vers -productName
        return ($os -eq "macOS" -or $os -eq "Mac OS X")
    }
    return $false
}

# Test if operation system is Microsoft Windows 
function TestWindows {
    Write-Warning "Not implemented yet!"
}

# Node Version Manager
function nvm {
    Invoke-Expression "sh -c 'export NVM_DIR=~/.nvm && source $(brew --prefix nvm)/nvm.sh && nvm $args'"
}

function Dotfiles {
    Param(
        [String] $install,
        [String] $i,
        [String] $remove,
        [String] $r,
        [String] $update,
        [String] $u
    )
    $version = "4.0.0"
    if (TestMacOS) {
        $os = "macOS"
    } elseif (TestWindows) {
        $os = "Windows"
    } else {
        $os = "Linux"
    }
    Write-Output "Artevelde Dotfiles v$version for $os"

    if ($i) {
        $install = $i
    }

    if ($install) {
        switch ($install) {
            "test" {
                Write-Host "test"
            }
            Default {
                Write-Host "$intall is not installable"
            }
        }
    }
}
New-Alias -Name dot -Value Dotfiles

function InstallArtestead {
    Write-Host "Installing Artestead (Artevelde Laravel Homestead)"
    vagrant plugin install vagrant-hostsupdater
    # composer g require gdmgent/artestead
    cgr gdmgent/artestead
}

function InstallBrew {
    Write-Host "Installing Brew"
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
}

function InstallComposer {
    Write-Host "Installing Composer"
    if (TestMacOS) {
        curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
    } else {
        Write-Error "This is for macOS only."
    }
}

function InstallComposerCgr {
    Write-Host "Installing CGR (Composer Global Require)"
    if (Get-Command composer -errorAction SilentlyContinue) {
        InstallComposer
    }
    composer global require consolidation/cgr
}

function InstallComposerPrestissimo {
    Write-Host "Installing Prestissimo"
    if (Get-Command composer -errorAction SilentlyContinue) {
        InstallComposer
    }
    composer global require hirak/prestissimo
}

function InstallOhMyZsh {
    Write-Host "Installing Oh-My-Zsh"
    brew install zsh
    sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
}

function InstallPhp {
    Write-Host "Installing PHP 7.0"
    brew tap homebrew/php
    brew install php70 php70-mcrypt
}

function RemoveLocalArtestead {
    Write-Host "Removing Local Artestead"
    Get-ChildItem
}

function RemoveAndroidStudio {
    rm -Rf /Applications/Android\ Studio.app
    rm -Rf ~/Library/Preferences/AndroidStudio*
    rm ~/Library/Preferences/com.google.android.studio.plist
    rm -Rf ~/Library/Application\ Support/AndroidStudio*
    rm -Rf ~/Library/Logs/AndroidStudio*
    rm -Rf ~/Library/Caches/AndroidStudio*

    # Projects
    rm -Rf ~/AndroidStudioProjects

    # Gradle
    rm -Rf ~/.gradle

    # Android Virtual Devices
    rm -Rf ~/.android

    # Android SDK
    rm -Rf ~/Library/Android*
}

function RemoveBrew {
    Write-Host "Removing Homebrew"
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/uninstall)"
}

function UpdateBrew {
    Write-Host "Updating Homebrew"
    brew update
    brew upgrade
    brew cleanup
}

function UpdateComposer {
    Write-Host "Updating Composer and CGR installed packages"
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
        Write-Warning "Composer is not installed. Run InstallComposer or InstallComposerCgr."
    }
}