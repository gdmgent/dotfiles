function GetLongList {
    Get-ChildItem -Force "$args"
}
New-Alias -Name ll -Value GetLongList

function OpenHostsFile {
    if (ExistCommand -Name code) {
        if ($IsMacOS) {
            WriteMessage -Type Warning -Message "Please close all instances of Visual Studio Code before continuing"
            [void](Read-Host 'Press Enter to continue…')
            sudo code /etc/hosts
        } elseif ($IsWindows) {
            code C:\Windows\System32\drivers\etc\hosts
        }
    } else {
        WriteMessage -Type Warning -Message "Please install Visual Studio Code and install the 'code' command in PATH."
    }
}
New-Alias -Name hosts -Value OpenHostsFile

function ExtendHostsFile {
    Param(
        [Switch]
        $Undo
    )
    $Tag = '# gdm.gent Dotfiles'
    if ($IsMacOS) {
        $HostsPath = '/etc/hosts'
        sudo powershell -c "(Get-Content -Path $HostsPath | Select-String -Pattern $Tag -NotMatch).Line | Out-File $HostsPath -Encoding utf8"
    } elseif ($IsWindows) {
        $HostsPath = 'C:\Windows\System32\drivers\etc\hosts'
        (Get-Content -Path $HostsPath | Select-String -Pattern $Tag -NotMatch).Line | Out-File $HostsPath -Encoding utf8
    }
    if (! $Undo) {
        $Domains = @(
            'cms.localhost     ',
            'cmsdev.localhost  ',
            'csse.localhost    ',
            'nmd1.localhost    ',
            'nmd2.localhost    ',
            'nmd3.localhost    ',
            'nmt1.localhost    ',
            'nmt2.localhost    ',
            'webdev1.localhost ',
            'webdev2.localhost ',
            'webtech1.localhost',
            'webtech2.localhost',
            'wot.localhost     '
        )
        $DomainEntries = ''
        foreach ($Domain in $Domains) {
            $DomainEntries += "`n127.0.0.1    ${Domain}    ${Tag}"
        }
        $Command = "Add-Content -Path '$HostsPath' -Value '${DomainEntries}';"
        # $Entries = @(
        #     '127.0.0.1       cms.localhost          # gdm.gent Dotfiles',
        #     '127.0.0.1       cmsdev.localhost       # gdm.gent Dotfiles',
        #     '127.0.0.1       csse.localhost         # gdm.gent Dotfiles',
        #     '127.0.0.1       nmd1.localhost         # gdm.gent Dotfiles',
        #     '127.0.0.1       nmd2.localhost         # gdm.gent Dotfiles',
        #     '127.0.0.1       nmd3.localhost         # gdm.gent Dotfiles',
        #     '127.0.0.1       nmt1.localhost         # gdm.gent Dotfiles',
        #     '127.0.0.1       nmt2.localhost         # gdm.gent Dotfiles',
        #     '127.0.0.1       webdev1.localhost      # gdm.gent Dotfiles',
        #     '127.0.0.1       webdev2.localhost      # gdm.gent Dotfiles',
        #     '127.0.0.1       webtech1.localhost     # gdm.gent Dotfiles',
        #     '127.0.0.1       webtech2.localhost     # gdm.gent Dotfiles',
        #     '127.0.0.1       wot.localhost          # gdm.gent Dotfiles'
        # )
        # $Command = '';

        # foreach ($Entry in $Entries) {
        #     $Command += "Add-Content -Path '$HostsPath' -Value '${Entry}';"
        # }
        if ($IsMacOS) {
            sudo powershell -c "$Command"
        } elseif ($IsWindows) {
            Invoke-Expression -Command $Command
        }
    }
}

