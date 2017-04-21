if ($IsOSX) {
    Set-Variable -Name HotelPort -Value '$PORT' -Option Constant -Scope Global
} elseif ($IsWindows) {
    Set-Variable -Name HotelPort -Value '%PORT%' -Option Constant -Scope Global
}

function AddJekyllToHotel {
    Invoke-Expression -Command "hotel add 'bundle exec jekyll serve --port=${HotelPort} --baseurl='"
}
New-Alias -Name hj -Value AddJekyllToHotel

function AddLaravelToHotel {
    Invoke-Expression -Command "hotel add 'php artisan serve --port=${HotelPort}'"
}
New-Alias -Name hl -Value AddLaravelToHotel

function AddPhpToHotel {
    Invoke-Expression -Command "hotel add 'php -S localhost:${HotelPort}'"
}
New-Alias -Name hp -Value AddPhpToHotel

function AddSymfonyToHotel {
    Invoke-Expression -Command "hotel add 'php bin/console server:start 127.0.0.1:${HotelPort}'"
}
New-Alias -Name hs -Value AddSymfonyToHotel
