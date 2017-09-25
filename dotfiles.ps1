Set-Variable -Name DotfilesInstallPath -Value (Split-Path -Path $MyInvocation.MyCommand.Path) -Option Constant -Scope Global -ErrorAction SilentlyContinue

Push-Location -Path $Global:DotfilesInstallPath

$Modules = @(
    'apps'
    'browsers'
    'core'
    'node'
    'path'
    'prompt'
    'proxy'
    'syllabus'
)
foreach ($Module in $Modules) {
    Import-Module -Name ([io.path]::combine($Global:DotfilesInstallPath, 'modules', "$Module.psm1"))
}

$Applications = @(
    'git'
    'hotel'
    'jekyll'
    'mysql'
    'php'
    'vagrant'
)
foreach ($Application in $Applications) {
    if (ExistCommand -Name $Application) {
        Import-Module -Name ([io.path]::combine($Global:DotfilesInstallPath, 'apps', "$Application.psm1"))
    } else {
        $Error.RemoveAt(0)
    }
}

if (ExistCommand -Name git) {
    git pull
} else {
    $Error.RemoveAt(0)
}

Pop-Location

Set-Location -Path $HOME

if (! $Error) {
    Clear-Host
}

Dotfiles