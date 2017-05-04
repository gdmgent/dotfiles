if ($IsOSX) {
    Set-Variable -Name HotelPort -Value '$PORT' -Option Constant -Scope Global
} elseif ($IsWindows) {
    Set-Variable -Name HotelPort -Value '%PORT%' -Option Constant -Scope Global
}

function AddDrushToHotel {
    Param(
        [String]
        $Name
    )
    if ($Name) {
        $Name = " --name $Name"
    }
    Invoke-Expression -Command "hotel add 'drush runserver localhost:${HotelPort}'$Name"
}
New-Alias -Name hd -Value AddDrushToHotel

function AddJekyllToHotel {
    Param(
        [String]
        $Name
    )
    if ($Name) {
        $Name = " --name $Name"
    }
    Invoke-Expression -Command "hotel add 'bundle exec jekyll serve --port=${HotelPort} --baseurl= --unpublished'$Name"
}
New-Alias -Name hj -Value AddJekyllToHotel

function AddLaravelToHotel {
    Param(
        [String]
        $Name
    )
    if ($Name) {
        $Name = " --name $Name"
    }
    Invoke-Expression -Command "hotel add 'php artisan serve --port=${HotelPort}'$Name"
}
New-Alias -Name hl -Value AddLaravelToHotel

function AddPhpToHotel {
    Param(
        [String]
        $Name
    )
    if ($Name) {
        $Name = " --name $Name"
    }
    Invoke-Expression -Command "hotel add 'php -S localhost:${HotelPort}'$Name"
}
New-Alias -Name hp -Value AddPhpToHotel

function AddSymfonyToHotel {
    Param(
        [String]
        $Name
    )
    if ($Name) {
        $Name = " --name $Name"
    }
    Invoke-Expression -Command "hotel add 'php bin/console server:start 127.0.0.1:${HotelPort}'$Name"
}
New-Alias -Name hs -Value AddSymfonyToHotel
