# Import-Module aliasesVagrant.psm1

function AliasCode {
    GoToPath "~/Code/$args"
}
New-Alias -Name c -Value AliasCode -Description "Go to ~/Code"

function AliasHome {
    GoToPath "~/$args"
}
New-Alias -Name ~ -Value AliasHome -Description "Go to '~' and optional subfolder."

function AliasHosts {
    sudo code /etc/hosts
}


function AliasSyllabi {
    GoToPath "~/Syllabi/$args"
}
New-Alias -Name s -Value AliasSyllabi -Description "Go to ~/Syllabi"

function AliasUpOneDirectory {
    GoToPath "../$args"
}
New-Alias -Name .. -Value AliasUpOneDirectory

function AliasUpTwoDirectories {
    GoToPath "../../$args"
}
New-Alias -Name ... -Value AliasUpTwoDirectories

function AliasLongList {
    Get-ChildItem -Force "$args"
}
New-Alias -Name ll -Value AliasLongList

function GoToPath ([string] $path) {
    if (Test-Path $path) {
        Set-Location $path
    } else {
        Write-Warning -Message "Cannot find path '$path' because it does not exist."
    }
}

