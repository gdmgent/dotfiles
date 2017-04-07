function JekyllServe {
    [CmdletBinding(PositionalBinding=$false)]
    Param(
        [Switch]
        [Alias('a')]
        $AtomEditor,

        [Switch]
        [Alias('c')]
        $CodeEditor,

        [Switch]
        [Alias('d')]
        $Drafts,

        [Switch]
        [Alias('f')]
        $Future,

        [Switch]
        [Alias('i')]
        $Incremental,

        [Switch]
        [Alias('o')]
        $Open,

        [Int]
        [ValidateRange(0,999)]
        [Alias('p')]
        $PortOffset,

        [Switch]
        [Alias('r')]
        $OpenRoot,

        [Switch]
        [Alias('u')]
        $Unpublished
    )
    if (IsJekyllSite) {
        $Command = "bundle exec jekyll serve"
        if ($AtomEditor) {
            atom .
        }
        if ($CodeEditor) {
            code .
        }
        if ($Drafts) {
            $Command += ' --drafts'
        }
        if ($Future) {
            $Command += ' --future'
        }
        if ($Incremental) {
            $Command += ' --incremental'
        }
        if ($PortOffset) {
            $Port = 4000 + $PortOffset
            $Command +=  " --port=$Port"
        }
        if ($Unpublished) {
            $Command += ' --unpublished'
        }
        if ($Open -or $OpenRoot) {
            if (! $OpenRoot) {
                $Directory = (Get-Item -Path .).Name.Replace('utl_', '') + '/'
            }
            if (! $PortOffset) {
                $Port = (Get-Content -Path ./_config.yml | Select-String -Pattern '^port\s*:\s*(\d+)$') -replace '^port\s*:\s*', ''
                if (! $Port) {
                    $Port = 4000;
                }
            }
            OpenUri -Uri "http://localhost:$Port/$Directory"
        }
        Invoke-Expression -Command "Clear-Host;$Command"
    }
}
New-Alias -Name js -Value JekyllServe

function IsJekyllSite {
    $File = "_config.yml"
    if (Test-Path -Path $File) {
        return $true
    } else {
        Write-Warning -Message "Cannot run Jekyll in this directory because a '$File' is required."
    }
}
