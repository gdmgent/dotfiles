function PromptColors {
     [enum]::GetValues([System.ConsoleColor]) | Foreach-Object { Write-Host $_ -ForegroundColor $_ }
}

function PromptGit {
    if (Test-Path -Path '.git') {
        $Branch = (git status | Select-Object -First 1) -replace 'On branch|\s'
        $Status = if ((git status --branch --short | Measure-Object).Count -gt 1) { '!' } else { '' }
        return "Git($Branch)$Status "
    }
}

function Prompt {
    $(PromptGit) + "$($ExecutionContext.SessionState.Path.CurrentLocation)$('>' * ($NestedPromptLevel + 1)) "
}