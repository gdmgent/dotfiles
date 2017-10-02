if ($IsMacOS) {
    New-Alias -Name node -Value Node -Scope Global
    Set-Variable -Name NodeJsPath -Value "$HOME/.nvm/versions/node" -Option Constant -Scope Global
}

# Node Version Manager
function nvm {
    if ($IsMacOS) {
        Invoke-Expression "sh -c 'export NVM_DIR=~/.nvm && source $(brew --prefix nvm)/nvm.sh && nvm $args'"
    } elseif ($IsWindows) {
        nvm.exe $args
    }
}

function NpmConfigProxy {
    Param(
        [Switch]
        $Off,
        [Switch]
        $On
    )
    $Proxy = 'http://proxy.arteveldehs.be:8080'
    $Keys = @('proxy','https-proxy')
    foreach ($Key in $Keys) {
        if ($Off) {
            npm config delete $Key
        } elseif ($On) {
            npm config set $Key "$Proxy"
        } else {
            WriteMessage -Message "${Key}: " -NoNewline
            npm config get $Key
        }
    }
}

function InitNode {
    if ($IsMacOS) {
        $Version = ReadConfig -Name Node
        if ($Version) {
            UseNode -Version $Version
        }
    }
}

function InstallNode {
    if ($IsMacOS) {
        nvm install stable
    } elseif ($IsWindows) {
        nvm install latest
    }
}

function UseNode8 {
    $NodeVersion = 8
    if ($IsMacOS) {
        # $Version = (Get-ChildItem $NodeJsPath).Name | Where-Object { $_ -match "(v$NodeVersion(.\d+){2})" } | Select-Object -Last 1
        $Version = "$(nvm current)"
    } elseif ($IsWindows) {
        $Version = nvm.exe list | Select-String -Pattern "($NodeVersion(.\d+){2})" -AllMatches | ForEach-Object { ($_.Matches).Value } | Select-Object -First 1
    }
    if ($Version) {
        UseNode -Version $Version
    }
}

function UseNode {
    Param(
        [Parameter(Mandatory=$true)]
        [String]
        $Version
    )
    if ($IsMacOS) {
        $Versions = (Get-ChildItem $NodeJsPath).Name
        switch ($Version) {
            { $Versions -contains "$Version" } {
                $nodePath = "$NodeJsPath/$Version/bin"
                if (Test-Path $nodePath) {
                    WriteConfig -Name Node -Value $Version
                    $env:PATH = @($nodePath, $env:PATH) -join ':'
                    Set-Alias -Name node -Value $(Get-Command -Name node -Type Application | Select-Object -First 1).Source -Scope Global
                } else {
                    WriteConfig -Name Node -Value $null
                }
            }
            Default {
                WriteConfig -Name Node -Value $null
                WriteMessage -Type Warning -Message "Version '$Version' of Node.js is not installed. Please install with nvm."
            }
        }
    } elseif ($IsWindows) {
        $Versions = nvm.exe list | Select-String -Pattern '(\d+(.\d+){2})' | ForEach-Object { ($_.Matches).Value }
        switch ($Version) {
            { $Versions -contains "$Version" } {
                WriteConfig -Name Node -Value $Version
                nvm.exe use $Version
            }
            Default {
                WriteConfig -Name Node -Value $null
                WriteMessage -Type Warning -Message "Version '$Version' of Node.js is not installed. Please install with nvm."
            }
        }
    }
}

function ShowNodeConfig {
    $Version = ReadConfig -Name Node
    WriteMessage -Type Info -Message 'Node.js is currently version ' -NoNewline
    if ($Version) {
        WriteMessage -Type Success -Message $Version -NoNewline
    } else {
        WriteMessage -Type Warning -Message 'Undefined' -NoNewline
    }
    WriteMessage -Message '.'
}

function WebpackCommand {
    if (Test-Path -Path ($Path = [io.path]::combine('.', 'node_modules', '.bin', 'webpack'))) {
        Invoke-Expression -Command "$Path $args"    
    } elseif (ExistCommand -Name webpack) {
        Invoke-Expression -Command ((Get-Command -Name webpack -Type Application).Source + " $args")
    } else {
        WriteMessage -Type Warning -Message "Webpack is not available from this directory, nor is it installed globally."
    }
}
New-Alias -Name webpack -Value WebpackCommand

InitNode