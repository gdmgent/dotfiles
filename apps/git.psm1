function GitAdd {
    Param(
        [String]
        $Files = '.',

        [Switch]
        $All,

        [Switch]
        $Submodule
    )
    $Command = "git add ${Files}"
    if ($All -or $Submodule) {
        Invoke-Expression -Command "git submodule foreach --recursive '${Command}'"
    }
    if ($All -or !$Submodule) {
        Invoke-Expression -Command $Command
    }
}
New-Alias -Name add -Value GitAdd

function GitBranchDefaultMain {
    Invoke-Expression -Command "git config --global init.defaultBranch main"
}
New-Alias -Name main -Value GitBranchDefaultMain

function GitCheckoutMain {
    Param (
        [Switch]
        $All,

        [Switch]
        $Submodule
    )
    $Command = 'git checkout main'
    if ($All -or $Submodule) {
        Invoke-Expression -Command "git submodule foreach --recursive '${Command}'"
    }
    if ($All -or !$Submodule) {
        Invoke-Expression -Command $Command
    }
}
New-Alias -Name checkout -Value GitCheckoutMain

function GitCommit {
    Param(
        [Parameter(Mandatory=$true)]
        [String]
        $Message,

        [ValidateSet('CHORE','ENHANCEMENT','FEATURE','FIX','REFACTOR','STYLE','TEST','WIP')]
        [String]
        $Type = 'WIP',

        [Switch]
        $All,

        [Switch]
        $Submodule
    )
    if ($Message) {
        $Message = " ${Message}"
    }
    $Command = "git commit -m `"[${Type}]${Message}`""
    if ($All -or $Submodule) {
        Invoke-Expression -Command "git submodule foreach --recursive '${Command}'"
    }
    if ($All -or !$Submodule) {
        Invoke-Expression -Command $Command
    }
}
New-Alias -Name commit -Value GitCommit

function GitPublish {
    Param(
        [ValidateSet('build','dist','docs')]
        [String]
        $Folder = 'build'
    )
    Invoke-Expression -Command "git add -f ./${Folder}"
    Invoke-Expression -Command "git commit -a -m `"[PUBLICATION]`""
    Invoke-Expression -Command "git subtree push --prefix ${Folder} origin gh-pages"
}
New-Alias -Name publish -Value GitPublish

function GitPublishDist {
    GitPublish -Folder 'dist'
}
New-Alias -Name dist -Value GitPublishDist

function GitPublishDocs {
    GitPublish -Folder 'docs'
}
New-Alias -Name docs -Value GitPublishDocs

function GitConfigFixProtocol {
    Invoke-Expression -Command "git config --global url.`"https://`".insteadOf git://"
}

function GitConfigIgnoreGlobal {
    if (! (ExistCommand -Name git)) {
        InstallGit
    }
    WriteMessage -Type Info -Inverse -Message 'Installing .gitignore_global'
    $GitIgnoreSource = Join-Path -Path $Global:DotfilesInstallPath -ChildPath 'preferences' | Join-Path -ChildPath 'gitignore_global'
    Invoke-Expression -Command "git config --global core.excludesfile $GitIgnoreSource"
}

function GitInit {
    Invoke-Expression -Command "git init"
    Invoke-Expression -Command "git branch -m master main"
}
New-Alias -Name init -Value GitInit

function GitConfigUser {
    Param(
        [Parameter(Mandatory=$true)]
        [String]
         $Email = 'olivier.parent@arteveldehs.be',
        [Parameter(Mandatory=$true)]
        [String]
         $User = 'OlivierParent'


    )
    if (! (ExistCommand -Name git)) {
        InstallGit
    }
    Invoke-Expression -Command "git config --global user.name `"${UserName}`""
    Invoke-Expression -Command "git config --global user.email `"${Email}`""
    if ($IsWindows) {
        Invoke-Expression -Command "git config --global credential.helper wincred"
    }
}

function GitPull {
    Param (
        [Switch]
        $All,

        [Switch]
        $Force,

        [Switch]
        $Submodule
    )
    if ($Force) {
        GitStashDrop
    }
    $Command = 'git pull'
    if ($All -or $Submodule) {
        # git submodule update --recursive --remote
        $CommandMain = 'git checkout main'
        Invoke-Expression -Command "git submodule foreach --recursive '${CommandMain};${Command}'"
    }
    if ($All -or !$Submodule) {
        Invoke-Expression -Command $Command
    }
}
New-Alias -Name pull -Value GitPull

function GitPush {
    Param (
        [Switch]
        $All,

        [Switch]
        $Submodule
    )
    $Command = 'git push'
    if ($All -or $Submodule) {
        Invoke-Expression -Command "git submodule foreach --recursive '${Command}'"
    }
    if ($All -or !$Submodule) {
        Invoke-Expression -Command $Command
    }
}
New-Alias -Name push -Value GitPush

function GitPushFirst {
    $Command = 'git push --set-upstream origin main'
    Invoke-Expression -Command $Command
}
New-Alias -Name pushfirst -Value GitPushFirst

function GitPushWorkInProgress {
    Param(
        [Switch]
        $All,

        [Switch]
        $Submodule
    )
    $Command = 'git commit -a -m [WIP]'
    if ($All -or $Submodule) {
        Invoke-Expression -Command "git submodule foreach --recursive '${Command}'"
        GitPush -Submodules
    }
    if ($All -or !$Submodule) {
        Invoke-Expression -Command $Command
        GitPush
    }
}
New-Alias -Name wip -Value GitPushWorkInProgress

function GitStashDrop {
    git stash
    git stash drop
}
New-Alias -Name stashdrop -Value GitStashDrop

function GitStatus {
    Param (
        [Switch]
        $All,

        [Switch]
        $Submodule
    )
    $Command = 'git status'
    if ($All -or $Submodule) {
        Invoke-Expression -Command "git submodule foreach --recursive '${Command}'"
    }
    if ($All -or !$Submodule) {
        Invoke-Expression -Command $Command
    }
}
New-Alias -Name status -Value GitStatus
New-Alias -Name sts -Value GitStatus
