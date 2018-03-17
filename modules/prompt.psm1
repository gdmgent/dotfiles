function PromptColors {
     [enum]::GetValues([System.ConsoleColor]) | Foreach-Object { Write-Host $_ -ForegroundColor $_ }
}

function PromptGit {
    if (Test-Path -Path '.git') {
        $Branch = (git status | Select-Object -First 1) -replace 'On branch|\s'
        $HasChanged = (git status --branch --short | Measure-Object).Count -gt 1
        $Prompt = if ($HasChanged) { "`u{26A0}" } else { "`u{26A1}" }
        if ($IsMacOS) {
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