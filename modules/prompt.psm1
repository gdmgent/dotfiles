function PromptColors {
     [enum]::GetValues([System.ConsoleColor]) | Foreach-Object { Write-Host $_ -ForegroundColor $_ }
}

function PromptGit {
    if (Test-Path -Path '.git') {
        $Branch = (git status | Select-Object -First 1) -replace 'On branch|\s'
        $Prompt = [char]::ConvertFromUtf32(0x26A1)
        $HasChanged = (git status --branch --short | Measure-Object).Count -gt 1
        if ($IsMacOS) {
            if ($HasChanged) {
                $Prompt = [char]::ConvertFromUtf32(0x26A0)
            }
            return "${Prompt} (${Branch}) "
        } elseif ($IsWindows) {
            Write-Host "${Prompt} (" -NoNewline
            Write-Host $Branch -NoNewline -ForegroundColor $(if ($HasChanged) { 'Red' } else { 'Green' })
            Write-Host ') ' -NoNewline
        }
    }
}

function Prompt {
    $(PromptGit) + "$($ExecutionContext.SessionState.Path.CurrentLocation)$('>' * (${NestedPromptLevel} + 1)) "
}