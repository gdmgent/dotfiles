function NginxCommand {
    $Command = 'nginx'
    if ($args.count) {
        Push-Location \nginx
        nginx.exe $args
        Pop-Location
    } else {
        WriteMessage -Type Info -Message 'Starting NGINX for ports 80 and 443 with PHP CGI on port 9999'
        if ((Get-Process -Name $Command -ErrorAction Ignore).count -le 0) {
            Start-Job -Name 'php-job' -ScriptBlock {
                php-cgi -b 127.0.0.1:9999
            }
            if ($IsWindows) {
                if ((ExistCommand -Name nginx) -and (Test-Path $HOME\.dotfiles\nginx.conf)) {
                    Start-Job -Name 'nginx-job' -ScriptBlock {
                        Set-Location \nginx
                        nginx.exe -c $HOME\.dotfiles\nginx.conf
                    }
                } else {
                    Message -Type Warning -Message 'NGINX is not correctly installed or configured.'
                }
            }
        }
    }
}
New-Alias -Name nginx -Value NginxCommand