function SettingProxy () {
    param(
        [ValidateSet('on', 'off')]
        [string]
        $State
    )
    $flag = "$HOME/.proxy"
    Write-Host ' Artevelde University College Ghent proxyserver settings. ' -BackgroundColor Blue -ForegroundColor White

    if (!$State) {
        Write-Host 'Proxyserver settings are ' -NoNewline
        if (Test-Path $flag) {
            Write-Host 'on.' -ForegroundColor Green
        } else {
            Write-Host 'off.' -ForegroundColor Red
        }
        return
    }

    $proxyVariables = @('HTTP_PROXY', 'HTTPS_PROXY', 'FTP_PROXY')
    $noProxyVariables = @('NO_PROXY')
    if ($State.Equals('on')) {
        $proxy = 'http://proxy.arteveldehs.be:8080'
        $noProxy = 'localhost,0.0.0.0,127.0.0.1,.local'
        New-Item -Path $flag -Type File -Value 'Artevelde Dotfiles: this file flags that proxyserver settings should be applied' -Force | Out-Null

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

        Write-Host 'Proxyserver settings are now ' -NoNewline
        Write-Host 'on.' -ForegroundColor Green

    } else {
        foreach ($variable in ($proxyVariables + $noProxyVariables)) {
            foreach ($var in @($variable.ToUpper(), $variable.ToLower())) {
                Remove-Item -Path env:$var
            }
        }
        Remove-Item -Path $flag
        Write-Host 'Proxyserver settings are now ' -NoNewline
        Write-Host 'off.' -ForegroundColor Red
    }

# system_profiler SPAirPortDataType | awk -F':' '/Current Network Information:/ {
#     getline
#     sub(/^ */, "")
#     sub(/:$/, "")
#     print
# }'

}
New-Alias -Name proxy -Value SettingProxy