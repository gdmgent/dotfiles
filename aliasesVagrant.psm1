# Import-Module aliasesPath.psm1

function AliasVagrantAliases {
    Get-Alias -Name v*
}
New-Alias -Name v -Value AliasVagrantAliases

function AliasVagrantBoxList {
    vagrant box list "$args"
}
New-Alias -Name vbl -Value AliasVagrantBoxList

function AliasVagrantBoxRemove {
    vagrant box remove laravel/homestead --box-version "$args"
}
New-Alias -Name vbr -Value AliasVagrantBoxRemove

function AliasVagrantBoxUpdate {
    vagrant box update "$args"
}
New-Alias -Name vbu -Value AliasVagrantBoxUpdate

function AliasVagrantDestroy {
    if (TestVagrant) {
        vagrant destroy "$args" 
    }
}
New-Alias -Name vd -Value AliasVagrantDestroy

function AliasVagrantGlobalStatus {
    vagrant global-status "$args"
}
New-Alias -Name vg -Value AliasVagrantGlobalStatus

function AliasVagrantGlobalStatusPrune {
    vagrant global-status --prune "$args"
}
New-Alias -Name vgp -Value AliasVagrantGlobalStatusPrune

function AliasVagrantHalt {
    if (TestVagrant) {
        vagrant halt "$args" 
    }
}
New-Alias -Name vh -Value AliasVagrantHalt

function AliasVagrantProvision {
    if (TestVagrant) {
        vagrant provision "$args" 
    }
}
New-Alias -Name vp -Value AliasVagrantProvision

function AliasVagrantReload {
    if (TestVagrant) {
        vagrant reload "$args" 
    }
}
New-Alias -Name vr -Value AliasVagrantReload

function AliasVagrantReloadProvision {
    if (TestVagrant) {
        vagrant reload --provision "$args" 
    }
}
New-Alias -Name vrp -Value AliasVagrantReloadProvision

function AliasVagrantSsh {
    if (TestVagrant) {
        vagrant ssh "$args" 
    }
}
New-Alias -Name vss -Value AliasVagrantSsh

function AliasVagrantStatus {
    if (TestVagrant) {
        vagrant status "$args" 
    }
}
New-Alias -Name vs -Value AliasVagrantStatus

function AliasVagrantSuspend {
    if (TestVagrant) {
        vagrant suspend "$args" 
    }
}
New-Alias -Name vsu -Value AliasVagrantSuspend

function AliasVagrantUp {
    if (TestVagrant) {
        vagrant up "$args" 
    }
}
New-Alias -Name vu -Value AliasVagrantUp

function AliasVagrantUpProvision {
    if (TestVagrant) {
        vagrant up --provision "$args" 
    }
}
New-Alias -Name vup -Value AliasVagrantUpProvision

function TestVagrant {
    $file = "Vagrantfile"
    if (Test-Path $file) {
        return $true
    } else {
        Write-Warning -Message "Cannot run Vagrant in this directory because a '$file' is required."
    }
}