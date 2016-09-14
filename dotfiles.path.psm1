function GetLongList {
    Get-ChildItem -Force "$args"
}
New-Alias -Name ll -Value GetLongList

function GoToPath ([String] $Path, [String] $Directory) {
    $Location = Join-Path -Path $Path -ChildPath $Directory
    if (Test-Path $Location) {
        Set-Location $Location
    } else {
        Write-Warning -Message "Cannot find path '$Location' because it does not exist."
        Write-Host 'Available directories:'
        Get-ChildItem -Name $Path | Write-Host -ForegroundColor DarkGray
    }
}

function GoToPathCode ([String] $Directory) {
    GoToPath (Join-Path -Path $HOME -ChildPath Code) $Directory
}
New-Alias -Name c -Value GoToPathCode

function GoToPathHome ([String] $Directory) {
    GoToPath $HOME $Directory
}
New-Alias -Name ~ -Value GoToPathHome

function GoToPathSyllabi ([String] $Directory) {
    $Directory = $Directory.ToLower()
    $Path = Join-Path -Path $HOME -ChildPath Syllabi
    $Location = Join-Path -Path $Path -ChildPath $Directory
    if (Test-Path $Location) {
        Set-Location $Location
    } else {
        Write-Warning -Message "Cannot find syllabus '$Directory' because it does not exist."
        Write-Host 'Available syllabi:'
        Get-ChildItem -Path $Path -Directory -Name | Where-Object { $_ -match '^((\d{4}|utl|mod)_|syllabus)' } | Write-Host -ForegroundColor DarkGray
    }
}
New-Alias -Name s -Value GoToPathSyllabi

function OpenHostsFile {
    if (Get-Command code -ErrorAction SilentlyContinue) {
        if ($IsOSX) {
            sudo code /etc/hosts
        } elseif ($IsWindows) {
            code C:\Windows\System32\drivers\etc\hosts
        }
    } else {
        Write-Warning -Message "Please install Visual Studio Code and install the 'code' command in PATH."
    }
}
New-Alias -Name hosts -Value OpenHostsFile

function UpOneDirectory ([String] $Directory) {
    GoToPath .. $Directory
}
New-Alias -Name .. -Value UpOneDirectory

function UpTwoDirectories ([String] $Directory) {
    GoToPath ../.. $Directory
}
New-Alias -Name ... -Value UpTwoDirectories