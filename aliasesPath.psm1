# Import-Module aliasesVagrant.psm1

function AliasCode([string] $directory) {
    GoToPath "$HOME/Code" "$directory"
}
New-Alias -Name c -Value AliasCode -Description "Go to ~/Code"

function AliasHome([string] $directory) {
    GoToPath "$HOME" "$directory"
}
New-Alias -Name ~ -Value AliasHome -Description "Go to '~' and optional subfolder."

function AliasHosts {
    if (Get-Command code -errorAction SilentlyContinue) {
        if ($IsOSX) {
            sudo code /etc/hosts
        } elseif (*isWindows) {
            code /Windows/System32/drivers/etc/hosts 
        }
    } else {
        Write-Warning -Message "Please install Visual Studio Code and install the 'code' command in PATH."
    }
}

function AliasSyllabi([string] $directory) {
    GoToPath "$HOME/Syllabi" "$directory"
}
New-Alias -Name s -Value AliasSyllabi

function AliasUpOneDirectory([string] $directory) {
    GoToPath '..' "$directory"
}
New-Alias -Name .. -Value AliasUpOneDirectory

function AliasUpTwoDirectories([string] $directory) {
    GoToPath '../..' "$directory"
}
New-Alias -Name ... -Value AliasUpTwoDirectories

function AliasLongList {
    Get-ChildItem -Force "$args"
}
New-Alias -Name ll -Value AliasLongList

function GoToPath ([string] $path, [string] $directory) {
    $location = "$path/$directory";
    if (Test-Path $location) {
        Set-Location $location
    } else {
        Write-Warning -Message "Cannot find path '$location' because it does not exist."
        Write-Host 'Available directories:'
        Get-ChildItem -Name $path | Write-Host -ForegroundColor DarkGray
    }
}