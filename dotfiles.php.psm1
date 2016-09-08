# Import-Module ./dotfiles.php.psm1

function Behat {
    if (Test-Path bin/behat) {
        php bin/behat "$args"
    } elseif (Test-Path vendor/bin/behat) {
        php vendor/bin/behat "$args"
    } elseif (Get-Command behat -errorAction SilentlyContinue) {
        behat "$args"
    } else {
        Write-Warning -Message "Behat is not available from this directory, nor is it installed globally."
    }
}
New-Alias -Name behat -Value Behat

function LaravelArtisan {
    if (Test-Path artisan) {
        php artisan "$args"
    } else {
        Write-Warning -Message "Laravel Artisan Console is not available from this directory."
    }
}
New-Alias -Name artisan -Value LaravelArtisan

function PHPUnit {
    if (Test-Path bin/phpunit) {
        php bin/phpunit "$args"
    } elseif (Test-Path vendor/bin/phpunit) {
        php vendor/bin/phpunit "$args"
    } elseif (Get-Command phpunit -errorAction SilentlyContinue) {
        phpunit "$args"
    } else {
        Write-Warning -Message "PHPUnit is not available from this directory, nor is it installed globally."
    }
}
New-Alias -Name phpunit -Value PHPUnit

function SymfonyConsole {
    if (Test-Path bin/console) {
        # Symfony 3.*.*
        php bin/console "$args"
    } elseif (Test-Path app/console) {
        # Symfony 2.*.*
        php app/console "$args"
    } else {
        Write-Warning -Message "Symfony Console is not available from this directory."
    }
}
New-Alias -Name console -Value SymfonyConsole