$Global:DotfilesInstallPath = Split-Path $MyInvocation.MyCommand.Path

Push-Location $Global:DotfilesInstallPath

Import-Module ./dotfiles.psm1
InitConfig
Import-Module ./dotfiles.path.psm1
Import-Module ./dotfiles.proxysettings.psm1
if (Get-Command git -errorAction SilentlyContinue) {
    Import-Module ./dotfiles.git.psm1
}
if (Get-Command jekyll -errorAction SilentlyContinue) {
    Import-Module ./dotfiles.jekyll.psm1
}
if (Get-Command php -errorAction SilentlyContinue) {
    Import-Module ./dotfiles.php.psm1
}
if (Get-Command vagrant -errorAction SilentlyContinue) {
    Import-Module ./dotfiles.vagrant.psm1
}
Pop-Location

Set-Location $HOME

Clear-Host

Dot