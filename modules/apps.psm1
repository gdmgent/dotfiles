function Installers {
    Get-Command -Name Install* -CommandType Function | Where-Object { $_.Source -eq 'apps' -and $_.Name -ne 'Installers' } | Format-Table -Property Name
}
New-Alias -Name install -Value Installers

function Removers {
    Get-Command -Name Remove* -CommandType Function | Where-Object { $_.Source -eq 'apps' -and $_.Name -ne 'Removers' } | Format-Table -Property Name
}
New-Alias -Name remove -Value Removers

function Uninstallers {
    Get-Command -Name Uninstall* -CommandType Function | Where-Object { $_.Source -eq 'apps' -and $_.Name -ne 'Uninstallers' } | Format-Table -Property Name
}
New-Alias -Name uninstall -Value Uninstallers

function Updaters {
    Get-Command -Name Update* -CommandType Function | Where-Object { $_.Source -eq 'apps' -and $_.Name -ne 'Updaters' } | Format-Table -Property Name
}
New-Alias -Name update -Value Updaters

# Install Functions
# -----------------
function InstallArtestead {
    WriteMessage -Type Info -Inverse -Message 'Installing Artestead (Artevelde Laravel Homestead)...'
    if (ExistCommand -Name vagrant) {
        vagrant plugin install vagrant-hostsupdater
    }
    if (ExistCommand -Name cgr) {
        ComposerGlobalRequire gdmgent/artestead
    } else {
        WriteMessage -Type Warning -Message 'Run InstallComposerCgr and try again.'
    }
}

if ($IsMacOS) {
    function InstallBrew {
        WriteMessage -Type Info -Inverse -Message 'Installing Homebrew'
        WriteMessage -Type Info -Message 'Using Ruby to install Homebrew...'
        sh -c 'ruby -e \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)\"'
        if (ExistCommand -Name brew) {
            WriteMessage -Type Success -Message 'Installed version of Homebrew: ' -NoNewline
            brew --version
        } else {
            WriteMessage -Type Danger -Message 'Homebrew was not installed.'
        }
    }
}

function InstallBundler {
    WriteMessage -Type Info -Inverse -Message 'Installing Bundler'
    WriteMessage -Type Info -Message 'Using Ruby Gem to install the Bundler Gem...'
    gem install bundler
    if (ExistCommand -Name bundle) {
        WriteMessage -Type Success -Message 'Installed version of Bundler: ' -NoNewline
        bundle --version
    } else {
        WriteMessage -Type Danger -Message 'Bundler was not installed.'
    }
}

function InstallComposer {
    WriteMessage -Type Info -Inverse -Message 'Installing Composer'
    if ($IsMacOS) {
        WriteMessage -Type Info -Message 'Using PHP to install Composer...'
        sh -c 'curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer'
    } elseif ($IsWindows) {
        WriteMessage -Type Info -Message 'Using Scoop to install Composer...'
        cmd /c 'scoop install composer'
    }
    if (ExistCommand -Name composer) {
        WriteMessage -Type Success -Message 'Installed version of Composer: ' -NoNewline
        composer --version
    } else {
        WriteMessage -Type Danger -Message 'Composer was not installed.'
    }
}

function InstallComposerCgr {
    WriteMessage -Type Info -Inverse -Message 'Installing CGR (Composer Global Require)'
    WriteMessage -Type Info -Message 'Using Composer to install CGR ...'
    if (! (ExistCommand -Name composer)) {
        InstallComposer
    }
    composer global require consolidation/cgr
    if (ExistCommand -Name cgr) {
        WriteMessage -Type Success -Message 'CGR is installed.'
    } else {
        WriteMessage -Type Danger -Message  'CGR was not installed.'
    }
}

function InstallComposerPrestissimo {
    WriteMessage -Type Info -Inverse -Message 'Installing Prestissimo'
    WriteMessage -Type Info -Message 'Using Composer to install Prestissimo...'
    if (! (ExistCommand -Name composer)) {
        InstallComposer
    }
    composer global require hirak/prestissimo
}

