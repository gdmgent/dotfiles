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
        $Account = 'gdmgent-1819',

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

function CloneClassroomProjects {
    Param(
        [Parameter(Mandatory=$true)]
        [String]
        $FilePath,

        [Parameter(Mandatory=$true)]
        [String]
        $Organisation,

        [String]
        $Column = 'Repository',

        [String]
        $RepositoryPrefix = '',

        [ValidateSet('Code','CodeColleges','CodeStudents','CodeTest')]
        [String]
        $CodeFolder = 'CodeStudents',

        [ValidateSet(',',';')]
        [String]
        $Delimiter = ';',

        [ValidateSet('bitbucket.org','github.com','gitlab.com')]
        [String]
        $Service = 'github.com'
    )
    $Rows = Import-Csv -Delimiter $Delimiter -Path $FilePath
    $SetLocationPath = "SetLocationPath${CodeFolder}"
    Invoke-Expression -Command "${SetLocationPath}"

    if (! (Test-Path -Path $Organisation)) {
        New-Item -Path $Organisation -ItemType Directory
    }
    Set-Location $Organisation
    foreach ($Row in $Rows) {
        $RepositoryName = $Row.$Column
        $RepositoryName = $RepositoryName.ToLower()
        if (! [regex]::matches($RepositoryName, ".git$")) {
            $RepositoryName = "${RepositoryName}.git"
        }
        if (! $RepositoryPrefix -eq '' ) {
            $RepositoryName = "${RepositoryPrefix}-${RepositoryName}"
        }
        if ([regex]::matches($Name, "^https?://")) {
            $Uri = $Name
        } else {
            $Uri = "https://${Service}/${Organisation}/${RepositoryName}"
        }
        $Path = [regex]::matches($Uri, "^(https?://[/\w.-]+/)?([\w.-]+).git$").Groups[2].Value
        if (! (Test-Path -Path $Path)) {
            $Command = "git clone ${Uri}"
            Invoke-Expression -Command $Command
        }
    }
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

        [ValidateSet('gdmgent','gdmgent-1819','pgmgent')]
        [String]
        $Account = 'gdmgent-1819',

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
        Remove-Item -Path 'syllabus-resources' -Recurse -Force
        git init
        git submodule add https://$Service/$Account/syllabus-resources.git
        if ($DestinationName) {
            git remote add origin https://$Service/$Account/$DestinationName.git
        } else {
            git remote add origin https://$Service/$Account/$Name.git
        }
    } else {
        git submodule update --init --recursive --remote
        GitCheckoutMaster -Submodule
    }
    yarn
    # UpdateBundler
}

function GitHubVuepress {
    Param (
        [Parameter(Mandatory=$true)]
        [String]
        $Name,

        [ValidateSet('gdm','pgm')]
        [String]
        $Organisation = 'gdm',

        [Switch]
        $CreateNew
    )
    if ($CreateNew) {
        SetLocationPathSyllabi
        Invoke-Expression -Command "gh repo clone gdmgent/vuepress-demo `"${Organisation}-${Name}`""
        Set-Location "${Organisation}-${Name}"
        Invoke-Expression -Command "rm -r -fo .git"
    }
    Invoke-Expression -Command "git init ."
    Invoke-Expression -Command "gh repo create ${Organisation}gent/${Name} --confirm --enable-issues=false --enable-wiki=false --homepage=https://www.${Organisation}.gent/${Name}/ --private"
}
New-Alias -Name vp -Value GitHubVuepress

function StatusSyllabi {
    Push-Location
    SetLocationPathSyllabi
    $Directories = Get-ChildItem -Directory -Name
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
New-Alias -Name ss -Value StatusSyllabi

function UpdateSyllabi {
    Param(
        [Switch]
        $NoBundlerUpdate,

        [Switch]
        $Push
    )
    Push-Location
    SetLocationPathSyllabi
    $Directories = Get-ChildItem -Directory -Name
    foreach ($Directory in $Directories) {
        Push-Location $Directory
            WriteMessage -Type Info -Inverse -Message $Directory
            UpdateSyllabus -NoBundlerUpdate:$NoBundlerUpdate -Push:$Push
        Pop-Location
    }
    Pop-Location
}
New-Alias -Name us -Value UpdateSyllabi

function UpdateSyllabus {
    Param(
        [Switch]
        $NoBundlerUpdate,

        [Switch]
        $Push
    )
    if (Test-Path -Path .git) {
        GitPull -All
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
    if (Test-Path -Path syllabus-resources) {
        WriteMessage -Type Info -Message 'Updating Syllabus Resources...'
        $Origin = [io.path]::Combine('syllabus-resources', '_data', 'shared', '*.yml')
        $Destination = [io.path]::Combine('_data', 'shared')
        if (! (Test-Path -Path $Destination)) {
            New-Item -Path $Destination -ItemType Directory | Out-Null
        }
        Copy-Item -Path $Origin -Destination $Destination
    }
}

function UpdateSyllabusSettings {
    if (Test-Path -Path syllabus-resources) {
        WriteMessage -Type Info -Message 'Updating Syllabus Settings...'
        $Origin = [io.path]::Combine('syllabus-resources', '__tools', 'settings', '*.json')
        $Destination = '.vscode'
        if (! (Test-Path -Path $Destination)) {
            New-Item -Path $Destination -ItemType Directory | Out-Null
        }
        Copy-Item -Path $Origin -Destination $Destination
    }
}

function UpdateSyllabusSnippets {
    if (Test-Path -Path syllabus-resources) {
        WriteMessage -Type Info -Message 'Updating Syllabus Snippets...'
        $Origin = [io.path]::Combine('syllabus-resources', '__tools', 'snippets', '*')
        if ($IsMacOS) {
            $Destination = "${HOME}/Library/Application Support/Code/User/snippets/"
        } elseif ($IsWindows) {
            $Destination = "${env:APPDATA}\Code\User\snippets\"
        } else {
            $Destination =  $MyInvocation.MyCommand.Path
        }
        Get-ChildItem -Path $Origin -Include *.json, *.code-snippets -Recurse | Copy-Item -Destination $Destination -Force
    }
}
