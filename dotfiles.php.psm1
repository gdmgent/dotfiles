function BehatBehat {
    if (Test-Path ($Path = Join-Path -Path bin -ChildPath behat)) {
        php $Path "$args"
    } elseif (Test-Path ($Path = Join-Path -Path vendor -ChildPath $Path)) {
        php $Path "$args"
    } elseif (Get-Command behat -Type Application -ErrorAction SilentlyContinue) {
        Invoke-Expression ((Get-Command -Name behat -Type Application).Source + " $args")
    } else {
        Write-Warning -Message "Behat is not available from this directory, nor is it installed globally."
    }
}
New-Alias -Name behat -Value BehatBehat

function LaravelArtisan {
    if (Test-Path artisan) {
        php artisan "$args"
    } else {
        Write-Warning -Message "Laravel Artisan Console is not available from this directory."
    }
}
New-Alias -Name artisan -Value LaravelArtisan

function PHPUnitPHPUnit {
    if (Test-Path ($Path = Join-Path -Path bin -ChildPath phpunit)) {
        php $Path "$args"
    } elseif (Test-Path ($Path = Join-Path -Path vendor -ChildPath $Path)) {
        php $Path "$args"
    } elseif (Get-Command phpunit -Type Application -ErrorAction SilentlyContinue) {
        Invoke-Expression ((Get-Command -Name phpunit -Type Application).Source + " $args")
    } else {
        Write-Warning -Message "PHPUnit is not available from this directory, nor is it installed globally."
    }
}
New-Alias -Name phpunit -Value PHPUnitPHPUnit

function SymfonyConsole {
    if (Test-Path ($PathBin = Join-Path -Path bin -ChildPath console)) {
        # Symfony 3.*.*
        php $PathBin "$args"
    } elseif (Test-Path ($PathApp = Join-Path -Path app -ChildPath console)) {
        # Symfony 2.*.*
        php $PathApp "$args"
    } else {
        Write-Warning -Message "Symfony Console is not available from this directory."
    }
}
New-Alias -Name console -Value SymfonyConsole