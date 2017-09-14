function GetLongList {
    Get-ChildItem -Force "$args"
}
New-Alias -Name ll -Value GetLongList

function OpenHostsFile {
    if (ExistCommand -Name code) {
        if ($IsMacOS) {
            sudo code /etc/hosts
        } elseif ($IsWindows) {
            code C:\Windows\System32\drivers\etc\hosts
        }
    } else {
        Write-Warning -Message "Please install Visual Studio Code and install the 'code' command in PATH."
    }
}
New-Alias -Name hosts -Value OpenHostsFile

function SetLocationPath ([String] $Path, [String] $Directory) {
    $Location = Join-Path -Path $Path -ChildPath $Directory
    if (Test-Path -Path $Location) {
        Set-Location $Location
    } else {
        Write-Warning -Message "Cannot find path '$Location' because it does not exist."
        Write-Host 'Available directories:'
        Get-ChildItem -Name $Path | Write-Host -ForegroundColor DarkGray
    }
}

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