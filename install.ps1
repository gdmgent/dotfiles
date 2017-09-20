if ($isWindows) {
    Set-ExecutionPolicy -ExecutionPolicy Unrestricted
}
Set-Content -Path (New-Item -Force $PROFILE -Type File) -Value ('. ' + (Join-Path -Path $PWD -ChildPath dotfiles.ps1))