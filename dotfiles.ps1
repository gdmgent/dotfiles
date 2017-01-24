Set-Variable -Name DotfilesInstallPath -Value (Split-Path -Path $MyInvocation.MyCommand.Path) -Option Constant -Scope Global -ErrorAction SilentlyContinue

Push-Location -Path $Global:DotfilesInstallPath

Import-Module -Name (Join-Path -Path . -ChildPath dotfiles.core.psm1); InitConfig
Import-Module -Name (Join-Path -Path . -ChildPath dotfiles.path.psm1)
Import-Module -Name (Join-Path -Path . -ChildPath dotfiles.prompt.psm1)
Import-Module -Name (Join-Path -Path . -ChildPath dotfiles.proxysettings.psm1); InitProxy
# Import-Module -Name (Join-Path -Path . -ChildPath dotfiles.proxy.psm1)
Import-Module ./dotfiles.nodejs.psm1; InitNode
if (ExistCommand -Name git) {
    Import-Module -Name (Join-Path -Path . -ChildPath dotfiles.git.psm1)
} else { RemoveError }
if (ExistCommand -Name jekyll) {
    Import-Module -Name (Join-Path -Path . -ChildPath dotfiles.jekyll.psm1)
} else { RemoveError }
if (ExistCommand -Name php) {
    Import-Module -Name (Join-Path -Path . -ChildPath dotfiles.php.psm1)
} else { RemoveError }
if (ExistCommand -Name vagrant) {
    Import-Module -Name (Join-Path -Path . -ChildPath dotfiles.vagrant.psm1)
} else { RemoveError }
if (ExistCommand -Name git) {
    git pull
} else { RemoveError }
Pop-Location

Set-Location -Path $HOME

if (!$Error) {
    Clear-Host
}

Dotfiles