function SetLocationPath ([String] $Path, [String] $Directory) {
    $Location = Join-Path -Path $Path -ChildPath $Directory
    if (Test-Path -Path $Location) {
        Set-Location $Location
    } else {
        WriteMessage -Type Danger -Message "Cannot find path '$Location' because it does not exist."
        WriteMessage -Type Info -Message 'Available directories:'
        Get-ChildItem -Name $Path | Write-Host -ForegroundColor DarkGray
    }
}
function SetLocationPathDotfiles {
     Set-Location -Path $DotfilesInstallPath
}
New-Alias -Name d -Value SetLocationPathDotfiles

function SetLocationPathCode {
    [CmdletBinding()]
    Param()
    DynamicParam {
        $Path = Join-Path -Path $HOME -ChildPath Code
        if (! (Test-Path -Path $Path)) {
            New-Item -Path $Path -ItemType Directory
        }
        try {
            $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
            $ParameterAttribute.Position = 1
            $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute((Get-ChildItem -Path $Path -Directory | Select-Object -ExpandProperty Name))
            $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
            $AttributeCollection.Add($ParameterAttribute)
            $AttributeCollection.Add($ValidateSetAttribute)
            $ParameterName = 'Directory'
            $RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($ParameterName, [String], $AttributeCollection)
            $RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
            $RuntimeParameterDictionary.Add($ParameterName, $RuntimeParameter)
            return $RuntimeParameterDictionary
        } catch {}
    }
    Begin {
        try {
            $Directory = $PSBoundParameters[$ParameterName]
        } catch {}
    }
    Process {
        SetLocationPath -Path $Path -Directory $Directory
    }
}
New-Alias -Name c -Value SetLocationPathCode

function SetLocationPathHome {
    [CmdletBinding()]
    Param()
    DynamicParam {
        $Path = $HOME
        if (! (Test-Path -Path $Path)) {
            New-Item -Path $Path -ItemType Directory
        }
        try {
            $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
            $ParameterAttribute.Position = 1
            $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute((Get-ChildItem -Path $Path -Directory | Select-Object -ExpandProperty Name))
            $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
            $AttributeCollection.Add($ParameterAttribute)
            $AttributeCollection.Add($ValidateSetAttribute)
            $ParameterName = 'Directory'
            $RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($ParameterName, [String], $AttributeCollection)
            $RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
            $RuntimeParameterDictionary.Add($ParameterName, $RuntimeParameter)
            return $RuntimeParameterDictionary
        } catch {}
    }
    Begin {
        try {
            $Directory = $PSBoundParameters[$ParameterName]
        } catch {}
    }
    Process {
        SetLocationPath -Path $Path -Directory $Directory
    }
}
New-Alias -Name ~ -Value SetLocationPathHome

function SetLocationPathSyllabi {
    [CmdletBinding()]
    Param()
    DynamicParam {
        $Path = Join-Path -Path $HOME -ChildPath Syllabi
        if (! (Test-Path -Path $Path)) {
            New-Item -Path $Path -ItemType Directory
        }
        try {
            $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
            $ParameterAttribute.Position = 1
            $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute((Get-ChildItem -Path $Path -Directory | Select-Object -ExpandProperty Name))
            $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
            $AttributeCollection.Add($ParameterAttribute)
            $AttributeCollection.Add($ValidateSetAttribute)
            $ParameterName = 'Directory'
            $RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($ParameterName, [String], $AttributeCollection)
            $RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
            $RuntimeParameterDictionary.Add($ParameterName, $RuntimeParameter)
            return $RuntimeParameterDictionary
        } catch {}
    }
    Begin {
        try {
            $Directory = $PSBoundParameters[$ParameterName]
        } catch {}
    }
    Process {
        SetLocationPath -Path $Path -Directory $Directory
    }
}
New-Alias -Name s -Value SetLocationPathSyllabi

function SetLocationPathUpOne ([String] $Directory) {
    SetLocationPath -Path .. -Directory $Directory
}
New-Alias -Name .. -Value SetLocationPathUpOne

function SetLocationPathUpTwo ([String] $Directory) {
    $Path = Join-Path -Path .. -ChildPath ..
    SetLocationPath -Path $Path -Directory $Directory
}
New-Alias -Name ... -Value SetLocationPathUpTwo