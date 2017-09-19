# Install Functions
# -----------------

function InstallArtestead {
    Write-Host 'Installing Artestead (Artevelde Laravel Homestead)...'
    if (ExistCommand -Name vagrant) {
        vagrant plugin install vagrant-hostsupdater
    }
    if (ExistCommand -Name cgr) {
        cgr gdmgent/artestead
    } else {
        Write-Warning -Message 'Run InstallComposerCgr and try again.'
    }
}

if ($IsMacOS) {
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
    if ($IsMacOS) {
        Write-Host 'Using PHP to install Composer...'
        sh -c 'curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer'
        
    } elseif ($IsWindows) {
        Write-Host 'Downloading Composer installer...'
        $Urn = 'Composer-Setup.exe'
        $Uri = "https://getcomposer.org/$Urn"
        $InstallerFile = Join-Path -Path $env:TEMP -ChildPath $Urn
        Invoke-WebRequest -Uri $Uri -OutFile $InstallerFile
        if (Test-Path -Path $InstallerFile) {
            Write-Host 'Running Composer Installer...'
            Start-Process -FilePath $InstallerFile -Wait
            Remove-Item -Path $InstallerFile
        }
    }
    if (ExistCommand -Name composer) {
        Write-Host 'Installed version of Composer: ' -NoNewline
        composer --version
    } else {
        Write-Warning -Message 'Composer was not installed.'
    }
}

function InstallComposerCgr {
    Write-Host 'Using Composer to install CGR (Composer Global Require)...'
    if (! (ExistCommand -Name composer)) {
        InstallComposer
    }
    composer global require consolidation/cgr
    if (ExistCommand -Name cgr) {
        Write-Host 'CGR is installed.'
    } else {
        Write-Warning -Message 'CGR was not installed.'
    }
}

