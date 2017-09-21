function BehatCommand {
    $Command = 'behat'
    if (Test-Path -Path ($Path = Join-Path -Path bin -ChildPath $Command)) {
        if ($IsWindows) {
            Invoke-Expression -Command "$Path $args"
        } else {
            Invoke-Expression -Command "php $Path $args"
        }
    } elseif (Test-Path -Path ($Path = Join-Path -Path vendor -ChildPath $Path)) {
        if ($IsWindows) {
            Invoke-Expression -Command "$Path $args"
        } else {
            Invoke-Expression -Command "php $Path $args"
        }
    } elseif (ExistCommand -Name $Command) {
        Invoke-Expression -Command (((Get-Command -Name $Command -Type Application).Source | Select-Object -first 1) + " $args")
    } else {
        Write-Warning -Message 'Behat is not available from this directory, nor is it installed globally.'
    }
}
New-Alias -Name behat -Value BehatCommand

function ComposerGlobalRequire {
    if (ExistCommand cgr) {
        $State = ReadConfig -Name Proxy
        if ($IsMacOS -and $State -eq 'on') {
            cgr --prefer-source $args
        } else {
            cgr $args
        }
    } else {
        InstallComposerCgr
    }
}

function DrushCommand {
    $Command = 'drush'
    if (Test-Path -Path ($Path = Join-Path -Path bin -ChildPath $Command)) {
        if ($IsWindows) {
            Invoke-Expression -Command "$Path --nocolor $args"
        } else {
            Invoke-Expression -Command "php $Path $args"
        }
    } elseif (Test-Path -Path ($Path = Join-Path -Path vendor -ChildPath $Path)) {
        if ($IsWindows) {
            Invoke-Expression -Command "$Path --nocolor $args"
        } else {
            Invoke-Expression -Command "php $Path $args"
        }
    } elseif (ExistCommand -Name $Command) {
        Invoke-Expression -Command (((Get-Command -Name $Command -Type Application).Source | Select-Object -first 1) + " --nocolor $args")
    } else {
        Write-Warning -Message 'Drush is not available from this directory, nor is it installed globally.'
    }
}
New-Alias -Name drush -Value DrushCommand

function GravCommand {
    $Command = 'grav'
    if (Test-Path -Path ($Path = Join-Path -Path bin -ChildPath $Command)) {
        Invoke-Expression -Command "php $Path $args"
    } else {
        Write-Warning -Message 'Grav CLI Application is not available from this directory.'
    }
}
New-Alias -Name grav -Value GravCommand

function GravGPMCommand {
    $Command = 'gpm'
    if (Test-Path -Path ($Path = Join-Path -Path bin -ChildPath $Command)) {
        Invoke-Expression -Command "php $Path $args"
    } else {
        Write-Warning -Message 'Grav Package Manager is not available from this directory.'
    }
}
New-Alias -Name gpm -Value GravGPMCommand

function LaravelArtisanCommand {
    $Command = 'artisan'
    if (Test-Path -Path $Command) {
        Invoke-Expression -Command "php $Command $args"
    } else {
        Write-Warning -Message 'Laravel Artisan Console is not available from this directory.'
    }
}
New-Alias -Name artisan -Value LaravelArtisanCommand
New-Alias -Name art -Value LaravelArtisanCommand

function PhpServeCommand {
    Param(
        [String]
        $Hostname = 'localhost',
        [Int16]
        $Port = 8080,
        [String]
        $RouterScript = ''
    )
    $Uri = "${Hostname}:$Port"
    OpenUri -Uri "http://$Uri"
    Invoke-Expression -Command "php -S $Uri $RouterScript"
}
New-Alias -Name phpserve -Value PhpServeCommand

function PHPUnitCommand {
    $Command = 'phpunit'
    if (Test-Path -Path ($Path = Join-Path -Path bin -ChildPath $Command)) {
        if ($IsWindows) {
            Invoke-Expression -Command "$Path $args"
        } else {
            Invoke-Expression -Command "php $Path $args"
        }
    } elseif (Test-Path -Path ($Path = Join-Path -Path vendor -ChildPath $Path)) {
        if ($IsWindows) {
            Invoke-Expression -Command "$Path $args"
        } else {
            Invoke-Expression -Command "php $Path $args"
        }
    } elseif (ExistCommand -Name $Command) {
        Invoke-Expression -Command ((Get-Command -Name $Command -Type Application).Source + " $args")
    } else {
        Write-Warning -Message 'PHPUnit is not available from this directory, nor is it installed globally.'
    }
}
New-Alias -Name phpunit -Value PHPUnitCommand

function SymfonyConsoleCommand {
    $Command = 'console'
    if (Test-Path -Path ($PathBin = Join-Path -Path bin -ChildPath $Command)) {
        # Symfony 3.*.*
        Invoke-Expression -Command "php $PathBin $args"
    } elseif (Test-Path -Path ($PathApp = Join-Path -Path app -ChildPath $Command)) {
        # Symfony 2.*.*
        Invoke-Expression -Command "php $PathApp $args"
    } else {
        Write-Warning -Message 'Symfony Console is not available from this directory.'
    }
}
New-Alias -Name console -Value SymfonyConsoleCommand

if (ExistCommand -Name composer) {
    function UpdateComposer {
        Param(
            [Switch]
            $Local
        )
        if ($Local) {
            Write-Host 'Updating locally installed Composer packages...' -ForegroundColor Blue
            $Directories = Get-ChildItem -Filter composer.json -Recurse | Where-Object { $_.Directory -notmatch 'vendor' } | Select-Object -Property Directory
            foreach ($Directory in $Directories) {
                Write-Host ('in ' + $Directory.Directory) -ForegroundColor  Magenta
                Push-Location $Directory.Directory
                composer update
                Pop-Location
            }
        } else {
            Write-Host 'Updating Composer...' -ForegroundColor Blue
            composer self-update
            Write-Host 'Updating globally installed Composer packages...' -ForegroundColor Blue
            composer global update
            if (ExistCommand -Name cgr) {
                Write-Host 'Updating CGR installed Composer packages...' -ForegroundColor Blue
                cgr update
            }
        }
    }
}

function XdebugCliConfig {
    $Settings = @(
        "remote_connect_back=0"
        "remote_enable=1"
        "remote_host=127.0.0.1"
        "remote_mode=req"
        "remote_port=9000"
    ) -join " "

    $env:XDEBUG_CONFIG = $Settings
}
XdebugCliConfig