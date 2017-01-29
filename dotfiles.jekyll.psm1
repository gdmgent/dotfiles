function JekyllServe {
    [CmdletBinding(PositionalBinding=$false)]
    Param(
        [Switch]
        [Alias('c')]
        $Code,
        
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
        [ValidateRange(4000,4999)]
        [Alias('p')]
        $Port = 4000,

        [Switch]
        [Alias('r')]
        $OpenRoot,

        [Switch]
        [Alias('u')]
        $Unpublished
    )
    if (IsJekyllSite) {
        $Command = "bundle exec jekyll serve --port=$Port"
        if ($Code) {
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
        if ($Open -or $OpenRoot) {
            if (!$OpenRoot) {
                $Directory = (Get-Item -Path .).Name.Replace('utl_', '') + '/'
            }
            OpenUri -Uri "http://127.0.0.1:$Port/$Directory"
        }
        if ($Unpublished) {
            $Command += ' --unpublished'
        }
        Invoke-Expression -Command $Command
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