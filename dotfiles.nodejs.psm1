New-Alias -Name node -Value Node -Scope Global

Set-Variable -Name NodeJsPath -Value "$HOME/.nvm/versions/node/" -Option Constant -Scope Global

# Node Version Manager
function nvm {
    if ($IsOSX) {
        Invoke-Expression "sh -c 'export NVM_DIR=~/.nvm && source $(brew --prefix nvm)/nvm.sh && nvm $args'"
    }
}

function InitNode {
    if ($IsOSX) {
        $Version = ReadConfig -Name Node
        UseNode -Version $Version
    }
}

function UseNode4 {
    $nodeVersion = 4
    $Version = (Get-ChildItem $NodeJsPath).Name | Where-Object { $_ -match "v$nodeVersion.\d.\d" } | Sort-Object -Descending | Select-Object -First 1  
    UseNode -Version $Version
}

function UseNode6 {
    $nodeVersion = 6
    $Version = (Get-ChildItem $NodeJsPath).Name | Where-Object { $_ -match "v$nodeVersion.\d.\d" } | Sort-Object -Descending | Select-Object -First 1  
    UseNode -Version $Version
}

function UseNode([string] $Version) {
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
            Write-Error -Message "Version '$Version' of Node.js is not installed. Please install with nvm."
        }
    }
}

function ShowNode {
    $Version = ReadConfig -Name Node
    Write-Host 'Node.js is currently version ' -NoNewline
    if ($Version) {
        Write-Host $Version -ForegroundColor Green -NoNewline
    } else {
        Write-Host 'Undefined' -ForegroundColor Blue -NoNewline
    }
    Write-Host '.'
}