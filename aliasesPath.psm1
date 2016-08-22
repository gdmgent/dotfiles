# Import-Module aliasesVagrant.psm1

function GetLongList {
    Get-ChildItem -Force "$args"
}
New-Alias -Name ll -Value GetLongList

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

function GoToPathCode([string] $directory) {
    GoToPath $HOME/Code $directory
}
New-Alias -Name c -Value GoToPathCode

function GoToPathHome([string] $directory) {
    GoToPath $HOME $directory
}
New-Alias -Name ~ -Value GoToPathHome

function GoToPathSyllabi([string] $directory) {
    GoToPath $HOME/Syllabi $directory
}
New-Alias -Name s -Value GoToPathSyllabi

function OpenHostsFile {
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
New-Alias -Name hosts -Value OpenHostsFile

function UpOneDirectory([string] $directory) {
    GoToPath .. $directory
}
New-Alias -Name .. -Value UpOneDirectory

function UpTwoDirectories([string] $directory) {
    GoToPath ../.. $directory
}
New-Alias -Name ... -Value UpTwoDirectories