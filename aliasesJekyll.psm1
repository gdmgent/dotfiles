# Import-Module aliasesJekyll.psm1

function AliasCodeJekyllServe {
    if (TestJekyll) {
        code .
        js "$args"
    }
}
New-Alias -Name cjs -Value AliasCodeJekyllServe

function AliasCodeJekyllServeUnpublished {
    if (TestJekyll) {
        code .
        jsu "$args"
    }
}
New-Alias -Name cjsu -Value AliasCodeJekyllServeUnpublished

function AliasJekyllServe {
    if (TestJekyll) {
        jekyll serve --watch "$args"
    }
}
New-Alias -Name js -Value AliasJekyllServe

function AliasJekyllServeDrafts {
    AliasJekyllServe --drafts "args"
}
New-Alias -Name jsd -Value AliasJekyllServeDrafts

function AliasJekyllServeFuture {
    AliasJekyllServe --future "args"
}
New-Alias -Name jsf -Value AliasJekyllServeFuture

function AliasJekyllServeIncremental {
    AliasJekyllServe --incremental "args"
}
New-Alias -Name jsi -Value AliasJekyllServeIncremental

function AliasJekyllServeUnpublished {
    AliasJekyllServe --unpublished "args"
}
New-Alias -Name jsu -Value AliasJekyllServeUnpublished

function TestJekyll {
    $file = "_config.yml"
    if (Test-Path $file) {
        return $true
    } else {
        Write-Warning -Message "Cannot run Jekyll in this directory because a '$file' is required."
    }
}