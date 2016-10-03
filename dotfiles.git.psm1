function GitAdd {
    git add .
}
New-Alias -Name add -Value GitAdd

function GitCheckoutGitHubPages {
    git checkout gh-pages
}
New-Alias -Name pages -Value GitCheckoutGitHubPages

function GitCheckoutMaster {
    git checkout master
}
New-Alias -Name master -Value GitCheckoutMaster

function GitPull {
    Param (
        [Switch]
        $Force
    )
    if ($Force) {
        GitStashDrop
    }
    git pull
}
New-Alias -Name pull -Value GitPull

function GitPush {
    git push
}
New-Alias -Name push -Value GitPush

function GitPushWorkInProgress {
    git commit -a -m [WIP]
    GitPush
}
New-Alias -Name wip -Value GitPushWorkInProgress

function GitStashDrop {
    git stash
    git stash drop
}
New-Alias -Name stashdrop -Value GitStashDrop

function GitStatus {
    git status
}
New-Alias -Name status -Value GitStatus
New-Alias -Name sts -Value GitStatus