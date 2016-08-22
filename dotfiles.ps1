Push-Location (Split-Path $MyInvocation.MyCommand.Path)

Import-Module ./dotfiles.psm1
Import-Module ./aliasesPath.psm1
Import-Module ./proxySettings.psm1
if (Get-Command git -errorAction SilentlyContinue) {
    Import-Module ./aliasesGit.psm1
}
if (Get-Command jekyll -errorAction SilentlyContinue) {
    Import-Module ./aliasesJekyll.psm1
}
if (Get-Command php -errorAction SilentlyContinue) {
    Import-Module ./aliasesPhp.psm1
}
if (Get-Command vagrant -errorAction SilentlyContinue) {
    Import-Module ./aliasesVagrant.psm1
}

Pop-Location
SetEnvironment
Set-Location $HOME
Clear-Host

Dot