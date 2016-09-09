Set-Variable -Name DotfilesInstallPath -Value (Split-Path $MyInvocation.MyCommand.Path) -Option Constant -Scope Global

Push-Location $Global:DotfilesInstallPath

Import-Module -Name (Join-Path -Path . -ChildPath dotfiles.psm1); InitConfig
Import-Module -Name (Join-Path -Path . -ChildPath dotfiles.path.psm1)
Import-Module -Name (Join-Path -Path . -ChildPath dotfiles.proxysettings.psm1); InitProxy
# Import-Module -Name (Join-Path -Path . -ChildPath dotfiles.proxy.psm1)
Import-Module ./dotfiles.nodejs.psm1; InitNode
if (Get-Command git -ErrorAction SilentlyContinue) {
    Import-Module -Name (Join-Path -Path . -ChildPath dotfiles.git.psm1)
} else { $Error.Remove($Error[$Error.Count - 1]) }
if (Get-Command jekyll -ErrorAction SilentlyContinue) {
    Import-Module -Name (Join-Path -Path . -ChildPath dotfiles.jekyll.psm1)
} else { $Error.Remove($Error[$Error.Count - 1]) }
if (Get-Command php -ErrorAction SilentlyContinue) {
    Import-Module -Name (Join-Path -Path . -ChildPath dotfiles.php.psm1)
} else { $Error.Remove($Error[$Error.Count - 1]) }
if (Get-Command vagrant -ErrorAction SilentlyContinue) {
    Import-Module -Name (Join-Path -Path . -ChildPath dotfiles.vagrant.psm1)
} else { $Error.Remove($Error[$Error.Count - 1]) }
if (Get-Command git -ErrorAction SilentlyContinue) {
    git pull
} else { $Error.Remove($Error[$Error.Count - 1]) }
Pop-Location

Set-Location $HOME

if (!$Error) {
    Clear-Host
}

Dotfiles