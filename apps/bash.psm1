if ($IsWindows) {
    function BashCommand {
        bash.exe ~
    }
    New-Alias -Name bash -Value BashCommand
}