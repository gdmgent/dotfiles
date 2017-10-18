function CloneProject {
    Param(
        [Parameter(Mandatory=$true)]
        [String]
        $Name,
        [String]
        $DestinationName,
        [ValidateSet('git','http','https')]
        [String]
        $Protocol = 'https',
        [ValidateSet('bitbucket.org','github.com','gitlab.com')]
        [String]
        $Service = 'github.com',
        [String]
        $Account = 'gdmgent',
        [ValidateSet('Code','CodeColleges','CodeStudents','CodeTest')]
        [String]
        $CodeFolder = 'Code'
    )
    $SetLocationPath = "SetLocationPath${CodeFolder}"
    Invoke-Expression -Command "${SetLocationPath}"
    $Name = $Name.ToLower()
    $Command = "git clone ${Protocol}://${Service}/${Account}/${Name}.git"
    WriteMessage -Type Mute -Message $Command
    if ($DestinationName) {
        $DestinationName = $DestinationName.ToLower()
        Invoke-Expression -Command "${Command} ${DestinationName}"
        Invoke-Expression -Command "${SetLocationPath} -Directory ${DestinationName}"
    } else {
        Invoke-Expression -Command $Command
        Invoke-Expression -Command "${SetLocationPath} -Directory ${Name}"
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
        $Account = 'gdmgent',
        [Switch]
        $Clean
    )
    $Branch = 'master'
    $DestinationName = $DestinationName.ToLower()
    SetLocationPathSyllabi
    git clone https://$Service/$Account/$Name --branch $Branch --single-branch $DestinationName
    if ($DestinationName) {
        SetLocationPathSyllabi -Directory $DestinationName
    } else {
        SetLocationPathSyllabi -Directory $Name
    }
    if ($Clean) {
        Remove-Item -Path '.git' -Recurse -Force
        Remove-Item -Path 'syllabusv2-resources' -Recurse -Force
        git init
        git submodule add https://github.com/gdmgent/syllabusv2-resources.git
        if ($DestinationName) {
            git remote add origin https://github.com/gdmgent/$DestinationName.git
        } else {
            git remote add origin https://github.com/gdmgent/$Name.git
        }
    } else {
        Push-Location -Path 'syllabusv2-resources'
        git submodule init
        git submodule update
        GitCheckoutMaster
        Pop-Location
    }
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

function StatusSyllabi {
    Param(
        [Switch]
        $V1
    )
    if ($V1) {
        $Pattern = '^((\d{4}|utl|mod)(_|-)|syllabus)|.github.io$'
    } else {
        $Pattern = '^\d{4}-'
    }
    Push-Location
    SetLocationPathSyllabi
    $Directories = Get-ChildItem -Directory -Name | Where-Object { $_ -match $Pattern }
    foreach ($Directory in $Directories) {
        Push-Location $Directory
        if (Test-Path -Path .git) {
            WriteMessage -Type Info -Inverse -Message $Directory
            git status | Write-Host -ForegroundColor DarkGray
        }
        Pop-Location
    }
    Pop-Location
}

function UpdateSyllabi {
    Param(
        [Switch]
        $NoBundlerUpdate,

        [Switch]
        $Push
    )
    Push-Location
    SetLocationPathSyllabi
    $Directories = Get-ChildItem -Directory -Name | Where-Object { $_ -match '^\d{4}-' }
    foreach ($Directory in $Directories) {
        Push-Location $Directory
            WriteMessage -Type Info -Inverse -Message $Directory
            UpdateSyllabus -NoBundlerUpdate:$NoBundlerUpdate -Push:$Push
        Pop-Location
    }
    Pop-Location
}

function UpdateSyllabus {
    Param(
        [Switch]
        $NoBundlerUpdate,

        [Switch]
        $Push
    )
    if (Test-Path -Path .git) {
        pull -All
        UpdateSyllabusResources
        UpdateSyllabusSettings
        UpdateSyllabusSnippets
        if (! $NoBundlerUpdate) {
            UpdateBundler
        }
        if ($Push) {
            if (Test-Path -Path .git) {
                GitPushWorkInProgress
            }
        }
    }
}

function UpdateSyllabusResources {
    if (Test-Path -Path syllabusv2-resources) {
        WriteMessage -Type Info -Message 'Updating Syllabus Resources...'
        $Origin = [io.path]::Combine('syllabusv2-resources', '_data', 'shared', '*.yml')
        $Destination = [io.path]::Combine('_data', 'shared')
        if (! (Test-Path -Path $Destination)) {
            New-Item -Path $Destination -ItemType Directory | Out-Null
        }
        Copy-Item -Path $Origin -Destination $Destination
    }
}

function UpdateSyllabusSettings {
    if (Test-Path -Path syllabusv2-resources) {
        WriteMessage -Type Info -Message 'Updating Syllabus Settings...'
        $Origin = [io.path]::Combine('syllabusv2-resources', '__tools', 'settings', '*.json')
        $Destination = '.vscode'
        if (! (Test-Path -Path $Destination)) {
            New-Item -Path $Destination -ItemType Directory | Out-Null
        }
        Copy-Item -Path $Origin -Destination $Destination
    }
}

function UpdateSyllabusSnippets {
    if (Test-Path -Path syllabusv2-resources) {
        WriteMessage -Type Info -Message 'Updating Syllabus Snippets...'
        $Origin = [io.path]::Combine('syllabusv2-resources', '__tools', 'snippets', '*.json')
        if ($IsMacOS) {
            $Destination = "$HOME/Library/Application Support/Code/User/snippets/"
        } elseif ($IsWindows) {
            $Destination = "$env:APPDATA\Code\User\snippets\"
        } else {
            $Destination =  $MyInvocation.MyCommand.Path
        }
        Copy-Item -Path $Origin -Destination $Destination -Force
    }
}

