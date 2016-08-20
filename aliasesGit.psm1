# Import-Module aliasesGit.psm1

function AliasGitAdd {
    git add .
}
New-Alias -Name add -Value AliasGitAdd

function AliasGitPull {
    git pull
}
New-Alias -Name pull -Value AliasGitPull

function AliasGitPush {
    git push
}
New-Alias -Name push -Value AliasGitPush

function AliasGitStatus {
    git status
}
New-Alias -Name sts -Value AliasGitStatus

function AliasGitWorkInProgress {
    git commit -a -m [WIP]
    push
}
New-Alias -Name wip -Value AliasGitWorkInProgress