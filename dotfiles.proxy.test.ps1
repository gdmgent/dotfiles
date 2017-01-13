class Proxy
{
    # Properties

    static [array] $A


    # Methods

    static Init() {
        $State = ReadConfig -Name Proxy
        switch ($State) {
            'on' {
                [Proxy]::On()
            }
            'off' {
                [Proxy]::Off()
            }
            Default {
                [Proxy]::Show()
            }
        }
    }

    static Off() {
        Write-Host 'proxy off'
    }

    static On() {
        Write-Host 'proxy on'
    }

    static Set() {
    
    }

    static Show() {
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
}