Set-Variable -Name NoProxyKeys             -Value @('NO_PROXY') -Option Constant -Scope Global
Set-Variable -Name NoProxyKeysVagrant      -Value @('VAGRANT_NO_PROXY') -Option Constant -Scope Global
Set-Variable -Name NoProxyValues           -Value 'localhost,0.0.0.0,127.0.0.1,.local,.localhost,192.168.10.0/8' -Option Constant -Scope Global
Set-Variable -Name ProxyKeys               -Value @('HTTP_PROXY', 'HTTPS_PROXY', 'FTP_PROXY') -Option Constant -Scope Global
Set-Variable -Name ProxyKeysVagrant        -Value @('VAGRANT_HTTP_PROXY', 'VAGRANT_HTTPS_PROXY', 'VAGRANT_FTP_PROXY') -Option Constant -Scope Global
Set-Variable -Name ProxyValues             -Value 'http://proxy.arteveldehs.be:8080' -Option Constant -Scope Global
Set-Variable -Name RegPathInternetSettings -Value 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings' -Option Constant -Scope Global
Set-Variable -Name RegPathEnvironment      -Value 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment' -Option Constant -Scope Global

if (ExistCommand -Name git) {
    Import-Module -Name ([io.path]::Combine($Global:DotfilesInstallPath, 'apps', 'git.psm1'))
}

function InitProxy {
    $State = ReadConfig -Name Proxy
    switch ($State) {
        'off' {
            TurnProxyOff
        }
        'on' {
            TurnProxyOn
        }
        Default {
            ShowProxy
        }
    }
}

function ShowProxy {
    $State = ReadConfig -Name Proxy
    WriteMessage -Type Info -Message 'Proxyserver settings are currently ' -NoNewline
    switch ($State) {
        'off' {
            $Type = 'Danger'
        }
        'on' {
            $Type = 'Success'
        }
        Default {
            $State = "unrecognized (${State})"
            $Type = 'Warning'
        }
    }
    WriteMessage -Type $Type -Inverse -Message $State
}

function SetProxy {
    Param(
        [String]
        [ValidateSet('on', 'off')]
        $State
    )
    $flag = ReadConfig -Name Proxy
    WriteMessage -Type Info -Inverse -Message 'Proxyserver Settings' -NoNewline
    WriteMessage -Type Mute -Message ' for Artevelde University College Ghent'
    if (! $State) {
        ShowProxy
    } else {
        WriteConfig -Name Proxy -Value $State
        InitProxy
        ShowProxy
    }
}
New-Alias -Name proxy -Value SetProxy

function TurnProxyOff {
    if ($IsMacOS) {
        foreach ($Key in ($Global:ProxyKeys + $Global:NoProxyKeys)) {
            foreach ($Variable in @($Key.ToUpper(), $Key.ToLower())) {
                if (Test-Path -Path Env:$Variable) {
                    Remove-Item -Path Env:$Variable
                }
            }
        }
    } elseif ($IsWindows) {
        foreach ($Key in ($Global:ProxyKeys + $Global:NoProxyKeys)) {
            foreach ($Variable in @($Key.ToUpper(), $Key.ToLower())) {
                if (Test-Path -Path Env:$Variable) {
                    Remove-Item -Path Env:$Variable
                }
            }
            foreach ($Variable in @($Key.ToUpper())) {
                Remove-ItemProperty -Path $Global:RegPathEnvironment -Name $Variable -ErrorAction SilentlyContinue
            }
        }
        foreach ($Key in ($Global:ProxyKeysVagrant + $Global:NoProxyKeysVagrant)) {
            foreach ($Variable in @($Key.ToUpper())) {
                Set-ItemProperty -Path $Global:RegPathEnvironment -Name $Variable -Value $null
            }
        }
        $CurrentProxyServer = Get-ItemProperty -Path $Global:RegPathInternetSettings -Name ProxyServer -ErrorAction SilentlyContinue
        Set-ItemProperty    -Path $Global:RegPathInternetSettings -Name ProxyEnable -value 0
        Remove-ItemProperty -Path $Global:RegPathInternetSettings -Name ProxyServer -ErrorAction SilentlyContinue
        # netsh.exe winhttp reset proxy
    }
    if (ExistCommand -Name git) {
        GitConfigProxy -Off
    }
    # if (ExistCommand -Name npm) {
    #     NpmConfigProxy -Off
    # }
}

function TurnProxyOn {
    if ($IsMacOS) {
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
    } elseif ($IsWindows) {
        foreach ($Key in $Global:ProxyKeys + $Global:ProxyKeysVagrant) {
            foreach ($Variable in @($Key.ToUpper(), $Key.ToLower())) {
                Set-Item -Path Env:$Variable -Value $Global:ProxyValues
            }
            foreach ($Variable in @($Key.ToUpper())) {
                Set-ItemProperty -Path $Global:RegPathEnvironment -Name $Variable -Value $Global:ProxyValues
            }
        }
        foreach ($Key in $Global:NoProxyKeys + $Global:NoProxyKeysVagrant) {
            foreach ($Variable in @($Key.ToUpper(), $Key.ToLower())) {
                Set-Item -Path Env:$Variable -Value $Global:NoProxyValues
            }
            foreach ($Variable in @($Key.ToUpper())) {
                Set-ItemProperty -Path $Global:RegPathEnvironment -Name $Variable -Value $Global:NoProxyValues
            }
        }
        $CurrentProxyServer = Get-ItemProperty -Path $Global:RegPathInternetSettings -Name ProxyServer -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $Global:RegPathInternetSettings -Name ProxyEnable -Value 1
        Set-ItemProperty -Path $Global:RegPathInternetSettings -Name ProxyServer -Value $Global:ProxyValues
        # netsh.exe winhttp set proxy proxy-server="http=myproxy;https=sproxy:88" bypass-list="*.foo.com"
    }
    if (ExistCommand -Name git) {
        GitConfigProxy -On
    }
    # if (ExistCommand -Name npm) {
    #     NpmConfigProxy -On
    # }
}

function OpenProxySettings {
    if ($IsMacOS) {
        $Command = @'
tell application \"System Preferences\"
    activate
    set the current pane to pane id \"com.apple.preference.network\"
end tell
'@
        osascript -e $Command
    } elseif ($IsWindows) {
        explorer ms-settings:network-proxy
    }
}

InitProxy