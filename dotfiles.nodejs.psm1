if ($IsOSX) {
    New-Alias -Name node -Value Node -Scope Global
    Set-Variable -Name NodeJsPath -Value "$HOME/.nvm/versions/node" -Option Constant -Scope Global
}

# Node Version Manager
function nvm {
    if ($IsOSX) {
        Invoke-Expression "sh -c 'export NVM_DIR=~/.nvm && source $(brew --prefix nvm)/nvm.sh && nvm $args'"
    } elseif ($IsWindows) {
        nvm.exe $args
    }
}

function InitNode {
    if ($IsOSX) {
        $Version = ReadConfig -Name Node
        if ($Version) {
            UseNode -Version $Version
        }
    }
}

function UseNode4 {
    $NodeVersion = 4
    if ($IsOSX) {
        $Version = (Get-ChildItem $NodeJsPath).Name | Where-Object { $_ -match "v$NodeVersion.\d.\d" } | Sort-Object -Descending | Select-Object -First 1
    } elseif ($IsWindows) {
        $Version = nvm.exe list | Select-String -Pattern "$NodeVersion.\d.\d" -AllMatches | % { ($_.Matches).Value } | Sort-Object -Descending | Select-Object -First 1
    }
    if ($Version) {
        UseNode -Version $Version
    }
}

function UseNode6 {
    $NodeVersion = 6
    if ($IsOSX) {
        $Version = (Get-ChildItem $NodeJsPath).Name | Where-Object { $_ -match "v$NodeVersion.\d.\d" } | Sort-Object -Descending | Select-Object -First 1
    } elseif ($IsWindows) {
        $Version = nvm.exe list | Select-String -Pattern "$NodeVersion.\d.\d" -AllMatches | ForEach-Object { ($_.Matches).Value } | Sort-Object -Descending | Select-Object -First 1
    }
    if ($Version) {
        UseNode -Version $Version
    }
}

function UseNode7 {
    $NodeVersion = 7
    if ($IsOSX) {
        $Version = (Get-ChildItem $NodeJsPath).Name | Where-Object { $_ -match "v$NodeVersion.\d.\d" } | Sort-Object -Descending | Select-Object -First 1
    } elseif ($IsWindows) {
        $Version = nvm.exe list | Select-String -Pattern "$NodeVersion.\d.\d" -AllMatches | ForEach-Object { ($_.Matches).Value } | Sort-Object -Descending | Select-Object -First 1
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
    if ($IsOSX) {
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
                Write-Warning -Message "Version '$Version' of Node.js is not installed. Please install with nvm."
            }
        }
    } elseif ($IsWindows) {
        $Versions = nvm.exe list | Select-String -Pattern '\d.\d.\d' | ForEach-Object { ($_.Matches).Value }
        switch ($Version) {
            { $Versions -contains "$Version" } {
                WriteConfig -Name Node -Value $Version
                nvm.exe use $Version
            }
            Default {
                WriteConfig -Name Node -Value $null
                Write-Warning -Message "Version '$Version' of Node.js is not installed. Please install with nvm."
            }
        }
    }
}

function ShowNodeConfig {
    $Version = ReadConfig -Name Node
    Write-Host 'Node.js is currently version ' -NoNewline
    if ($Version) {
        Write-Host $Version -ForegroundColor Green -NoNewline
    } else {
        Write-Host 'Undefined' -ForegroundColor Blue -NoNewline
    }
    Write-Host '.'
}