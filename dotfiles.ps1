New-Variable -Name WorkingDirectory -Value $pwd

Set-Variable -Name DotfilesInstallPath -Value (Split-Path -Path $MyInvocation.MyCommand.Path) -Option Constant -Scope Global -ErrorAction SilentlyContinue

Set-Location -Path $Global:DotfilesInstallPath

$Modules = @(
    'apps'
    'browsers'
    'core'
    'node'
    'path'
    'prompt'
    'syllabus'
)
foreach ($Module in $Modules) {
    Import-Module -Name ([io.path]::Combine($Global:DotfilesInstallPath, 'modules', "${Module}.psm1"))
}

$Applications = @(
    'bash'
    'bundler'
    'git'
    'hotel'
    'mysql'
    'nginx'
    'php'
    'vagrant'
)
foreach ($Application in $Applications) {
    if (ExistCommand -Name $Application) {
        Import-Module -Name ([io.path]::Combine($Global:DotfilesInstallPath, 'apps', "${Application}.psm1"))
    }
    else {
        $Error.RemoveAt(0)
    }
}
$CustomModule = [io.path]::Combine($HOME, '.dotfiles', 'custom.psm1')
if (Test-Path -Path $CustomModule) {
    Import-Module -Name $CustomModule
}

if (ExistCommand -Name git) {
    git pull
}
else {
    $Error.RemoveAt(0)
}

Pop-Location

Set-Location -Path $HOME

if (! $Error) {
    Clear-Host
}

Dotfiles

Set-Location $WorkingDirectory