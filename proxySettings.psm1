function SettingProxy ([string] $state) {
    $proxy = 'http://proxy.arteveldehs.be:8080'
    $noProxy = 'localhost,0.0.0.0,127.0.0.1,.local'
    $proxyVariables = @('HTTP_PROXY', 'HTTPS_PROXY', 'FTP_PROXY')
    $noProxyVariables = @('NO_PROXY')
    switch ($state) {
        'off' {}
        'on' {
# system_profiler SPAirPortDataType | awk -F':' '/Current Network Information:/ {
#     getline
#     sub(/^ */, "")
#     sub(/:$/, "")
#     print
# }'
        }
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
        if ($state -eq 'on') {
            foreach ($variable in $proxyVariables) {
                foreach ($var in @($variable.ToUpper(), $variable.ToLower())) {
                    Set-Item -Path env:$var -Value $proxy
                }
            }
            foreach ($variable in $noProxyVariables) {
                foreach ($var in @($variable.ToUpper(), $variable.ToLower())) {
                    Set-Item -Path env:$var -Value $noproxy
                }
            }
        } elseif ($state -eq 'off') {
            foreach ($variable in ($proxyVariables + $noProxyVariables)) {
                foreach ($var in @($variable.ToUpper(), $variable.ToLower())) {
                    Remove-Item -Path env:$var
                }
            }
        }
    } elseif ($IsWindows) {
        Write-Host ' Proxy settings for Windows. ' -BackgroundColor Blue -ForegroundColor White
    } elseif ($IsLinux) {
        Write-Host ' Proxy settings for Linux. ' -BackgroundColor Blue -ForegroundColor White
    } else {
        Write-Warning 'Could not identify operating system.'
    }
}
New-Alias -Name proxy -Value SettingProxy