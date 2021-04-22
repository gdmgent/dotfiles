if ($IsMacOS) {
    New-Alias -Name node -Value Node -Scope Global
    Set-Variable -Name NodeJsPath -Value "${HOME}/.nvm/versions/node" -Option Constant -Scope Global
}

# Node Version Manager
function nvm {
    if ($IsMacOS) {
        Invoke-Expression "sh -c 'export NVM_DIR=~/.nvm && source $(brew --prefix nvm)/nvm.sh && nvm ${args}'"
    } elseif ($IsWindows) {
        nvm.exe $args
    }
}

function InitNode {
    if ($IsMacOS) {
        $Version = ReadConfig -Name Node
        if ($Version) {
            SetNode -Version $Version
        }
    }
}

function InstallNode {
    if ($IsMacOS) {
        WriteMessage -Type Info -Message "Using NVM to install Node.js..."
        # nvm install
        nvm install --lts
    } elseif ($IsWindows) {
        # $Latest = (($(nvm list available) | Select-Object -Index 3).Split('|') | Select-Object -Index 1).Trim()
        $Latest = (($(nvm list available) | Select-Object -Index 3).Split('|') | Select-Object -Index 2).Trim()
        WriteMessage -Type Info -Message "Using NVM to install Node.js ${Latest}..."
        nvm.exe install $Latest
    }
}

function SetNode {
    Param(
        [Parameter(Mandatory=$true)]
        [String]
        $Version
    )
    if ($IsMacOS) {
        $Versions = (Get-ChildItem $NodeJsPath).Name
        if ($Versions -contains "${Version}") {
            $nodePath = "${NodeJsPath}/${Version}/bin"
            if (Test-Path -Path $nodePath) {
                WriteConfig -Name Node -Value $Version
                nvm alias default $Version
                $env:PATH = @($nodePath, $env:PATH) -join [io.path]::PathSeparator
                Set-Alias -Name node -Value $(Get-Command -Name node -Type Application | Select-Object -First 1).Source -Scope Global
            } else {
                WriteConfig -Name Node -Value $null
            }
            return
        }
    } elseif ($IsWindows) {
        $Versions = nvm.exe list | Select-String -Pattern '(\d+(.\d+){2})' | ForEach-Object { ($_.Matches).Value }
        if ($Versions -contains "${Version}") {
            WriteConfig -Name Node -Value $Version
            nvm.exe use $Version
            return
        }
    }
    WriteConfig -Name Node -Value $null
    WriteMessage -Type Warning -Message "Version '${Version}' of Node.js is not installed. Please install with nvm."
}

function UseNode {
    Param(
        [ValidateSet(14, 15, 16)]
        [Int16]
        $Version = 14
    )
    if ($IsMacOS) {
        $NodeVersion = $(nvm version $Version)
    } elseif ($IsWindows) {
        $NodeVersion = nvm.exe list | Select-String -Pattern "(${Version}(.\d+){2})" -AllMatches | ForEach-Object { ($_.Matches).Value } | Select-Object -First 1
    }
    if ($NodeVersion) {
        SetNode -Version $NodeVersion
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
    if (Test-Path -Path ($Path = [io.path]::Combine('.', 'node_modules', '.bin', 'webpack'))) {
        Invoke-Expression -Command "${Path} ${args}"
    } elseif (ExistCommand -Name webpack) {
        Invoke-Expression -Command ((Get-Command -Name webpack -Type Application).Source + " ${args}")
    } else {
        WriteMessage -Type Warning -Message 'Webpack is not available from this directory, nor is it installed globally.'
    }
}
New-Alias -Name webpack -Value WebpackCommand

InitNode