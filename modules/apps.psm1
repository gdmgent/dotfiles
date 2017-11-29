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
        WriteMessage -Type Info -Message 'Downloading Composer installer...'
        $Urn = 'Composer-Setup.exe'
        $Uri = "https://getcomposer.org/${Urn}"
        $InstallerFile = Join-Path -Path $env:TEMP -ChildPath $Urn
        Invoke-WebRequest -Uri $Uri -OutFile $InstallerFile
        if (Test-Path -Path $InstallerFile) {
            WriteMessage -Type Info -Message 'Running Composer Installer...'
            Start-Process -FilePath $InstallerFile -Wait
            Remove-Item -Path $InstallerFile
        }
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
    $State = ReadConfig -Name Proxy
    if ($IsMacOS -and $State.Equals('on')) {
        composer global require --prefer-source consolidation/cgr
    } else {
        composer global require consolidation/cgr
    }
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
    $State = ReadConfig -Name Proxy
    if ($IsMacOS -and $State.Equals('on')) {
        composer global require --prefer-source hirak/prestissimo
    } else {
        composer global require hirak/prestissimo
    }
}

function InstallFontFiraCode {
    WriteMessage -Type Info -Inverse -Message 'Installing Fira Code typeface by Nikita Prokopov'
    WriteMessage -Type Info -Message 'Downloading Fira Code typeface ...'
    $Response = Invoke-RestMethod -Method Get -Uri https://api.github.com/repos/tonsky/FiraCode/releases/latest
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
            $output = unzip $OutFile **/*.otf -d $TempPath -o
            Remove-Item -Path $OutFile
            Move-Item -Path ${TempPath}otf/*.otf -Destination $DestinationPath -Force
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
            $Output = Get-ChildItem -Path ${TempPath}otf\*.otf | Select-Object { (New-Object -ComObject Shell.Application).Namespace(0x14).CopyHere($_.FullName) }
            Remove-Item -Path $TempPath -Recurse -Force
        }
    }
}

function InstallFontHack {
    WriteMessage -Type Info -Inverse -Message 'Installing Hack typeface by Chris Simpkins'
    WriteMessage -Type Info -Message 'Downloading Hack typeface'
    $Response = Invoke-RestMethod -Method Get -Uri https://api.github.com/repos/chrissimpkins/Hack/releases/latest
    $Name = 'Hack'
    $Urn = "${Name}.zip"
    $Uri = ($Response.assets | Where-Object { $_.name -match '^Hack-(.+)-otf.zip$' }).browser_download_url
    if ($IsMacOS) {
        $OutFile = Join-Path -Path $env:TMPDIR -ChildPath $Urn
        Invoke-WebRequest -Uri $Uri -OutFile $OutFile
        if (Test-Path -Path $OutFile) {
            Write-WriteMessage -Type Info -Message 'Installing Hack typeface...'
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
            WriteMessage -Type Info -Message 'Installing Hack typeface...'
            $DestinationPath = "C:\Windows\Fonts\"
            $TempPath = "${env:TEMP}${Name}\"
            Expand-Archive -Path $OutFile -DestinationPath $TempPath -Force
            Remove-Item -Path $OutFile
            $Output = Get-ChildItem -Path ${TempPath}*.otf | Select-Object { (New-Object -ComObject Shell.Application).Namespace(0x14).CopyHere($_.FullName) }
            Remove-Item -Path $TempPath -Recurse -Force
        }
    }
}

function InstallFontHasklig {
    WriteMessage -Type Info -Inverse -Message 'Installing Hasklig typeface by Ian Tuomi...'
    WriteMessage -Type Info -Message 'Downloading Hasklig typeface...'
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
            $Output = Get-ChildItem -Path ${TempPath}*.otf | Select-Object { (New-Object -ComObject Shell.Application).Namespace(0x14).CopyHere($_.FullName) }
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
        WriteMessage -Type Info -Message 'Downloading Git installer...'
        $Response = Invoke-RestMethod -Method Get -Uri https://api.github.com/repos/git-for-windows/git/releases/latest
        $Version = $Response.tag_name
        $OS = '-64-bit.exe$'
        $Uri = ($Response.assets | Where-Object { $_.name -match $OS }).browser_download_url
        $Urn = 'git-64-bit.exe'
        $InstallerFile = Join-Path -Path $env:TEMP -ChildPath $Urn
        Invoke-WebRequest -Uri $Uri -OutFile $InstallerFile
        if (Test-Path -Path $InstallerFile) {
            WriteMessage -Type Info -Inverse -Message 'Running Git installer...'
            WriteMessage -Message ' - ' -NoNewline
            WriteMessage -Type Success -Inverse -Message '[Next >]'
            WriteMessage -Message ' - ' -NoNewline
            WriteMessage -Type Success -Inverse -Message '[Next >]'
            WriteMessage -Message ' - ' -NoNewline
            WriteMessage -Type Warning -Message "'Use Git and optional Unix tools from the Windows Command Prompt'" -NoNewLine
            WriteMessage -Message ', ' -NoNewline
            WriteMessage -Type Success -Inverse -Message '[Next >]'
            WriteMessage -Message ' - ' -NoNewline
            WriteMessage -Type Warning -Message "'Checkout Windows-style, commit Unix-style line endings'" -NoNewLine
            WriteMessage -Message ', ' -NoNewline
            WriteMessage -Type Success -Inverse -Message '[Next >]'
            WriteMessage -Message ' - ' -NoNewline
            WriteMessage -Type Warning -Message "'Use Windows' default console window'" -NoNewLine
            WriteMessage -Message ', ' -NoNewline
            WriteMessage -Type Success -Inverse -Message '[Next >]'
            WriteMessage -Message ' - ' -NoNewline
            WriteMessage -Type Success -Inverse -Message '[Install]'
            WriteMessage -Message ' - ' -NoNewline
            WriteMessage -Type Success -Inverse -Message '[Finish]'
            Start-Process -FilePath $InstallerFile -Wait
            Remove-Item -Path $InstallerFile
        }
    }
    if (ExistCommand -Name git) {
        git config --global credential.helper wincred
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
        $Command = (Get-Command -Name $AppName -CommandType Application | Where-Object { $_.Source -like '*6.0.0*' } | Select-Object -First 1).Source -replace '\\', '\\' # replaces \ with \\
    }
    Copy-Item -Path $SourcePath -Destination $DestinationPath
    $FileContent = (Get-Content -Path $DestinationPath).Replace("shell: '${AppName}',", "shell: '${Command}',")
    Set-Content -Path $DestinationPath -Value $FileContent
}

function InstallNvm {
    Param(
        [Switch]
        $Prerelease
    )
    WriteMessage -Type Info -Inverse -Message 'Installing NVM (Node Version Manager)'
    if ($IsMacOS) {
        WriteMessage -Type Info -Message 'Using Homebrew to install NVM...'
        sh -c 'brew install nvm'
    } elseif ($IsWindows) {
        if ($Prerelease) {
            $Response = Invoke-RestMethod -Method Get -Uri https://api.github.com/repos/coreybutler/nvm-windows/releases?per_page=1
        } else {
            $Response = Invoke-RestMethod -Method Get -Uri https://api.github.com/repos/coreybutler/nvm-windows/releases/latest
        }
        $Version = $Response.name
        WriteMessage -Type Info -Message "Downloading Node Version Manager ${Version}..."
        $Urn = 'nvm-setup.zip'
        $Uri = ($Response.assets | Where-Object { $_.name.Equals($Urn) }).browser_download_url
        $InstallerArchive = Join-Path -Path $env:TEMP -ChildPath $Urn
        Invoke-WebRequest -Uri $Uri -OutFile $InstallerArchive
        if (Test-Path -Path $InstallerArchive) {
            WriteMessage -Type Info -Message 'Running Node Version Manager installer...'
            Expand-Archive -Path $InstallerArchive -DestinationPath $env:TEMP -Force
            $InstallerFile = Join-Path -Path $env:TEMP -ChildPath $Urn.Replace('zip', 'exe')
            if (Test-Path -Path $InstallerFile) {
                Remove-Item -Path $InstallerArchive
                Start-Process -FilePath $InstallerFile -Wait
                Remove-Item -Path $InstallerFile
            }
        }
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
    $Version = '1.12'
    WriteMessage -Type Info -Inverse -Message 'Installing NGINX'
    if ($IsMacOS) {
        WriteMessage -Type Info -Message 'Using Homebrew to install NGINX...'
        sh -c 'brew install nginx'
    } elseif ($IsWindows) {
        WriteMessage -Type Info -Message "Downloading NGINX ${Version}..."
        $Url = 'https://nginx.org/en/download.html'
        $File = "/nginx-${Version}.\d+.zip$"
        $FileUri = "https://nginx.org"
        $RelativeUri = ((Invoke-WebRequest -Uri $Url).Links | Where-Object { $_.href -match $File } | Select-Object -First 1).href
        $Uri = "${FileUri}${RelativeUri}"
        $OutFile = Join-Path -Path $env:TEMP -ChildPath 'nginx.zip'
        Invoke-WebRequest -Uri $Uri -OutFile $OutFile
        if (Test-Path -Path $OutFile) {
            $DestinationPath = 'C:\nginx'
            if (Test-Path -Path $DestinationPath) {
                if (Test-Path -Path "${DestinationPath}.bak") {
                    WriteMessage -Type Info -Message "Removing a backup of previously installed version..."
                    Remove-Item -Path "${DestinationPath}.bak" -Recurse -Force
                }
                WriteMessage -Type Info -Message "Making a backup of previously installed version..."
                Rename-Item $DestinationPath -NewName "${DestinationPath}.bak"
            }
            WriteMessage -Type Info -Message 'Installing NGINX...'
            Expand-Archive -Path $OutFile -DestinationPath 'C:\' -Force
            if ($RelativeUri -match 'nginx-\d+.\d+.\d+') {
                $DestinationPathTemp = 'C:\' + $Matches[0]
                if (Test-Path -Path $DestinationPathTemp) {
                    Rename-Item $DestinationPathTemp -NewName $DestinationPath
                }
            }
            Remove-Item -Path $OutFile
        }
    }
    WriteMessage -Type Info -Message 'Configuring NGINX...'
    $FileName = 'nginx.conf'
    $SourcePath = [io.path]::Combine($HOME, 'dotfiles', 'settings', $FileName)
    $DestinationPath = [io.path]::Combine($HOME, '.dotfiles', $FileName)
    Copy-Item -Path $SourcePath -Destination $DestinationPath
    if ($IsMacOS) {
        $NginxConfigDirectory = (brew --prefix nginx) + '/.bottle/etc/nginx'
    } else {
        $NginxConfigDirectory = '/nginx/conf'
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
    Param(
        [Switch]
        $Development
    )
    $VersionStable      = '7.1'
    $VersionDevelopment = '7.2'
    $Version = if ($Development) { $VersionDevelopment } else { $VersionStable }
    WriteMessage -Type Info -Inverse -Message "Installing PHP ${Version}"
    if ($IsMacOS) {
        WriteMessage -Type Info -Message "Using Homebrew to install PHP ${Version}..."
        $V = $Version.replace('.', '')
        sh -c "brew tap homebrew/php && brew install php${V} php${V}-opcache php${V}-xdebug"
        $ConfigFilePath = "/usr/local/etc/php/${Version}/conf.d/ext-xdebug.ini"
        if (Test-Path -Path $ConfigFilePath) {
            $ConfigFile = Get-Content -Path $ConfigFilePath
            if (! [bool]($ConfigFile -match "xdebug.remote_enable")) {
                Add-Content -Path $ConfigFilePath -Value "`nxdebug.remote_enable=1"
            }
        }
    } elseif ($IsWindows) {
        WriteMessage -Type Info -Message "Downloading PHP ${Version}..."
        $Url =  'http://windows.php.net'
        if ($Development) {
            $File = "/php-${Version}.\d+RC\d+-nts-Win32-VC15-x64.zip$"
            $FileUri = "${Url}/downloads/qa"
        } else {
            $File = "/php-${Version}.\d+-nts-Win32-VC14-x64.zip$"
            $FileUri = "${Url}/downloads/releases"
        }
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
                'extension=php_curl',
                'extension=php_gd2',
                'extension=php_mbstring',
                'extension=php_openssl',
                'extension=php_pdo_mysql',
                'extension=php_pdo_sqlite',
                'extension=php_sqlite3'
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
            if (!$Development) {
                # OPcache
                WriteMessage -Type Info 'Configuring PHP to use OPcache...'
                Add-Content -Path $ConfigFilePath -Value "`nzend_extension=C:\php\ext\php_opcache.dll"
                # Xdebug
                WriteMessage -Type Info -Message 'Downloading Xdebug for PHP...'
                $Url = 'https://xdebug.org'
                $RelativeUrl = ((Invoke-WebRequest -Uri "${Url}/download.php").Links | Where-Object { $_.href -match "/php_xdebug-\d.\d.\d-${Version}-vc14-nts-x86_64.dll$" } | Select-Object -First 1).href
                $Uri = "${Url}/${RelativeUrl}"
                $OutFile = 'C:\php\ext\php_xdebug.dll'
                Invoke-WebRequest -Uri $Uri -OutFile $OutFile
                WriteMessage -Type Info -Message 'Configuring PHP to use Xdebug...'
                Add-Content -Path $ConfigFilePath -Value "`nzend_extension=C:\php\ext\php_xdebug.dll"
            }
        }
    }
    if (ExistCommand -Name php) {
        WriteMessage -Type Success 'Installed version of PHP: ' -NoNewline
        php -v
    } else {
        WriteMessage -Type Danger -Message 'PHP is not correctly installed.'
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
        $Url = 'https://cmake.org/download/'
        WriteMessage -Type Info -Message 'Downloading CMake installer...'
        $Uri = ((Invoke-WebRequest -Uri $Url).Links | Where-Object { $_.href -match "cmake-\d+.\d+.\d+-win64-x64.msi$" } | Select-Object -First 1).href
        WriteMessage -Message $Uri
        
        $Urn = "${RubyDirectoryName}.exe"
        
    }
}

function InstallRuby {
    WriteMessage -Type Info -Inverse -Message 'Installing Ruby'
    if ($IsMacOS) {
        WriteMessage -Type Info -Message 'Using Homebrew to install Ruby...'
        if (ExistCommand -Name brew) {
            InstallCmake 
            sh -c 'brew install ruby'
        }
    } elseif ($IsWindows) {
        $Url = 'http://rubyinstaller.org/downloads/'
        WriteMessage -Type Info -Message 'Downloading Ruby installer...'
        $Version = '2.3.\d+' # Jekyll is not compatible with newer versions of Ruby
        $RubyDirectoryName = 'Ruby23-x64'
        $Uri = ((Invoke-WebRequest -Uri $Url).Links | Where-Object { $_.href -match "rubyinstaller-${Version}-x64.exe$" } | Select-Object -First 1).href
        $Urn = "${RubyDirectoryName}.exe"
        $InstallerFile = Join-Path -Path $env:TEMP -ChildPath $Urn
        Invoke-WebRequest -Uri $Uri -OutFile $InstallerFile
        if (Test-Path -Path $InstallerFile) {
            WriteMessage -Type Info -Message 'Running Ruby installer...'
            WriteMessage -Type Warning -Inverse -Message " - 'English', [OK]"
            WriteMessage -Type Warning -Inverse -Message " - 'I accept the License', [Next>]"
            WriteMessage -Type Warning -Inverse -Message " - 'C:\${RubyDirectoryName}', 'Add Ruby executables to your PATH', [Install]"
            WriteMessage -Type Warning -Inverse -Message ' - [Finish]'
            Start-Process -FilePath $InstallerFile -Wait
            Remove-Item -Path $InstallerFile
        }
        AddToEnvironmentPath -Path C:\$RubyDirectoryName\bin -First
        InstallRubyDevKit
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
            WriteMessage -Type Info -Message 'Downloading Ruby DevKit installer...'
            $RubyDirectoryName = 'Ruby23-x64'
            $Version = 'mingw64-64'
            $DevKitDirectoryName = 'DevKit'
            $Uri = ((Invoke-WebRequest -Uri $Url).Links | Where-Object { $_.href -match "DevKit-${Version}-(\S+)-sfx.exe$" } | Select-Object -First 1).href
            $Urn = "${DevKitDirectoryName}.exe"
            $InstallerFile = Join-Path -Path $env:TEMP -ChildPath $Urn
            Invoke-WebRequest -Uri $Uri -OutFile $InstallerFile
            if (Test-Path -Path $InstallerFile) {
                WriteMessage -Type Info -Message 'Running Ruby DevKit installer...'
                Start-Process -FilePath $InstallerFile -ArgumentList "-oC:\${DevKitDirectoryName} -y" -Wait
                Remove-Item -Path $InstallerFile
                Set-Location -Path C:\$DevKitDirectoryName
                # ruby dk.rb init
                "---`n- C:\${RubyDirectoryName}`n" | Out-File -FilePath 'config.yml' -Encoding utf8
                ruby dk.rb install
            }
        } else {
            WriteMessage -Type Danger -Message 'Ruby is not correctly installed.'
        }
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
        $Response = Invoke-RestMethod -Method Get -Uri https://api.github.com/repos/yarnpkg/yarn/releases/latest
        $Version = $Response.tag_name
        $OS = '.msi$'
        $Uri = ($Response.assets | Where-Object { $_.name -match $OS }).browser_download_url
        $Urn = 'yarn.msi'
        $InstallerFile = Join-Path -Path $env:TEMP -ChildPath $Urn
        Invoke-WebRequest -Uri $Uri -OutFile $InstallerFile
        if (Test-Path -Path $InstallerFile) {
            WriteMessage -Type Info -Inverse -Message "Installing Yarn ${Version}..."
            WriteMessage -Message ' - ' -NoNewline
            WriteMessage -Type Success -Inverse -Message '[Next]'
            WriteMessage -Message ' - ' -NoNewline
            WriteMessage -Type Warning -Message "'I accept the terms License Agreement'" -NoNewLine
            WriteMessage -Message ', ' -NoNewline
            WriteMessage -Type Success -Inverse -Message '[Next]'
            WriteMessage -Message ' - ' -NoNewline
            WriteMessage -Type Warning -Message "'C:\Program Files (x86)\Yarn\'" -NoNewline
            WriteMessage -Message ', ' -NoNewline
            WriteMessage -Type Success -Inverse -Message '[Next]'
            WriteMessage -Message ' - ' -NoNewline
            WriteMessage -Type Success -Inverse -Message '[Install]'
            WriteMessage -Message ' - ' -NoNewline
            WriteMessage -Type Success -Inverse -Message '[Finish]'
            Start-Process -FilePath 'msiexec.exe' -ArgumentList "/i ${InstallerFile}" -Wait
            Remove-Item -Path $InstallerFile
       }
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
        WriteMessage -Type Info -Message 'Removing Ruby files...'
        Remove-Item -Path @('C:\DevKit', 'C:\Ruby23-x64') -Recurse -Force
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
        WriteMessage -Type Primary -Inverse -Message 'Updating Homebrew'
        if (ExistCommand -Name brew) {
            WriteMessage -Type Info -Message 'Updating Homebrew...'
            sh -c 'brew update'
            WriteMessage -Type Info -Message 'Upgrading Homebrew...'
            sh -c 'brew upgrade'
            WriteMessage -Type Info -Message 'Cleaning up Homebrew...'
            sh -c 'brew cleanup'
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