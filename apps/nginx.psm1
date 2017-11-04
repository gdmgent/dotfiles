function NginxServeCommand {
    Param(
        [ValidateSet('Edit', 'Force-Stop', 'Reload', 'Start', 'Stop')]
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
            }
            Invoke-Expression -Command $Expression
        }
        'Stop' {
            $Expression = 'nginx -s quit'
            if ($IsMacOS) {
                Invoke-Expression -Command "sudo ${Expression}"
            } elseif ($IsWindows) {
                Invoke-Expression -Command $Expression
                Get-Job -Name 'nginx-job' -ErrorAction SilentlyContinue | Stop-Job
            }
            Get-Job -Name 'php-job' -ErrorAction SilentlyContinue | Stop-Job
        }
        Default {
            WriteMessage -Type Info -Message 'Starting NGINX for ports 80 and 443 with PHP CGI on port 9999'
            Start-Job -Name 'php-job' -ScriptBlock {
                php-cgi -b 127.0.0.1:9999
            } | Out-Null
            if ($IsMacOS) {
                sudo nginx -c $NginxConfig
            } elseif ($IsWindows) {
                Start-Job -Name 'nginx-job' -ScriptBlock {
                    Set-Location \nginx
                    nginx -c $NginxConfig
                }
            }
        }
    }
}
New-Alias -Name nginxserve -Value NginxServeCommand

function ConfigureNginxSite {
    Param(
        [String]
        $DomainName
    )
    $AcceptedParentDirectories = @(
        'Code',
        'CodeCollege',
        'CodeStudent',
        'CodeTest'
    )
    $Directories = $ExecutionContext.SessionState.Path.CurrentLocation.Path -split [io.path]::DirectorySeparatorChar
    if (! ($Directories.Length -gt 2 -and $AcceptedParentDirectories -contains $Directories[-2])) {
        WriteMessage -Type Danger -Message 'This command cannot be executed in this directory.'
        return
    }
    if (Test-Path -Path drupal -PathType Container) {
        $Directories += 'drupal'
        $SourceFileName = 'nginx-drupal.conf'
    } else {
        WriteMessage -Type Warning -Message 'No configurable site found.'
        return
    }
    $WebRootDirectory = $Directories -join '/'
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
        @('»HOME-DIRECTORY«'        , $HOME),
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
        'college',
        'student',
        'test'
    )
    $Domains = @(
        'cms',
        'csse',
        'cmsdev',
        'webdev1',
        'webdev2',
        'nmtech1',
        'nmtech2'
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