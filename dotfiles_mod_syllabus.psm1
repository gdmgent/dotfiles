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
    Push-Location -Path 'syllabusv2-resources'
    git submodule init
    git submodule update
    GitCheckoutMaster
    Pop-Location
    UpdateBundler
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
    $Directories = Get-ChildItem -Directory -Name | Where-Object { $_ -match '^((\d{4}|utl|mod)(_|-)|syllabus)|.github.io$' }
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
    $Directories = Get-ChildItem -Directory -Name | Where-Object { $_ -match '^((\d{4}|utl|mod)(_|-)|syllabus)|.github.io$' }
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
    $Directories = Get-ChildItem -Directory -Name | Where-Object { $_ -match '^((\d{4}|utl|mod)(_|-)|syllabus)|.github.io$' }
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
        if (! (Test-Path -Path $Destination)) {
            New-Item -Path $Destination -ItemType Directory | Out-Null
        }
        Copy-Item -Path $Origin -Destination $Destination
    }
}