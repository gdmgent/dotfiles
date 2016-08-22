function ProxySettings ([string] $state) {
    switch ($state) {
        'off' {}
        'on' {}
        'state' {}
        Default {
            Write-Warning 'Missing required parameter.'
            Write-Host -ForegroundColor DarkGray 'Usage:'
            Write-Host -ForegroundColor DarkGray '  proxy off'
            Write-Host -ForegroundColor DarkGray '  proxy on'
            Write-Host -ForegroundColor DarkGray '  proxy state'
            return
        }
    }

    if ($IsOSX) {
        Write-Host ' Proxy settings for macOS. ' -BackgroundColor Blue -ForegroundColor White
    } elseif ($IsWindows) {
        Write-Host ' Proxy settings for Windows. ' -BackgroundColor Blue -ForegroundColor White
    } elseif ($IsLinux) {
        Write-Host ' Proxy settings for Linux. ' -BackgroundColor Blue -ForegroundColor White
    } else {
        Write-Warning 'Could not identify operating system.'
    }
}
New-Alias -Name proxy -Value ProxySettings