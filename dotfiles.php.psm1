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
    } elseif (Get-Command behat -Type Application -ErrorAction SilentlyContinue) {
        Invoke-Expression -Command ((Get-Command -Name behat -Type Application).Source + " $args")
    } else {
        Write-Warning -Message "Behat is not available from this directory, nor is it installed globally."
    }
}
New-Alias -Name behat -Value BehatBehat

function LaravelArtisan {
    if (Test-Path -Path artisan) {
        Invoke-Expression -Command "php artisan $args"
    } else {
        Write-Warning -Message "Laravel Artisan Console is not available from this directory."
    }
}
New-Alias -Name artisan -Value LaravelArtisan

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
    } elseif (Get-Command phpunit -Type Application -ErrorAction SilentlyContinue) {
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