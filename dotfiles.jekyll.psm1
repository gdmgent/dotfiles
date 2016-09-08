# Import-Module ./dotfiles.jekyll.psm1

function CodeJekyllServe {
    if (IsJekyllSite) {
        code .
        JekyllServe $args
    }
}
New-Alias -Name cjs -Value CodeJekyllServe

function CodeJekyllServeUnpublished {
    if (IsJekyllSite) {
        code .
        JekyllServeUnpublished $args
    }
}
New-Alias -Name cjsu -Value CodeJekyllServeUnpublished

function JekyllServe {
    if (IsJekyllSite) {
        $Directory = (Get-Item -Path '.').Name
        $Uri = "http://127.0.0.1:4000/$Directory/"
        if ($IsOSX) {
            Invoke-Expression "open $Uri".Replace('utl_', '')
        } elseif ($IsWindows) {
            Invoke-Expression "cmd.exe /C 'start $Uri'".Replace('utl_', '')
        }
        Invoke-Expression "jekyll serve --watch $args"
    }
}
New-Alias -Name js -Value JekyllServe

function JekyllServeDrafts {
    JekyllServe --drafts $args
}
New-Alias -Name jsd -Value JekyllServeDrafts

function JekyllServeFuture {
    JekyllServe --future $args
}
New-Alias -Name jsf -Value JekyllServeFuture

function JekyllServeIncremental {
    JekyllServe --incremental $args
}
New-Alias -Name jsi -Value JekyllServeIncremental

function JekyllServeUnpublished {
    JekyllServe --unpublished $args
}
New-Alias -Name jsu -Value JekyllServeUnpublished

function IsJekyllSite {
    $File = "_config.yml"
    if (Test-Path $File) {
        return $true
    } else {
        Write-Warning -Message "Cannot run Jekyll in this directory because a '$File' is required."
    }
}