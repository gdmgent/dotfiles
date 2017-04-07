Set-Variable -Name DotfilesInstallPath -Value (Split-Path -Path $MyInvocation.MyCommand.Path) -Option Constant -Scope Global -ErrorAction SilentlyContinue

Push-Location -Path $Global:DotfilesInstallPath

$Modules = @(
    'core'
    'path'
    'prompt'
    'proxy'
)
foreach ($Module in $Modules) {
    Import-Module -Name (Join-Path -Path . -ChildPath dotfiles.$Module.psm1);
}

$Applications = @(
    'git'
    'jekyll'
    'mysql'
    'node'
    'php'
    'vagrant'
)
foreach ($Application in $Applications) {
    if (ExistCommand -Name $Application) {
        Import-Module -Name (Join-Path -Path . -ChildPath dotfiles.app.$Application.psm1)
    } else { 
        RemoveError 
    }
}

if (ExistCommand -Name git) {
    git pull
} else {
    RemoveError
}

Pop-Location

Set-Location -Path $HOME

if (! $Error) {
    Clear-Host
}

Dotfiles