function InstallComposerPrestissimo {
    Write-Host 'Using Composer to install Prestissimo...'
    if (! (ExistCommand -Name composer)) {
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
    if ($IsMacOS) {
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
    if ($IsMacOS) {
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
    if ($IsMacOS) {
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
    if ($IsMacOS) {
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
    if (! (ExistCommand -Name git)) {
        InstallGit
    }
    Write-Host 'Installing GitIgnore Global...'
    $GitIgnoreSource = Join-Path -Path $Global:DotfilesInstallPath -ChildPath 'preferences' | Join-Path -ChildPath 'gitignore_global'
    git config --global core.excludesfile $GitIgnoreSource
}

function InstallHotel {
    Write-Host 'Installing Hotel...'
    if (! (ExistCommand -Name yarn)) {
        InstallYarn
    }
    yarn global add hotel
    if (ExistCommand -Name hotel) {
        Write-Host 'Installed version of Hotel: ' -NoNewline
        hotel --version
    } else {
        Write-Warning -Message 'Hotel was not installed.'
    }
}

function InstallHyperPreferences {
    Write-Host 'Installing Hyper.js preferences...'
    $FileName = '.hyper.js'
    $SourcePath = Join-Path -Path $Global:DotfilesInstallPath -ChildPath 'preferences' | Join-Path -ChildPath $FileName
    $DestinationPath = Join-Path -Path $HOME -ChildPath $FileName
    if ($IsMacOS) {
        $Command = (Get-Command -Name powershell -CommandType Application).Source
    } elseif ($IsWindows) {
        $Command = (Get-Command -Name powershell -CommandType Application | Where-Object { $_.Source -like '*6.0.0*' } | Select-Object -First 1).Source -replace '\\', '\\' # replaces \ with \\
    }
    Copy-Item -Path $SourcePath -Destination $DestinationPath
    $FileContent = (Get-Content -Path $DestinationPath).Replace("shell: 'powershell',", "shell: '$Command',")
    Set-Content -Path $DestinationPath -Value $FileContent
}

function InstallNvm {
    if ($IsMacOS) {
        Write-Host 'Using Homebrew to install Node Version Manager...'
        sh -c 'brew install nvm'

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
    if (ExistCommand -Name nvm) {
        Write-Host 'Installed version of NVM: ' -NoNewline
        if ($IsMacOS) {
            nvm --version
        } elseif ($IsWindows) {
            nvm version
        }
    } else {
        Write-Warning -Message 'NVM is not correctly installed.'
    }
}

function InstallMySQL {
    if ($IsMacOS) {
        Write-Host 'Using Homebrew to install MySQL Server...'
        sh -c 'brew install mysql'
    } elseif ($IsWindows) {
        OpenUri -Uri https://dev.mysql.com/downloads/installer/
    }
}

if ($IsWindows) {
    function InstallOhMyZsh {
        if ($IsMacOS) {
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
}

function InstallPhp {
    Param(
        [Switch]
        $Development
    )
    $VersionStable      = '7.1'
    $VersionDevelopment = '7.2'
    if ($Development) {
        $Version = $VersionDevelopment
    } else {
        $Version = $VersionStable
    }
    if ($IsMacOS) {
        Write-Host "Using Homebrew to install PHP $Version..."
        $V = $Version.replace('.', '')
        sh -c "brew tap homebrew/php && brew install php${V} php${V}-mcrypt php${V}-opcache php${V}-xdebug"
        $ConfigFilePath = "/usr/local/etc/php/${Version}/conf.d/ext-xdebug.ini"
        if (Test-Path -Path $ConfigFilePath) {
            $ConfigFile = Get-Content -Path $ConfigFilePath
            if (! [bool]($ConfigFile -match "xdebug.remote_enable")) {
                Add-Content -Path $ConfigFilePath -Value "`nxdebug.remote_enable=1"
            }
        }
    } elseif ($IsWindows) {
        Write-Host "Downloading PHP $Version..."
        $Url =  'http://windows.php.net'
        if ($Development) {
            $File = "/php-$Version.\d+RC\d+-nts-Win32-VC15-x64.zip$"
            $FileUri = "$Url/downloads/qa"
        } else {
            $File = "/php-$Version.\d+-nts-Win32-VC14-x64.zip$"
            $FileUri = "$Url/downloads/releases"
        }
        $RelativeUri = ((Invoke-WebRequest -Uri $FileUri).Links | Where-Object { $_.href -match $File } | Select-Object -First 1).href
        $Uri = "$Url$RelativeUri"
        $OutFile = Join-Path -Path $env:TEMP -ChildPath 'php.zip'
        Invoke-WebRequest -Uri $Uri -OutFile $OutFile
        if (Test-Path -Path $OutFile) {
            $DestinationPath = 'C:\php'
            if ((Test-Path -Path $DestinationPath) -and ! (Test-Path -Path "$DestinationPath.bak")) {
                Write-Host "Making a backup of previously installed version..."
                Move-Item -Path $DestinationPath -Destination "$DestinationPath.bak"
            }
            Write-Host 'Installing PHP...'
            Expand-Archive -Path $OutFile -DestinationPath $DestinationPath -Force
            Remove-Item -Path $OutFile
            Write-Host 'Configuring PHP...'
            $ConfigFile = Get-Content -Path C:\php\php.ini-development
            $Replacements = @(
                'extension=php_curl'
                'extension=php_gd2'
                'extension=php_mbstring'
                'extension=php_openssl'
                'extension=php_pdo_mysql'
                'extension=php_pdo_sqlite'
                'extension=php_sqlite3'
            )
            foreach ($Replacement in $Replacements) {
                $ConfigFile = $ConfigFile.Replace(";$Replacement", $Replacement)
            }
            # Adding CA Root Certificates for SSL
            $ConfigFile = $ConfigFile.Replace(';openssl.cafile=', 'openssl.cafile=' + $Global:DotfilesInstallPath + '\ssl\cacert.pem')
            Set-Content -Path ($ConfigFilePath = Join-Path -Path $DestinationPath -ChildPath 'php.ini') -Value $ConfigFile
            if (!$Development) {
                # OPcache
                Write-Host 'Configuring PHP to use OPcache...'
                Add-Content -Path $ConfigFilePath -Value "`nzend_extension=C:\php\ext\php_opcache.dll"
                # Xdebug
                Write-Host 'Downloading Xdebug for PHP...'
                $Url = 'https://xdebug.org'
                $RelativeUrl = ((Invoke-WebRequest -Uri "$Url/download.php").Links | Where-Object { $_.href -match "/php_xdebug-\d.\d.\d-$Version-vc14-nts-x86_64.dll$" } | Select-Object -First 1).href
                $Uri = "$Url/$RelativeUrl"
                $OutFile = 'C:\php\ext\php_xdebug.dll'
                Invoke-WebRequest -Uri $Uri -OutFile $OutFile
                Write-Host 'Configuring PHP to use Xdebug...'
                Add-Content -Path $ConfigFilePath -Value "`nzend_extension=C:\php\ext\php_xdebug.dll"
            }
        }
    }
    if (ExistCommand -Name php) {
        Write-Host 'Installed version of PHP: ' -NoNewline
        php -v
    } else {
        Write-Warning -Message 'PHP is not correctly installed.'
    }
}

function InstallPowerShell {
    $Response = Invoke-RestMethod -Method Get -Uri https://api.github.com/repos/powershell/powershell/releases/latest
    $Version = $Response.tag_name
    if ($IsMacOS) {
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
        $OS = 'win10-win2016-x64.msi$'
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
            Write-Host 'Run InstallHyperPreferences and reopen Hyper'
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
    if ($IsMacOS) {
        # Write-Host 'Using Homebrew and rbenv to install Ruby...'
        # sh -c 'brew install rbenv && rbenv install 2.3.4 && rbenv global 2.3.4'
        Write-Host 'Using Homebrew to install Ruby...'
        if (ExistCommand -Name brew) {
            sh -c 'brew install ruby'
        }
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
        AddToEnvironmentPath -Path C:\$RubyDirectoryName\bin -First
        InstallRubyDevKit
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

if ($IsWindows) {
    function InstallRubyDevKit {
        if (ExistCommand -Name ruby) {
            Write-Host 'Downloading Ruby DevKit installer...'
            $RubyDirectoryName = 'Ruby23-x64'
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
        } else {
            Write-Warning -Message 'Ruby is not correctly installed.'
        }
    }
}

if ($IsMacOS) {
    function InstallValet {
        Write-Host 'Using CGR to install Laravel Valet...'
        cgr laravel/valet
        if (ExistCommand -Name valet) {
            Write-Host 'Installed version of Laravel Valet: ' -NoNewline
            valet --version
            valet install
        } else {
            Write-Warning -Message 'Laravel Valet was not installed.'
        }
    }
}

function InstallVisualStudioCode {
    if ($IsMacOS) {
        # Fixes a PowerShell extension in Visual Studio Code
        $Path = '/usr/local/Cellar/openssl/1.0.2h_1/lib'
        $Destination = '/usr/local/lib'
        Copy-Item -Path $Path/libcrypto.dylib -Destination $Destination/libcrypto.1.0.0.dylib
        Copy-Item -Path $Path/libssl.dylib -Destination $Destination/libssl.1.0.0.dylib
    }
}

function InstallYarn {
    if ($IsMacOS) {
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
    if (ExistCommand -Name yarn) {
        Write-Host 'Installed version of Yarn: ' -NoNewline
        yarn --version
    } else {
        Write-Warning -Message 'Yarn is not correctly installed.'
    }
}

# Remove Functions
# ----------------

function RemoveLocalArtestead {
    $File = 'Artestead'
    if ((Test-Path -Path "$File.json") -or (Test-Path -Path "$File.yaml")) {
        Write-Host 'Removing Local Artestead...'
        $ToRemove = @(
            "$File.json",
            "$File.json.example",
            "$File.yaml",
            "$File.yaml.example"
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
        Write-Warning -Message "This is not an Artestead project. Could not find '$File' in this directory."
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
    Write-Host 'Using CGR to uninstall Artestead...'
    if ((ExistCommand -Name cgr) -and (ExistCommand -Name artestead)) {
        cgr remove gdmgent/artestead
    }
}

if ($IsMacOS) {
    function UninstallBrew {
        Write-Host 'Using Ruby to uninstall Homebrew...'
        sh -c 'ruby -e \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/uninstall)\"'
    }
}

function UninstallRuby {
    if ($IsMacOS) {
        Write-Host 'Using Homebrew to uninstall Ruby...'
        if (ExistCommand -Name brew) {
            brew uninstall ruby
        }
    } elseif ($IsWindows) {
        Write-Host 'Uninstalling Ruby...'
        Remove-Item -Path @('C:\DevKit', 'C:\Ruby23-x64') -Recurse -Force
    }
}

if ($IsMacOS) {
    function UninstallValet {
        Write-Host 'Using CGR to uninstall Laravel Valet...'
        if ((ExistCommand -Name cgr) -and (ExistCommand -Name valet)) {
            cgr remove laravel/valet
        }
    }
}

if ($IsMacOS) {
    function UpdateBrew {
        Write-Host 'Updating Homebrew...'
        if (ExistCommand -Name brew) {
            sh -c 'brew update && brew upgrade && brew cleanup'
        }
    }
}

function UpdateBundler {
    $File = 'Gemfile'
    if (Test-Path $File) {
        if (ExistCommand -Name bundle) {
            bundle update
            gem cleanup
        } else {
            Write-Warning -Message 'Bundler Ruby Gem is not installed.'
            InstallBundler
            UpdateBundler
        }
    } else {
        Write-Warning -Message "Cannot run Bundler in this directory because a '$File' is required."
    }
}