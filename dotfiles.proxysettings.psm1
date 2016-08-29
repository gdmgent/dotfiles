function InitProxy() {
    $State = ReadConfig -Name Proxy
    switch ($State) {
        'on' {
            TurnProxyOn
        }
        'off' {
            TurnProxyOff
        }
        Default {
            ShowProxy
        }
    }
}

function ShowProxy {
    $State = ReadConfig -Name Proxy
    Write-Host 'Proxyserver settings are currently ' -NoNewline
    switch ($State) {
        'on' {
            Write-Host $State -ForegroundColor Green -NoNewline
        }
        'off' {
            Write-Host $State -ForegroundColor Red -NoNewline
        }
        Default {
            Write-Host "unrecognized ($State)" -ForegroundColor Blue -NoNewline
        }
    }
    Write-Host '.'
}

function SetProxy {
    param(
        [ValidateSet('on', 'off')]
        [string]
        $State
    )
    $flag = ReadConfig -Name Proxy
    Write-Host ' Artevelde University College Ghent proxyserver settings. ' -BackgroundColor Blue -ForegroundColor White

    if (!$State) {
        ShowProxy
    } else {
        WriteConfig -Name Proxy -Value $State
        InitProxy
        ShowProxy
    }

# system_profiler SPAirPortDataType | awk -F':' '/Current Network Information:/ {
#     getline
#     sub(/^ */, "")
#     sub(/:$/, "")
#     print
# }'

}
New-Alias -Name proxy -Value SetProxy

function TurnProxyOn {
    $proxyVariables = @('HTTP_PROXY', 'HTTPS_PROXY', 'FTP_PROXY')
    $noProxyVariables = @('NO_PROXY')
    $proxy = 'http://proxy.arteveldehs.be:8080'
    $noProxy = 'localhost,0.0.0.0,127.0.0.1,.local'
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
}

function TurnProxyOff {
    $proxyVariables = @('HTTP_PROXY', 'HTTPS_PROXY', 'FTP_PROXY')
    $noProxyVariables = @('NO_PROXY')
        foreach ($variable in ($proxyVariables + $noProxyVariables)) {
        foreach ($var in @($variable.ToUpper(), $variable.ToLower())) {
            if (Test-Path env:$var) {
                Remove-Item -Path env:$var
            }
        }
    }
}