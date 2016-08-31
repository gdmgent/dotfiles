Set-Variable -Name ProxyKeys -Value @('HTTP_PROXY', 'HTTPS_PROXY', 'FTP_PROXY') -Option Constant -Scope Global
Set-Variable -Name ProxyValues -Value 'http://proxy.arteveldehs.be:8080' -Option Constant -Scope Global
Set-Variable -Name NoProxyKeys -Value @('NO_PROXY') -Option Constant -Scope Global
Set-Variable -Name NoProxyValues -Value 'localhost,0.0.0.0,127.0.0.1,.local' -Option Constant -Scope Global


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
}
New-Alias -Name proxy -Value SetProxy

function TurnProxyOn {
    foreach ($Key in $Global:ProxyKeys) {
        foreach ($Variable in @($Key.ToUpper(), $Key.ToLower())) {
            Set-Item -Path env:$Variable -Value $Global:ProxyValues
        }
    }
    foreach ($Key in $Global:NoProxyKeys) {
        foreach ($Variable in @($Key.ToUpper(), $Key.ToLower())) {
            Set-Item -Path env:$Variable -Value $Global:NoProxyValues
        }
    }
}

function TurnProxyOff {
    foreach ($Key in ($Global:ProxyKeys + $Global:NoProxyKeys)) {
        foreach ($Variable in @($Key.ToUpper(), $Key.ToLower())) {
            if (Test-Path env:$Variable) {
                Remove-Item -Path env:$Variable
            }
        }
    }
}