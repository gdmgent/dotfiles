Set-Variable -Name DotfilesInstallPath -Value (Split-Path $MyInvocation.MyCommand.Path) -Option Constant -Scope Global

Push-Location $Global:DotfilesInstallPath

Import-Module ./dotfiles.psm1;InitConfig
Import-Module ./dotfiles.path.psm1
Import-Module ./dotfiles.proxysettings.psm1; InitProxy
# Import-Module ./dotfiles.proxy.ps1
Import-Module ./dotfiles.nodejs.psm1; InitNode
if (Get-Command git -ErrorAction SilentlyContinue) {
    Import-Module ./dotfiles.git.psm1
}
if (Get-Command jekyll -ErrorAction SilentlyContinue) {
    Import-Module ./dotfiles.jekyll.psm1
}
if (Get-Command php -ErrorAction SilentlyContinue) {
    Import-Module ./dotfiles.php.psm1
}
if (Get-Command vagrant -ErrorAction SilentlyContinue) {
    Import-Module ./dotfiles.vagrant.psm1
}
if (Get-Command git -ErrorAction SilentlyContinue) {
    git pull
}
Pop-Location

Set-Location $HOME

if (!$Error) {
    Clear-Host
}

Dotfiles