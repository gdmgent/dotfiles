function BehatCommand {
    if (Test-Path -Path ($Path = Join-Path -Path bin -ChildPath behat)) {
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
    } elseif (ExistCommand -Name behat) {
        Invoke-Expression -Command ((Get-Command -Name behat -Type Application).Source + " $args")
    } else {
        Write-Warning -Message "Behat is not available from this directory, nor is it installed globally."
    }
}
New-Alias -Name behat -Value BehatCommand

function GravCommand {
    if (Test-Path -Path ($Path = Join-Path -Path bin -ChildPath grav)) {
        Invoke-Expression -Command "php $Path $args"
    } else {
        Write-Warning -Message "Grav CLI Application is not available from this directory."
    }
}
New-Alias -Name grav -Value GravCommand

function GravGPMCommand {
    if (Test-Path -Path ($Path = Join-Path -Path bin -ChildPath gpm)) {
        Invoke-Expression -Command "php $Path $args"
    } else {
        Write-Warning -Message "Grav Package Manager is not available from this directory."
    }
}
New-Alias -Name gpm -Value GravGPMCommand

function LaravelArtisanCommand {
    if (Test-Path -Path artisan) {
        Invoke-Expression -Command "php artisan $args"
    } else {
        Write-Warning -Message "Laravel Artisan Console is not available from this directory."
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
    if (Test-Path -Path ($Path = Join-Path -Path bin -ChildPath phpunit)) {
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
    } elseif (ExistCommand -Name phpunit) {
        Invoke-Expression -Command ((Get-Command -Name phpunit -Type Application).Source + " $args")
    } else {
        Write-Warning -Message "PHPUnit is not available from this directory, nor is it installed globally."
    }
}
New-Alias -Name phpunit -Value PHPUnitCommand

function SymfonyConsoleCommand {
    if (Test-Path -Path ($PathBin = Join-Path -Path bin -ChildPath console)) {
        # Symfony 3.*.*
        Invoke-Expression -Command "php $PathBin $args"
    } elseif (Test-Path -Path ($PathApp = Join-Path -Path app -ChildPath console)) {
        # Symfony 2.*.*
        Invoke-Expression -Command "php $PathApp $args"
    } else {
        Write-Warning -Message "Symfony Console is not available from this directory."
    }
}
New-Alias -Name console -Value SymfonyConsoleCommand

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