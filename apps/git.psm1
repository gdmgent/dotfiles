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

function GitCheckoutGitHubPages {
    git checkout gh-pages
}
New-Alias -Name pages -Value GitCheckoutGitHubPages

function GitCheckoutMaster {
    Param (
        [Switch]
        $All,
        [Switch]
        $Submodule
    )
    $Command = 'git checkout master'
    if ($All -or $Submodule) {
        Invoke-Expression -Command "git submodule foreach --recursive '${Command}'"
    }
    if ($All -or !$Submodule) {
        Invoke-Expression -Command $Command
    }
}
New-Alias -Name master -Value GitCheckoutMaster

function GitCommit {
    Param(
        [Parameter(Mandatory=$true)]
        [String]
        $Message,
        [ValidateSet('CHORE','ENHANCEMENT','FEATURE','FIX','REFACTOR','STYLE','TEST')]
        [String]
        $Type = 'WIP',
        [Switch]
        $All,
        [Switch]
        $Submodule
    )
    $Command = "git commit -m `"[${Type}] ${Message}`""
    if ($All -or $Submodule) {
        Invoke-Expression -Command "git submodule foreach --recursive '${Command}'"
    }
    if ($All -or !$Submodule) {
        Invoke-Expression -Command $Command
    }
}
New-Alias -Name commit -Value GitCommit

function GitConfig {
    Param(
        [Parameter(Mandatory=$true)]
        [String]
        $UserName,
        [Parameter(Mandatory=$true)]
        [String]
        $Email
    )
    if (! (ExistCommand -Name git)) {
        InstallGit
    }
    git config --global user.name "${UserName}"
    git config --global user.email "${Email}"
}

function GitConfigFixProtocol {
    git config --global url."https://".insteadOf git://
}

function GitConfigIgnoreGlobal {
    if (! (ExistCommand -Name git)) {
        InstallGit
    }
    WriteMessage -Type Info -Inverse -Message 'Installing .gitignore_global'
    $GitIgnoreSource = Join-Path -Path $Global:DotfilesInstallPath -ChildPath 'preferences' | Join-Path -ChildPath 'gitignore_global'
    git config --global core.excludesfile $GitIgnoreSource
}

function GitConfigUser {
    Param(
        [Parameter(Mandatory=$true)]
        [String]
        $Email = 'olivier.parent@arteveldehs.be',
        [Parameter(Mandatory=$true)]
        [String]
        $User = 'OlivierParent'
    )
    git config --global user.email $Email
    git config --global user.name $User
    if ($IsWindows) {
        git config --global credential.helper wincred
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
        $CommandMaster = 'git checkout master'
        Invoke-Expression -Command "git submodule foreach --recursive '${CommandMaster};${Command}'"
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