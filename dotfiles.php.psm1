function BehatBehat {
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
New-Alias -Name behat -Value BehatBehat

function GetGravGrav {
    if (Test-Path -Path ($Path = Join-Path -Path bin -ChildPath grav)) {
        Invoke-Expression -Command "php $Path $args"
    } else {
        Write-Warning -Message "Grav CLI Application is not available from this directory."
    }
}
New-Alias -Name grav -Value GetGravGrav

function GetGravGPM {
    if (Test-Path -Path ($Path = Join-Path -Path bin -ChildPath gpm)) {
        Invoke-Expression -Command "php $Path $args"
    } else {
        Write-Warning -Message "Grav Package Manager is not available from this directory."
    }
}
New-Alias -Name gpm -Value GetGravGPM

function LaravelArtisan {
    if (Test-Path -Path artisan) {
        Invoke-Expression -Command "php artisan $args"
    } else {
        Write-Warning -Message "Laravel Artisan Console is not available from this directory."
    }
}
New-Alias -Name artisan -Value LaravelArtisan

function PhpServerPhpServer {
    Param(
        [String]
        $Hostname = 'localhost',
        [Int16]
        $Port = 80,
        [String]
        $RouterScript = ''
    )
    $Uri = "${Hostname}:$Port"
    OpenUri -Uri "http://$Uri"
    Invoke-Expression -Command "php -S $Uri $RouterScript"
}
New-Alias -Name phpserver -Value PhpServerPhpServer

function PHPUnitPHPUnit {
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
New-Alias -Name phpunit -Value PHPUnitPHPUnit

function SymfonyConsole {
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
New-Alias -Name console -Value SymfonyConsole