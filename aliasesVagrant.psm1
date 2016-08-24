# Import-Module esPath.psm1

function VagrantAliases {
    Get-Alias -Name v*
}
New-Alias -Name v -Value VagrantAliases

function VagrantBoxList {
    vagrant box list "$args"
}
New-Alias -Name vbl -Value VagrantBoxList

function VagrantBoxRemove {
    vagrant box remove laravel/homestead --box-version "$args"
}
New-Alias -Name vbr -Value VagrantBoxRemove

function VagrantBoxUpdate {
    vagrant box update "$args"
}
New-Alias -Name vbu -Value VagrantBoxUpdate

function VagrantDestroy {
    if (TestVagrantfile) {
        vagrant destroy "$args" 
    }
}
New-Alias -Name vd -Value VagrantDestroy

function VagrantGlobalStatus {
    vagrant global-status "$args"
}
New-Alias -Name vg -Value VagrantGlobalStatus

function VagrantGlobalStatusPrune {
    vagrant global-status --prune "$args"
}
New-Alias -Name vgp -Value VagrantGlobalStatusPrune

function VagrantHalt {
    if (TestVagrantfile) {
        vagrant halt "$args" 
    }
}
New-Alias -Name vh -Value VagrantHalt

function VagrantProvision {
    if (TestVagrantfile) {
        vagrant provision "$args" 
    }
}
New-Alias -Name vp -Value VagrantProvision

function VagrantReload {
    if (TestVagrantfile) {
        vagrant reload "$args" 
    }
}
New-Alias -Name vr -Value VagrantReload

function VagrantReloadProvision {
    if (TestVagrantfile) {
        vagrant reload --provision "$args" 
    }
}
New-Alias -Name vrp -Value VagrantReloadProvision

function VagrantSsh {
    if (TestVagrantfile) {
        vagrant ssh "$args" 
    }
}
New-Alias -Name vss -Value VagrantSsh

function VagrantStatus {
    if (TestVagrantfile) {
        vagrant status "$args" 
    }
}
New-Alias -Name vs -Value VagrantStatus

function VagrantSuspend {
    if (TestVagrantfile) {
        vagrant suspend "$args" 
    }
}
New-Alias -Name vsu -Value VagrantSuspend

function VagrantUp {
    if (TestVagrantfile) {
        vagrant up "$args" 
    }
}
New-Alias -Name vu -Value VagrantUp

function VagrantUpProvision {
    if (TestVagrantfile) {
        vagrant up --provision "$args" 
    }
}
New-Alias -Name vup -Value VagrantUpProvision

function TestVagrantfile {
    $file = "Vagrantfile"
    if (Test-Path $file) {
        return $true
    } else {
        Write-Warning -Message "Cannot run Vagrant in this directory because a '$file' is required."
    }
}