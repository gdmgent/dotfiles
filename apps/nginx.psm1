function ServeNginx {
    Param(
        [ValidateSet('Edit', 'Force-Stop', 'Reload', 'Start', 'Status', 'Stop')]
        [String]
        $Command = 'Start'
    )
    $NginxConfig = [io.path]::Combine($HOME, '.dotfiles', 'nginx.conf')
    if (! ((ExistCommand -Name nginx) -and (Test-Path $NginxConfig))) {
        Message -Type Warning -Message 'NGINX is not correctly installed or configured.'
    }
    switch ($Command) {
        'Edit' {
            code ([io.path]::Combine($HOME, '.dotfiles', 'sites-enabled'))
        }
        'Force-Stop' {
            $Expression = 'Get-Process -Name nginx -ErrorAction SilentlyContinue | Stop-Process'
            if ($IsMacOS) {
                sudo pwsh -c $Expression
            } elseif ($IsWindows) {
                Invoke-Expression -Command $Expression
            }
        }
        'Reload' {
            $Expression = 'nginx -s reload'
            if ($IsMacOS) {
                $Expression = "sudo ${Expression}"
                Invoke-Expression -Command $Expression
            } elseif ($IsWindows) {
                Push-Location \nginx
                Invoke-Expression -Command $Expression
                Pop-Location
            }
        }
        'Status' {
            Get-Job -Name php-job -ErrorAction SilentlyContinue
            Get-Job -Name nginx-job -ErrorAction SilentlyContinue
        }
        'Stop' {
            $Expression = 'nginx -s quit'
            if ($IsMacOS) {
                Invoke-Expression -Command "sudo ${Expression}"
            } elseif ($IsWindows) {
                Push-Location \nginx
                Invoke-Expression -Command $Expression
                Pop-Location
            }
            Get-Job -Name nginx-job -ErrorAction SilentlyContinue | Stop-Job
            Get-Job -Name nginx-job -ErrorAction SilentlyContinue | Remove-Job
            Get-Job -Name php-job -ErrorAction SilentlyContinue | Stop-Job
            Get-Job -Name php-job -ErrorAction SilentlyContinue | Remove-Job
        }
        Default {
            WriteMessage -Type Info -Message 'Starting NGINX for ports 80 and 443 with PHP CGI on port 9999'
            if ($IsMacOS) {
                # Trigger Super User Do login.
                sudo cd .
            }
            Start-Job -Name 'php-job' -ScriptBlock {
                php-cgi -b 127.0.0.1:9999
            } | Out-Null
            $Expression = "nginx -c ${NginxConfig}"
            Start-Job -Name 'nginx-job' -ArgumentList $Expression -ScriptBlock {
                $Expression = $args[0]
                if ($IsMacOS) {
                    Invoke-Expression -Command "sudo ${Expression}"
                } elseif ($IsWindows) {
                    Set-Location \nginx
                    Invoke-Expression -Command $Expression
                }
            } | Out-Null
        }
    }
}
New-Alias -Name nginxserve -Value ServeNginx

function ConfigureNginxSite {
    Param(
        [String]
        $DomainName
    )
    $AcceptedParentDirectories = @(
        'Code',
        'CodeColleges',
        'CodeStudents',
        'CodeTest'
    )
    $Directories = $ExecutionContext.SessionState.Path.CurrentLocation.Path.Split([io.path]::DirectorySeparatorChar)
    if (! ($Directories.Length -gt 2 -and $AcceptedParentDirectories -contains $Directories[-2])) {
        WriteMessage -Type Danger -Message 'This command cannot be executed in this directory.'
        return
    }
    if (Test-Path -Path drupal -PathType Container) {
        $Directories += 'drupal'
        $SourceFileName = 'nginx-drupal.conf'
    } elseif (Test-Path -Path laravel -PathType Container) {
        $Directories += 'laravel/public'
        $SourceFileName = 'nginx-laravel.conf'
    } elseif (Test-Path -Path lumen -PathType Container) {
        $Directories += 'lumen/public'
        $SourceFileName = 'nginx-laravel.conf'
    } else {
        WriteMessage -Type Warning -Message 'No configurable site found.'
        return
    }
    $HomeDirectory = $HOME.Split([io.path]::DirectorySeparatorChar) -join [io.path]::AltDirectorySeparatorChar
    $WebRootDirectory = $Directories -join [io.path]::AltDirectorySeparatorChar
    if ($IsMacOS) {
        $NginxConfigDirectory = (brew --prefix nginx) + '/.bottle/etc/nginx'
    } else {
        $NginxConfigDirectory = '/nginx/conf'
    }
    $DomainName = GenerateDomainName($Directories)
    $SourcePath = [io.path]::Combine($HOME, 'dotfiles', 'settings', $SourceFileName)
    $FileContent = Get-Content -Path $SourcePath
    $Settings = @(
        @('»DOMAIN-NAME«'           , $DomainName),
        @('»HOME-DIRECTORY«'        , $HomeDirectory),
        @('»NGINX-CONFIG-DIRECTORY«', $NginxConfigDirectory),
        @('»WEB-ROOT-DIRECTORY«'    , $WebRootDirectory)
    )
    foreach ($Setting in $Settings) {
        $FileContent = $FileContent.Replace($Setting[0], $Setting[1])
    }
    $DestinationPaths = @($HOME, '.dotfiles', 'sites-enabled')
    $DestinationPath = $DestinationPaths -join [io.path]::DirectorySeparatorChar
    New-Item -Path $DestinationPath -ItemType Directory -Force | Out-Null
    $DestinationFileName = $DomainName.Replace('.', '-') + '.conf'
    $DestinationPaths += $DestinationFileName
    $DestinationPath = $DestinationPaths -join [io.path]::DirectorySeparatorChar
    Set-Content -Path $DestinationPath -Value $FileContent -Force
    WriteMessage -Type Success -Message 'Create new site for ' -NoNewLine
    WriteMessage -Type Strong -Message "http://${DomainName}"
}

function GenerateDomainName($Directories) {
    $SubDomains = @(
        'colleges',
        'students',
        'test'
    )
    $Domains = @(
        'cms',
        'cmsdev',
        'csse',
        'nmtech1',
        'nmtech2',
        'webdev1',
        'webdev2'
    )
    $DomainName = '.localhost';
    foreach ($Domain in $Domains) {
        if ($Directories[-2] -match "-$Domain-") {
            $DomainName = $Domain + $DomainName
            foreach ($SubDomain in $Subdomains) {
                if ($Directories[-3] -match "Code${SubDomain}") {
                    return "${SubDomain}.${DomainName}"
                }
            }
            return $DomainName
        }
    }
    return $DirectoryName.ToLower() + $DomainName
}