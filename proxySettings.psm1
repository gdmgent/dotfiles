function ProxySettings ([string] $state) {
    switch ($state) {
        "off" {}
        "on" {}
        "state" {}
        Default {
            Write-Warning "Error: missing required parameter."
            Write-Host "Usage:"
            Write-Host "  proxy off"
            Write-Host "  proxy on"
            Write-Host "  proxy state"
            return
        }
    }

    if (TestMacOS) {
        Write-Host "Proxy settings for macOS"

    } elseif (TestWindows) {
        Write-Host "Proxy settings for Windows"

    } else {
        Write-Warning "Could not identify operating system."
    }
}
New-Alias -Name proxy -Value ProxySettings