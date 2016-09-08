# Import-Module ./dotfiles.proxysettings.psm1

Set-Variable -Name InternetSettingsRegKey -Value 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings'
Set-Variable -Name ProxyKeys -Value @('HTTP_PROXY', 'HTTPS_PROXY', 'FTP_PROXY') -Option Constant -Scope Global
Set-Variable -Name ProxyValues -Value 'http://proxy.arteveldehs.be:8080' -Option Constant -Scope Global
Set-Variable -Name NoProxyKeys -Value @('NO_PROXY') -Option Constant -Scope Global
Set-Variable -Name NoProxyValues -Value 'localhost,0.0.0.0,127.0.0.1,.local' -Option Constant -Scope Global

#Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment' -Name 'Path'
# Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment' -Name Test -Value $null
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
    Param(
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
            Set-Item -Path Env:$Variable -Value $Global:ProxyValues
        }
    }
    foreach ($Key in $Global:NoProxyKeys) {
        foreach ($Variable in @($Key.ToUpper(), $Key.ToLower())) {
            Set-Item -Path Env:$Variable -Value $Global:NoProxyValues
        }
    }
    if ($IsWindows) {
        $CurrentProxyServer = Get-ItemProperty -Path $InternetSettingsRegKey -Name ProxyServer -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $InternetSettingsRegKey -Name ProxyEnable -Value 1
        Set-ItemProperty -Path $InternetSettingsRegKey -Name ProxyServer -Value $Global:ProxyValues
    }
}

function TurnProxyOff {
    foreach ($Key in ($Global:ProxyKeys + $Global:NoProxyKeys)) {
        foreach ($Variable in @($Key.ToUpper(), $Key.ToLower())) {
            if (Test-Path Env:$Variable) {
                Remove-Item -Path Env:$Variable
            }
        }
    }
    if ($IsWindows) {
        $CurrentProxyServer = Get-ItemProperty -Path $InternetSettingsRegKey -Name ProxyServer -ErrorAction SilentlyContinue
        Set-ItemProperty    -Path $InternetSettingsRegKey -Name ProxyEnable -value 0
        Remove-ItemProperty -Path $InternetSettingsRegKey -Name ProxyServer
    }
}