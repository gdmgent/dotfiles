function GitAdd {
    Param(
        [String]
        $Files = '.',
        [Switch]
        $All,
        [Switch]
        $Submodule
    )
    $Command = "git add $Files"
    if ($All -or $Submodule) {
        Invoke-Expression -Command "git submodule foreach '$Command'"
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
    git checkout master
}
New-Alias -Name master -Value GitCheckoutMaster

function GitCommit {
    Param(
        [Parameter(Mandatory=$true)]
        [String]
        $Message,
        [ValidateSet('CHORE','ENHANCEMENT','FEATURE','FIX','REFACTOR','STYLE','TEST')]
        [String]
        $Type = "WIP",
        [Switch]
        $All,
        [Switch]
        $Submodule
    )
    $Command = "git commit -m `"[$Type] $Message`""
    if ($All -or $Submodule) {
        Invoke-Expression -Command "git submodule foreach '$Command'"
    }
    if ($All -or !$Submodule) {
        Invoke-Expression -Command $Command
    }
}
New-Alias -Name commit -Value GitCommit

function GitConfigFixProtocol {
    git config --global url."https://".insteadOf git://
}

function GitConfigIgnoreGlobal {
    if (! (ExistCommand -Name git)) {
        InstallGit
    }
    Write-Host 'Installing GitIgnore Global...'
    $GitIgnoreSource = Join-Path -Path $Global:DotfilesInstallPath -ChildPath 'preferences' | Join-Path -ChildPath 'gitignore_global'
    git config --global core.excludesfile $GitIgnoreSource
}

function GitConfigProxyOff {
    git config --global --unset http.proxy
}

function GitConfigProxyOn {
    git config --global http.proxy "http://proxy.arteveldehs.be:8080"
}

function GitConfigUser {
    Param(
        [Parameter(Mandatory=$true)]
        [String]
        $Email = "olivier.parent@arteveldehs.be",
        [Parameter(Mandatory=$true)]
        [String]
        $User = "OlivierParent"
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
    $Command = "git pull"
    if ($All -or $Submodule) {
        Invoke-Expression -Command "git submodule foreach '$Command'"
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
    $Command = "git push"
    if ($All -or $Submodule) {
        Invoke-Expression -Command "git submodule foreach '$Command'"
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
    $Command = "git commit -a -m [WIP]"
    if ($All -or $Submodule) {
        Invoke-Expression -Command "git submodule foreach '$Command'"
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
    $Command = "git status"
    if ($All -or $Submodule) {
        Invoke-Expression -Command "git submodule foreach '$Command'"
    }
    if ($All -or !$Submodule) {
        Invoke-Expression -Command $Command
    }
}
New-Alias -Name status -Value GitStatus
New-Alias -Name sts -Value GitStatus

function CloneProject {
    Param(
        [Parameter(Mandatory=$true)]
        [String]
        $Name,
        [String]
        $DestinationName,
        [ValidateSet('bitbucket.org','github.com','gitlab.com')]
        [String]
        $Service = 'github.com',
        [String]
        $Account = 'gdmgent',
        [Switch]
        $Student
    )
    $StudentPath = 'students'
    if ($Service -eq 'gitlab.com') {
        $Git = '.git'
    }
    $Name = $Name.ToLower()
    $DestinationName = $DestinationName.ToLower()
    if ($Student) {
        SetLocationPathCode
        if (! (Test-Path -Path $StudentPath)) {
            New-Item -Path $StudentPath -ItemType Directory
        }
        SetLocationPathCode $StudentPath
    } else {
        SetLocationPathCode
    }
    git clone https://$Service/$Account/$Name$Git $DestinationName
    if ($DestinationName) {
        if ($Student) {
            SetLocationPathCode $StudentPath
            Set-Location -Path $DestinationName
        } else {
            SetLocationPathCode $DestinationName
        }
    } else {
        if ($Student) {
            SetLocationPathCode $StudentPath
            Set-Location -Path $Name
        } else {
            SetLocationPathCode $Name
        }
    }
}

function CloneSyllabusV1 {
    Param(
        [Parameter(Mandatory=$true)]
        [String]
        $Name,
        [String]
        $DestinationName,
        [ValidateSet('github.com','gitlab.com')]
        [String]
        $Service = 'github.com',
        [String]
        $Account = 'gdmgent',
        [Switch]
        $Master
    )
    $Branch = if ($Master) { 'master' } else { 'gh-pages' }
    $DestinationName = $DestinationName.ToLower()
    SetLocationPathSyllabi
    git clone https://$Service/$Account/$Name --branch $Branch --single-branch $DestinationName
    if ($DestinationName) {
        SetLocationPathSyllabi $DestinationName
    } else {
        SetLocationPathSyllabi $Name
    }
    bundle update
}

function CloneSyllabus {
    Param(
        [Parameter(Mandatory=$true)]
        [String]
        $Name,
        [String]
        $DestinationName,
        [ValidateSet('github.com','gitlab.com')]
        [String]
        $Service = 'github.com',
        [String]
        $Account = 'gdmgent'
    )
    $Branch = 'master'
    $DestinationName = $DestinationName.ToLower()
    SetLocationPathSyllabi
    git clone https://$Service/$Account/$Name --branch $Branch --single-branch $DestinationName
    if ($DestinationName) {
        SetLocationPathSyllabi $DestinationName
    } else {
        SetLocationPathSyllabi $Name
    }
    Set-Location -Path syllabusv2-resources
    git checkout master
    git submodule init
    git submodule update
    Set-Location -Path ..
    bundle update
}

function NewSyllabusV1 {
    Param(
        [Parameter(Mandatory=$true)]
        [String]
        $Name,
        [ValidateSet('github.com','gitlab.com')]
        [String]
        $Service = 'github.com',
        [String]
        $Account = 'gdmgent',
        [Switch]
        $Master
    )
    $Name = $Name.ToLower()
    SetLocationPathSyllabi
    New-Item -Path $Name -ItemType Directory
    Set-Location -Path $Name
    git init
    git checkout -b gh-pages
    git remote add origin https://$Service/$Account/$Name.git
    New-Item -Path README.md -ItemType File
    git add .
    git commit -m [WIP]
    git push --set-upstream origin gh-pages
}

function PullSyllabi {
    Param(
        [Switch]
        $Force
    )
    Push-Location
    SetLocationPathSyllabi
    $Directories = Get-ChildItem -Directory -Name | Where-Object { $_ -match '^((\d{4}|utl|mod)_|syllabus)|.github.io$' }
    foreach ($Directory in $Directories) {
        Push-Location $Directory
        if (Test-Path -Path .git) {
            Write-Host " $Directory " -BackgroundColor Blue -ForegroundColor White
            git add . | Write-Host -ForegroundColor DarkGray
            if ($Force) {
                git stash | Write-Host -ForegroundColor DarkGray
                git stash drop | Write-Host -ForegroundColor DarkGray
                git pull | Write-Host -ForegroundColor DarkGray
            } else {
                git pull | Write-Host -ForegroundColor DarkGray
            }
        }
        Pop-Location
    }
    Pop-Location
}

function PushSyllabi {
    Push-Location
    SetLocationPathSyllabi
    $Directories = Get-ChildItem -Directory -Name | Where-Object { $_ -match '^((\d{4}|utl|mod)_|syllabus)|.github.io$' }
    foreach ($Directory in $Directories) {
        Push-Location $Directory
        if (Test-Path -Path .git) {
            Write-Host " $Directory " -BackgroundColor Blue -ForegroundColor White
            git add . | Write-Host -ForegroundColor DarkGray
            git commit -a -m [WIP] | Write-Host -ForegroundColor DarkGray
            git push | Write-Host -ForegroundColor DarkGray
        }
        Pop-Location
    }
    Pop-Location
}

function StatusSyllabi {
    Push-Location
    SetLocationPathSyllabi
    $Directories = Get-ChildItem -Directory -Name | Where-Object { $_ -match '^((\d{4}|utl|mod)_|syllabus)|.github.io$' }
    foreach ($Directory in $Directories) {
        Push-Location $Directory
        if (Test-Path -Path .git) {
            Write-Host " $Directory " -BackgroundColor Blue -ForegroundColor White
            git status | Write-Host -ForegroundColor DarkGray
        }
        Pop-Location
    }
    Pop-Location
}

function UpdateSyllabusResources {
    if (Test-Path -Path syllabusv2-resources) {
        $Origin = Join-Path -Path (Join-Path -Path (Join-Path -Path 'syllabusv2-resources' -ChildPath '_data') -ChildPath 'shared') -ChildPath '*.yml'
        $Destination = Join-Path -Path '_data' -ChildPath 'shared'
        Copy-Item -Path $Origin -Destination $Destination
    }
}