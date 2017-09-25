function MySQLAliases {
    Get-Alias -Name my* | Select-Object -Property Name, ReferencedCommand
}
New-Alias -Name my -Value MySQLAliases 

function MySQLStart {
    mysql.server start
}
New-Alias -Name myon -Value MySQLStart

function MySQLStartService {
    brew services start mysql
}
New-Alias -Name myonserv -Value MySQLStartService

function MySQLStop {
    mysql.server stop
}
New-Alias -Name myoff -Value MySQLStop

function MySQLStopService {
    brew services stop mysql
}
New-Alias -Name myoffserv -Value MySQLStopService

function MySQLStatus {
    mysql.server status
}
New-Alias -Name mysts -Value MySQLStatus

function MySQLCreateDbUser {
    Param(
        [Parameter(Mandatory=$true)]
        [ValidateSet('cms','cmsdev','webdev1','webdev2','webtech2')]
        [String]
        $Course,
        [String]
        $Database,
        [Switch]
        $ShowSQL
    )
    if (! $Database) {
        $Database= "${Course}-db"
    } else {
        $Database = $Database.ToLower()
        $Course = $Database
    }
    $DatabaseAdministratorUsername = 'root'
    $DatabaseAdministratorPassword = 'secret'
    $DatabaseUserUsername          = "${Course}-user"
    $DatabaseUserPassword          = "${Course}-pass"
    if ($DatabaseUserUsername.Length -gt 13) {
        WriteMessage -Type Danger -Message "The username '${DatabaseUserUsername}' is longer than the maximum allowed number of characters of 13."
        return
    }
    WriteMessage -Type Info -Message 'Creating Database User...'
    [System.Environment]::SetEnvironmentVariable('MYSQL_PWD', $DatabaseAdministratorPassword)
    $SQL = @(
        "CREATE USER IF NOT EXISTS '${DatabaseUserUsername}'@'localhost' IDENTIFIED BY '${DatabaseUserPassword}'",
        "GRANT ALL PRIVILEGES ON ``${Database}``.* TO '${DatabaseUserUsername}'@'localhost' WITH GRANT OPTION"
    )
    $SQL = $SQL -join ';'
    if ($ShowSQL) {
        WriteMessage -Message "${SQL}";
        return
    }
    mysql --host=127.0.0.1 --user=${DatabaseAdministratorUsername} --execute="`"${SQL};`""
    WriteMessage -Type Success -Message 'Database User created'
    WriteMessage -Message 'Username                  : ' -NoNewLine
    WriteMessage -Type Info -Message "'${DatabaseUserUsername}'"
    WriteMessage -Message 'Password                  : ' -NoNewLine
    WriteMessage -Type Info -Message "'${DatabaseUserPassword}'"
    WriteMessage -Message 'Has privileges on database: ' -NoNewLine
    WriteMessage -Type Info -Message "'${Database}'"
}
New-Alias -Name myuser -Value MySQLCreateDbUser

function MySQLLogin {
    Param(
        [Parameter(Mandatory=$true)]
        [ValidateSet('cms','cmsdev','webdev1','webdev2','webdtech2','root')]
        [String]
        $DbUser
    )
    $DbPassword = 'secret'
    [System.Environment]::SetEnvironmentVariable('MYSQL_PWD', $DbPassword)
    mysql --host=127.0.0.1 --user=$DbUser
}
New-Alias -Name mydb -Value MySQLLogin