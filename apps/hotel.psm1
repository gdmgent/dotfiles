if ($IsMacOS) {
    Set-Variable -Name HotelPort -Value '$PORT' -Option Constant -Scope Global
} elseif ($IsWindows) {
    Set-Variable -Name HotelPort -Value '%PORT%' -Option Constant -Scope Global
}

function HotelServerAliases {
    Get-Alias -Name hs* | Select-Object -Property Name, ReferencedCommand
}
New-Alias -Name hs -Value HotelServerAliases

function HotelServerAddDrush {
    Param(
        [String]
        $Name
    )
    if ($Name) {
        $Name = " --name $Name"
    }
    Invoke-Expression -Command "hotel add 'drush runserver localhost:${HotelPort}'$Name"
}
New-Alias -Name hsd -Value HotelServerAddDrush

function HotelServerAddJekyll {
    Param(
        [String]
        $Name,

        [String]
        $BaseUrl = '',

        [Switch]
        $Incremental
    )
    if ($Name) {
        $Name = " --name $Name"
    }
    $Options = ' --unpublished'
    if ($Incremental) {
        $Options += ' --incremental'
    }
    Invoke-Expression -Command "hotel add 'bundle exec jekyll serve --port=${HotelPort} --baseurl=${BaseUrl}${Options}'$Name"
}
New-Alias -Name hsj -Value HotelServerAddJekyll

function HotelServerAddLaravel {
    Param(
        [String]
        $Name
    )
    if ($Name) {
        $Name = " --name $Name"
    }
    Invoke-Expression -Command "hotel add 'php artisan serve --port=${HotelPort}'$Name"
}
New-Alias -Name hsl -Value HotelServerAddLaravel

function HotelServerAddPhp {
    Param(
        [String]
        $Name
    )
    if ($Name) {
        $Name = " --name $Name"
    }
    Invoke-Expression -Command "hotel add 'php -S 127.0.0.1:${HotelPort}'$Name"
}
New-Alias -Name hsp -Value HotelServerAddPhp

function HotelServerAddSymfony {
    Param(
        [String]
        $Name
    )
    if ($Name) {
        $Name = " --name $Name"
    }
    Invoke-Expression -Command "hotel add 'php bin/console server:run 127.0.0.1:${HotelPort}'$Name"
}
New-Alias -Name hss -Value HotelServerAddSymfony