function InstallCustomDotfilesPowerShellModule {
    WriteMessage -Type Info -Inverse -Message 'Installing Custom Dotfiles PowerShell Module'
    $CustomModule = [io.path]::Combine($DotfilesInstallPath, 'settings', 'custom.psm1')
    $CustomModuleDestination = [io.path]::Combine($HOME, '.dotfiles', 'custom.psm1')
    if (! (Test-Path -Path $CustomModuleDestination)) {
        WriteMessage -Type Info -Message 'Copying file...'
        Copy-Item -Path $CustomModule -Destination $CustomModuleDestination
    } else {
        WriteMessage -Type Warning -Message 'Custom Dotfiles PowerShell Module already installed.'
    }
}

function InstallFontFiraCode {
    WriteMessage -Type Info -Inverse -Message 'Installing Fira Code typeface by Nikita Prokopov'
    WriteMessage -Type Info -Message 'Downloading Fira Code typeface ...'
    $Response = Invoke-RestMethod -Method Get -Uri https://api.github.com/repos/tonsky/FiraCode/releases/latest
    $FontFormat = 'otf'
    $Name = 'FiraCode'
    $Urn = "${Name}.zip"
    $Uri = $Response.assets.browser_download_url
    if ($IsMacOS) {
        $OutFile = Join-Path -Path $env:TMPDIR -ChildPath $Urn
        Invoke-WebRequest -Uri $Uri -OutFile $OutFile
        if (Test-Path -Path $OutFile) {
            WriteMessage -Type Info -Message 'Installing Fira Code typeface...'
            $DestinationPath = "${HOME}/Library/Fonts/"
            $TempPath = "${env:TMPDIR}${Name}/"
            $output = unzip $OutFile **/*.$FontFormat -d $TempPath -o
            Remove-Item -Path $OutFile
            Move-Item -Path ${TempPath}${FontFormat}/*.${FontFormat} -Destination $DestinationPath -Force
            Remove-Item -Path $TempPath -Recurse -Force
        }
    } elseif ($IsWindows) {
        $OutFile = Join-Path -Path $env:TEMP -ChildPath $Urn
        Invoke-WebRequest -Uri $Uri -OutFile $OutFile
        if (Test-Path -Path $OutFile) {
            WriteMessage -Type Info -Message 'Installing Fira Code typeface...'
            $DestinationPath = "C:\Windows\Fonts\"
            $TempPath = "${env:TEMP}${Name}\"
            Expand-Archive -Path $OutFile -DestinationPath $TempPath -Force
            Remove-Item -Path $OutFile
            $Output = Get-ChildItem -Path ${TempPath}${FontFormat}\*.${FontFormat} | Select-Object { (New-Object -ComObject Shell.Application).Namespace(0x14).CopyHere($_.FullName) }
            Remove-Item -Path $TempPath -Recurse -Force
        }
    }
}

function InstallFontHack {
    WriteMessage -Type Info -Inverse -Message 'Installing Hack typeface by Chris Simpkins'
    WriteMessage -Type Info -Message 'Downloading Hack typeface'
    $FontFormat = 'ttf'
    $Response = Invoke-RestMethod -Method Get -Uri https://api.github.com/repos/source-foundry/Hack/releases/latest
    $Name = 'Hack'
    $Urn = "${Name}.zip"
    $Uri = ($Response.assets | Where-Object { $_.name -match "^Hack-(.+)-${FontFormat}.zip$" }).browser_download_url
    if ($IsMacOS) {
        $OutFile = Join-Path -Path $env:TMPDIR -ChildPath $Urn
        Invoke-WebRequest -Uri $Uri -OutFile $OutFile
        if (Test-Path -Path $OutFile) {
            WriteMessage -Type Info -Message 'Installing Hack typeface...'
            $DestinationPath = "${HOME}/Library/Fonts/"
            $TempPath = "${env:TMPDIR}${Name}/"
            $output = unzip $OutFile *.${FontFormat} -d $TempPath -o
            Remove-Item -Path $OutFile
            Move-Item -Path ${TempPath}*.${FontFormat} -Destination $DestinationPath -Force
            Remove-Item -Path $TempPath -Recurse -Force
        }
    } elseif ($IsWindows) {
        $OutFile = Join-Path -Path $env:TEMP -ChildPath $Urn
        Invoke-WebRequest -Uri $Uri -OutFile $OutFile
        if (Test-Path -Path $OutFile) {
            WriteMessage -Type Info -Message 'Installing Hack typeface...'
            $DestinationPath = "C:\Windows\Fonts\"
            $TempPath = "${env:TEMP}${Name}\"
            Expand-Archive -Path $OutFile -DestinationPath $TempPath -Force
            Remove-Item -Path $OutFile
            $Output = Get-ChildItem -Path ${TempPath}*.${FontFormat} | Select-Object { (New-Object -ComObject Shell.Application).Namespace(0x14).CopyHere($_.FullName) }
            Remove-Item -Path $TempPath -Recurse -Force
        }
    }
}

function InstallFontHasklig {
    WriteMessage -Type Info -Inverse -Message 'Installing Hasklig typeface by Ian Tuomi...'
    WriteMessage -Type Info -Message 'Downloading Hasklig typeface...'
    $FontFormat = 'otf'
    $Response = Invoke-RestMethod -Method Get -Uri https://api.github.com/repos/i-tu/Hasklig/releases?per_page=1
    # $Response = Invoke-RestMethod -Method Get -Uri https://api.github.com/repos/i-tu/Hasklig/releases/latest
    $Name = 'Hasklig'
    $Urn = "${Name}.zip"
    $Uri = $Response.assets.browser_download_url
    if ($IsMacOS) {
        $OutFile = Join-Path -Path $env:TMPDIR -ChildPath $Urn
        Invoke-WebRequest -Uri $Uri -OutFile $OutFile
        if (Test-Path -Path $OutFile) {
            WriteMessage -Type Info -Message 'Installing Hasklig typeface...'
            $DestinationPath = "${HOME}/Library/Fonts/"
            $TempPath = "${env:TMPDIR}${Name}/"
            $output = unzip $OutFile *.otf -d $TempPath -o
            Remove-Item -Path $OutFile
            Move-Item -Path ${TempPath}*.otf -Destination $DestinationPath -Force
            Remove-Item -Path $TempPath -Recurse -Force
        }
    } elseif ($IsWindows) {
        $OutFile = Join-Path -Path $env:TEMP -ChildPath $Urn
        Invoke-WebRequest -Uri $Uri -OutFile $OutFile
        if (Test-Path -Path $OutFile) {
            WriteMessage -Type Info -Message 'Installing Hasklig typeface...'
            $DestinationPath = "C:\Windows\Fonts\"
            $TempPath = "${env:TEMP}${Name}\"
            Expand-Archive -Path $OutFile -DestinationPath $TempPath -Force
            Remove-Item -Path $OutFile
            $Output = Get-ChildItem -Path "${TempPath}*.${FontFormat}" | Select-Object { (New-Object -ComObject Shell.Application).Namespace(0x14).CopyHere($_.FullName) }
            Remove-Item -Path $TempPath -Recurse -Force
        }
    }
}

function InstallGit {
    WriteMessage -Type Info -Inverse -Message 'Installing Git'
    if ($IsMacOS) {
        WriteMessage -Type Info -Message 'Using Homebrew to install Git...'
        sh -c 'brew install git'
    } elseif ($IsWindows) {
        WriteMessage -Type Info -Message 'Using Scoop to install Git...'
        cmd /c 'scoop install git'
    }
    if (ExistCommand -Name git) {
        if ($IsWindows) {
            git config --global credential.helper wincred
        }
        WriteMessage -Type Success -Message 'Installed version of Git: ' -NoNewline
        git --version
    } else {
        WriteMessage -Type Danger -Message 'Git was not installed.'
    }
}

function InstallGitIgnoreGlobal {
    if (! (ExistCommand -Name git)) {
        InstallGit
    }
    WriteMessage -Type Info -Inverse -Message 'Installing GitIgnore Global'
    $GitIgnoreSource = Join-Path -Path $Global:DotfilesInstallPath -ChildPath 'preferences' | Join-Path -ChildPath 'gitignore_global'
    git config --global core.excludesfile $GitIgnoreSource
}

function InstallHotel {
    WriteMessage -Type Info -Inverse -Message 'Installing Hotel'
    if (! (ExistCommand -Name yarn)) {
        InstallYarn
    }
    yarn global add hotel
    if (ExistCommand -Name hotel) {
        WriteMessage -Type Success -Message 'Installed version of Hotel: ' -NoNewline
        hotel --version
    } else {
        WriteMessage -Type Danger -Message 'Hotel was not installed.'
    }
}

function InstallHyperPreferences {
    WriteMessage -Type Info -Inverse -Message 'Installing Hyper.js preferences'
    $AppName = 'pwsh'
    $FileName = '.hyper.js'
    $SourcePath = Join-Path -Path $Global:DotfilesInstallPath -ChildPath 'preferences' | Join-Path -ChildPath $FileName
    $DestinationPath = Join-Path -Path $HOME -ChildPath $FileName
    if ($IsMacOS) {
        $Command = (Get-Command -Name $AppName -CommandType Application).Source
    } elseif ($IsWindows) {
        $Command = (Get-Command -Name $AppName -CommandType Application | Where-Object { $_.Source -match '6.\d+.\d+' } | Select-Object -First 1).Source -replace '\\', '\\' # replaces \ with \\
    }
    Copy-Item -Path $SourcePath -Destination $DestinationPath
    $FileContent = (Get-Content -Path $DestinationPath).Replace("shell: '${AppName}',", "shell: '${Command}',")
    Set-Content -Path $DestinationPath -Value $FileContent
}

function InstallNvm {
    WriteMessage -Type Info -Inverse -Message 'Installing NVM (Node Version Manager)'
    if ($IsMacOS) {
        WriteMessage -Type Info -Message 'Using Homebrew to install NVM...'
        sh -c 'brew install nvm'
    } elseif ($IsWindows) {
        WriteMessage -Type Info -Message 'Using Scoop to install NVM...'
        cmd /c 'scoop install nvm'
    }
    WriteMessage -Type Success -Message 'Installed version of NVM: ' -NoNewline
    if ($IsMacOS) {
        nvm --version
    } elseif ($IsWindows) {
        nvm version
    }
}

function InstallMySQL {
    WriteMessage -Type Info -Inverse -Message 'Installing MySQL Server'
    if ($IsMacOS) {
        WriteMessage -Type Info -Message 'Using Homebrew to install MySQL Server...'
        sh -c 'brew install mysql'
        if (ExistCommand -Name mysql) {
            sh -c 'brew services start mysql'
            sh -c "$(brew --prefix mysql)/bin/mysqladmin -u root password secret"
            WriteMessage -Type Warning -Inverse -Message 'Open a new PowerShell window or tab to activate the MySQL commands.'
        } else { 
            WriteMessage -Type Danger -Inverse -Message 'MySQL was not correctly installed.'
        }
    } elseif ($IsWindows) {
        WriteMessage -Type Info -Message 'Using the MySQL Installer to install MySQL Server...'
        WriteMessage -Type Warning -Inverse -Message 'set "root" password to "secret"'
        OpenUri -Uri https://dev.mysql.com/downloads/installer/
        WriteMessage -Type Warning -Inverse -Message 'Open a new PowerShell window or tab once MySQL is installed to activate the MySQL commands.'
    }
}

function InstallNginx {
    WriteMessage -Type Info -Inverse -Message 'Installing NGINX'
    if ($IsMacOS) {
        WriteMessage -Type Info -Message 'Using Homebrew to install NGINX...'
        sh -c 'brew install nginx --devel'
    } elseif ($IsWindows) {
        WriteMessage -Type Info -Message 'Using Scoop to install NGINX...'
        cmd /c 'scoop install nginx'
    }
    WriteMessage -Type Info -Message 'Configuring NGINX...'
    $FileName = 'nginx.conf'
    $SourcePath = [io.path]::Combine($HOME, 'dotfiles', 'settings', $FileName)
    $DestinationPath = [io.path]::Combine($HOME, '.dotfiles', $FileName)
    Copy-Item -Path $SourcePath -Destination $DestinationPath
    if ($IsMacOS) {
        # $NginxConfigDirectory = (brew --prefix nginx) + '/.bottle/etc/nginx'
        $NginxConfigDirectory = '/usr/local/etc/nginx'
    } else {
        $NginxConfigDirectory = "${HOME}/scoop/apps/nginx/current/conf".replace('\', '/')
    }
    $FileContent = (Get-Content -Path $DestinationPath).Replace('»NGINX-CONFIG-DIRECTORY«', $NginxConfigDirectory)
    Set-Content -Path $DestinationPath -Value $FileContent
    if (ExistCommand -Name nginx) {
        WriteMessage -Type Success 'Installed version of NGINX: ' -NoNewline
        nginx -v
    } else {
        WriteMessage -Type Danger -Message 'NGINX is not correctly installed.'
    }
}

if ($IsMacOS) {
    function InstallOhMyZsh {
        WriteMessage -Type Info -Inverse -Message 'Installing OhMyZsh'
        WriteMessage -Type Info -Message 'Using Homebrew to install Zsh...'
        sh -c 'brew install zsh'
        WriteMessage -Type Success -Message 'Installed version of Zsh: ' -NoNewline
        zsh --version
        WriteMessage -Type Info -Message 'Using Bash to install Oh-My-Zsh...'
        sh -c '$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)'
    }
}

function InstallPhp {
    $Version = '7.2'
    $V = $Version.replace('.', '')
    WriteMessage -Type Info -Inverse -Message "Installing PHP ${Version}"
    if ($IsMacOS) {
        WriteMessage -Type Info -Message "Using Homebrew to install PHP ${Version}..."
        sh -c "brew tap homebrew/php && brew install php${V} --with-argon2 && brew install php${V}-opcache"
        # $ConfigFilePath = "/usr/local/etc/php/${Version}/conf.d/ext-xdebug.ini"
        # if (Test-Path -Path $ConfigFilePath) {
        #     $ConfigFile = Get-Content -Path $ConfigFilePath
        #     if (! [bool]($ConfigFile -match "xdebug.remote_enable")) {
        #         Add-Content -Path $ConfigFilePath -Value "`nxdebug.remote_enable=1"
        #     }
        # }
    } elseif ($IsWindows) {
        WriteMessage -Type Info -Message "Downloading PHP ${Version}..."
        $Url =  'http://windows.php.net'
        $File = "/php-${Version}.\d+-nts-Win32-VC15-x64.zip$"
        $FileUri = "${Url}/downloads/releases"
        $RelativeUri = ((Invoke-WebRequest -Uri $FileUri).Links | Where-Object { $_.href -match $File } | Select-Object -First 1).href
        $Uri = "$Url$RelativeUri"
        $OutFile = Join-Path -Path $env:TEMP -ChildPath 'php.zip'
        Invoke-WebRequest -Uri $Uri -OutFile $OutFile
        if (Test-Path -Path $OutFile) {
            $DestinationPath = 'C:\php'
            if ((Test-Path -Path $DestinationPath) -and ! (Test-Path -Path "${DestinationPath}.bak")) {
                WriteMessage -Type Info -Message "Making a backup of previously installed version..."
                Move-Item -Path $DestinationPath -Destination "${DestinationPath}.bak"
            }
            WriteMessage -Type Info -Message 'Installing PHP...'
            Expand-Archive -Path $OutFile -DestinationPath $DestinationPath -Force
            Remove-Item -Path $OutFile
            WriteMessage -Type Info -Message 'Configuring PHP...'
            $ConfigFile = Get-Content -Path C:\php\php.ini-development
            $Extensions = @(
                'extension=curl',
                'extension=gd2',
                'extension=mbstring',
                'extension=openssl',
                'extension=pdo_mysql',
                'extension=pdo_sqlite',
                'extension=sqlite3'
            )
            foreach ($Extension in $Extensions) {
                $ConfigFile = $ConfigFile.Replace(";${Extension}", $Extension)
            }
            $Settings = @(
                @('max_execution_time = 30', 'max_execution_time = 999'),
                @('max_input_time = 60', 'max_input_time = -1'),
                @('memory_limit = 128M', 'memory_limit = 256M'),
                @(';opcache.enable=1', 'opcache.enable=1'),
                @(';opcache.enable_cli=1', 'opcache.enable_cli=1'),
                @(';opcache.memory_consumption=128', 'opcache.memory_consumption=128'),
                @(';opcache.interned_strings_buffer=8', 'opcache.interned_strings_buffer=8'),
                @(';opcache.max_wasted_percentage=5', 'opcache.max_wasted_percentage=5'),
                @(';opcache.use_cwd=1', 'opcache.use_cwd=1')
            )
            foreach ($Setting in $Settings) {
                $ConfigFile = $ConfigFile.Replace($Setting[0], $Setting[1])
            }
            # Adding CA Root Certificates for SSL
            $ConfigFile = $ConfigFile.Replace(';openssl.cafile=', 'openssl.cafile=' + $Global:DotfilesInstallPath + '\ssl\cacert.pem')
            Set-Content -Path ($ConfigFilePath = Join-Path -Path $DestinationPath -ChildPath 'php.ini') -Value $ConfigFile
            WriteMessage -Type Info 'Configuring PHP to use Sodium...'
            Add-Content -Path $ConfigFilePath -Value "`nextension=sodium"
            # OPcache
            WriteMessage -Type Info 'Configuring PHP to use OPcache...'
            Add-Content -Path $ConfigFilePath -Value "`nzend_extension=opcache"
            # Xdebug
            # WriteMessage -Type Info -Message 'Downloading Xdebug for PHP...'
            # $Url = 'https://xdebug.org'
            # $RelativeUrl = ((Invoke-WebRequest -Uri "${Url}/download.php").Links | Where-Object { $_.href -match "/php_xdebug-\d.\d.\d-${Version}-vc14-nts-x86_64.dll$" } | Select-Object -First 1).href
            # $Uri = "${Url}/${RelativeUrl}"
            # $OutFile = 'C:\php\ext\php_xdebug.dll'
            # Invoke-WebRequest -Uri $Uri -OutFile $OutFile
            # WriteMessage -Type Info -Message 'Configuring PHP to use Xdebug...'
            # Add-Content -Path $ConfigFilePath -Value "`nzend_extension=C:\php\ext\php_xdebug.dll"
        }
    }
}

function InstallPowerShell {
    WriteMessage -Type Info -Inverse -Message 'Installing PowerShell...'
    $Response = Invoke-RestMethod -Method Get -Uri https://api.github.com/repos/powershell/powershell/releases/latest
    $Version = $Response.tag_name
    if ($IsMacOS) {
        WriteMessage -Type Info -Message 'Using Homebrew to install PowerShell...'
        sh -c 'brew cask install powershell'
    } elseif ($IsWindows) {
        $OS = 'win10-win2016-x64.msi$'
        $Uri = ($Response.assets | Where-Object { $_.name -match $OS }).browser_download_url
        $Urn = 'powershell-win10-x64.msi'
        $InstallerFile = Join-Path -Path $env:TEMP -ChildPath $Urn
        Invoke-WebRequest -Uri $Uri -OutFile $InstallerFile
        if (Test-Path -Path $InstallerFile) {
            WriteMessage -Type Info -Message "Installing PowerShell ${Version}..."
            WriteMessage -Type Warning -Inverse -Message ' - [Next]'
            WriteMessage -Type Warning -Inverse -Message " - 'I accept the terms in the License Agreement', [next]"
            WriteMessage -Type Warning -Inverse -Message " - 'C:\Program Files\PowerShell\', [Next]"
            WriteMessage -Type Warning -Inverse -Message ' - [Finish]'
            WriteMessage -Type Warning -Inverse -Message 'Run InstallHyperPreferences and reopen Hyper'
            Start-Process -FilePath 'msiexec.exe' -ArgumentList "/i ${InstallerFile}" -Wait
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

function InstallCmake {
    WriteMessage -Type Info -Inverse -Message 'Installing CMake'
    if ($IsMacOS) {
        WriteMessage -Type Info -Message 'Using Homebrew to install CMake...'
        if (ExistCommand -Name brew) {
            sh -c 'brew install cmake'
        }
    } elseif ($IsWindows) {
        WriteMessage -Type Info -Message 'Using Scoop to install CMake...'
        if (ExistCommand -Name scoop) {
            cmd /c 'scoop install cmake'
        }
    }
}

function InstallRuby {
    WriteMessage -Type Info -Inverse -Message 'Installing Ruby'
    InstallCmake
    if ($IsMacOS) {
        WriteMessage -Type Info -Message 'Using Homebrew to install Ruby...'
        if (ExistCommand -Name brew) {
            sh -c 'brew install ruby'
        }
    } elseif ($IsWindows) {
        WriteMessage -Type Info -Message 'Using Scoop to install Ruby...'
        if (ExistCommand -Name scoop) {
            cmd /c 'scoop install ruby'
        }
    }
    if (ExistCommand -Name ruby) {
        WriteMessage -Type Success -Message 'Installed version of Ruby: ' -NoNewline
        ruby --version
        if (ExistCommand -Name gem) {
            WriteMessage -Type Success -Message 'Installed version of Gem: ' -NoNewline
            gem --version
        }
    } else {
        WriteMessage -Type Danger -Message 'Ruby is not correctly installed.'
    }
}

if ($IsWindows) {
    function InstallRubyDevKit {
        if (ExistCommand -Name ruby) {
            WriteMessage -Type Info -Inverse -Message 'Installing Ruby DevKit...'
            ridk install
        } else {
            WriteMessage -Type Danger -Message 'Ruby is not correctly installed.'
        }
    }
}

if ($IsWindows) {
    function InstallScoop {
        WriteMessage -Type Info -Inverse -Message 'Installing Scoop...'
        iex (new-object net.webclient).downloadstring('https://get.scoop.sh')
        if (ExistCommand -Name scoop) {
            cmd /c 'scoop bucket add extras'
        }
    }
}

if ($IsWindows) {
    function InstallUbuntu {
        WriteMessage -Type Info -Inverse -Message 'Installing Ubuntu Bash for Windows...'
        LxRun.exe /install /y
    }
}

if ($IsMacOS) {
    function InstallValet {
        WriteMessage -Type Info -Inverse -Message 'Using CGR to install Laravel Valet...'
        ComposerGlobalRequire laravel/valet
        if (ExistCommand -Name valet) {
            WriteMessage -Type Success -Message 'Installed version of Laravel Valet: ' -NoNewline
            valet --version
            valet install
        } else {
            WriteMessage -Type Danger -Message 'Laravel Valet was not installed.'
        }
    }
}

function InstallYarn {
    if ($IsMacOS) {
        WriteMessage -Type Info -Inverse -Message "Using Homebrew to install Yarn..."
        sh -c 'brew install yarn --without-node'
    } elseif ($IsWindows) {
        WriteMessage -Type Info -Inverse -Message "Using Scoop to install Yarn..."
        cmd /c 'scoop install yarn'
    }
    if (ExistCommand -Name yarn) {
        WriteMessage -Type Success -Message 'Installed version of Yarn: ' -NoNewline
        yarn --version
    } else {
        WriteMessage -Type Danger -Message 'Yarn is not correctly installed.'
    }
}

# Remove Functions
# ----------------

function RemoveLocalArtestead {
    WriteMessage -Type Info -Inverse -Message 'Removing local Artestead'
    $File = 'Artestead'
    if ((Test-Path -Path "${File}.json") -or (Test-Path -Path "${File}.yaml")) {
        WriteMessage -Type Info -Message 'Removing files...'
        $ToRemove = @(
            "${File}.json",
            "${File}.json.example",
            "${File}.yaml",
            "${File}.yaml.example"
        )
        if (Test-Path -Path Vagrantfile) {
            vagrant destroy
            $ToRemove += @('.vagrant', 'Vagrantfile')
        }
        $ToRemove += @(
            '.gitignore',
            'after.sh',
            'aliases.sh',
            'composer.*',
            'vendor'
        )
        Remove-Item -Path $ToRemove -Recurse -Force -ErrorAction SilentlyContinue
    } else {
        WriteMessage -Type Warning -Message "This is not an Artestead project. Could not find '${File}' in this directory."
    }
}

function RemoveAndroidStudio {
    if ($IsMacOS) {
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

# Uninstall functions
# -------------------

function UninstallArtestead {
    WriteMessage -Type Info -Inverse -Message 'Uninstalling Artestead'
    WriteMessage -Type Info -Message 'Using CGR to uninstall Artestead...'
    if ((ExistCommand -Name cgr) -and (ExistCommand -Name artestead)) {
        cgr remove gdmgent/artestead
    }
}

if ($IsMacOS) {
    function UninstallBrew {
        WriteMessage -Type Info -Inverse -Message 'Uninstalling Homebrew'
        WriteMessage -Type Info -Message 'Using Ruby to uninstall Homebrew...'
        sh -c 'ruby -e \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/uninstall)\"'
    }
}

if ($IsMacOS) {
    function UninstallMySQL {
        WriteMessage -Type Info -Inverse -Message 'Uninstalling MySQL'
        WriteMessage -Type Info -Message 'Using Homebrew to uninstall MySQL...'
        sh -c 'brew uninstall mysql'
        $ToRemove = @(
            '/usr/local/var/mysql'
        )
        Remove-Item -Path $ToRemove -Recurse -Force -ErrorAction SilentlyContinue
    }
}

function UninstallRuby {
    WriteMessage -Type Info -Inverse -Message 'Uninstalling Ruby'
    if ($IsMacOS) {
        WriteMessage -Type Info -Message 'Using Homebrew to uninstall Ruby...'
        if (ExistCommand -Name brew) {
            sh -c 'brew uninstall ruby'
        }
    } elseif ($IsWindows) {
        WriteMessage -Type Info -Message 'Using Scoop to uninstall Ruby...'
        if (ExistCommand -Name brew) {
            cmd /c 'scoop uninstall ruby'
            cmd /c 'scoop uninstall msys2'
        }
        # WriteMessage -Type Info -Message 'Removing Ruby files...'
        # Remove-Item -Path @('C:\DevKit', 'C:\Ruby23-x64') -Recurse -Force
    }
}

if ($IsWindows) {
    function UninstallUbuntu {
        WriteMessage -Type Info -Inverse -Message 'Uninstalling Bash on Ubuntu on Windows...'
        LxRun.exe /uninstall /y
    }
    function ResetUbuntu {
    WriteMessage -Type Info -Inverse -Message 'Resetting Bash on Ubuntu on Windows...'
        LxRun.exe /uninstall /full /y
        LxRun.exe /install /y
    }
}

if ($IsMacOS) {
    function UninstallValet {
        WriteMessage -Type Info -Inverse -Message 'Uninstalling Valet'
        WriteMessage -Type Info -Message 'Using CGR to uninstall Laravel Valet...'
        if ((ExistCommand -Name cgr) -and (ExistCommand -Name valet)) {
            cgr remove laravel/valet
        }
    }
}

if ($IsMacOS) {
    function UpdateBrew {
        Param(
            [Switch]
            $Force
        )
        WriteMessage -Type Primary -Inverse -Message 'Updating Homebrew'
        if (ExistCommand -Name brew) {
            WriteMessage -Type Info -Message 'Updating Homebrew...'
            sh -c 'brew update'
            WriteMessage -Type Info -Message 'Upgrading Homebrew...'
            sh -c 'brew upgrade'
            WriteMessage -Type Info -Message 'Cleaning up Homebrew...'
            if ($Force) {
                sh -c 'brew cleanup -s'
            } else {
                sh -c 'brew cleanup'
            }
        }
    }
}

function UpdateBundler {
    $File = 'Gemfile'
    if (Test-Path $File) {
        if (ExistCommand -Name bundle) {
            WriteMessage -Type Primary -Inverse -Message 'Updating Bundler'
            WriteMessage -Type Info -Message 'Updating Bundler Bundle...'
            bundle update
            WriteMessage -Type Info -Message 'Cleaning up unused Ruby Gems...'
            gem cleanup
        } else {
            WriteMessage -Type Danger -Message 'Bundler Ruby Gem is not installed.'
            InstallBundler
            UpdateBundler
        }
    } else {
        WriteMessage -Type Warning -Message "Cannot run Bundler in this directory because a '${File}' is required."
    }
}

if ($IsWindows) {
    function UpdateScoop {
        WriteMessage -Type Primary -Inverse -Message 'Updating Scoop'
        if (ExistCommand -Name scoop) {
            WriteMessage -Type Info -Message 'Updating Scoop...'
            cmd /c 'scoop update'
            WriteMessage -Type Info -Message 'Updating Scoop apps...'
            cmd /c 'scoop update *'
            WriteMessage -Type Info -Message 'Cleaning up Scoop apps...'
            cmd /c 'scoop cleanup *'
            WriteMessage -Type Info -Message 'Clearing Scoop cache...'
            cmd /c 'scoop cache rm *'
        }
    }
}