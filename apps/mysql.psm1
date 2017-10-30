function MySQLAliases {
    Get-Alias -Name my* | Select-Object -Property Name, ReferencedCommand
}
New-Alias -Name my -Value MySQLAliases 

if ($IsMacOS) {
    function MySQLStart {
        Param(
            [Switch]
            $Service
        )
        if ($Service) {
            brew services start mysql
        } else {
            mysql.server start
        }
    }
    New-Alias -Name myon -Value MySQLStart
}

if ($IsMacOS) {
    function MySQLStop {
        Param(
            [Switch]
            $Service
        )
        if ($Service) {
            brew services stop mysql
        } else {
            mysql.server stop
        }
    }
    New-Alias -Name myoff -Value MySQLStop
}
if ($IsMacOS) {
    function MySQLStatus {
        mysql.server status
    }
    New-Alias -Name mysts -Value MySQLStatus
}

function MySQLCreateDatabase {
    Param(
        [Parameter(Mandatory=$true)]
        [ValidateSet('cms','cmsdev','webdev1','webdev2','webtech2')]
        [String]
        $Course,

        [String]
        $DatabaseName,

        [ValidateSet('College','Default','Student','Test')]
        [String]
        $Mode = 'Default',

        [Int16]
        $Port = 3306,

        [Switch]
        $ShowSQL
    )
    if (! $DatabaseName) {
        $DatabaseName = "${Course}-db"
        switch ($Mode) {
            'College' {
                $DatabaseName = "${DatabaseName}-college"
            }
            'Student' {
                $DatabaseName = "${DatabaseName}-student"
            }
            'Test' {
                $DatabaseName = "${DatabaseName}-test"
            }
            Default {}
        }
    } else {
        $DatabaseName = $DatabaseName.ToLower()
        $Course       = $DatabaseName
    }
    $DatabaseUserUsername = "${Course}-user"
    $DatabaseUserPassword = "${Course}-pass"
    WriteMessage -Type Info -Message 'Creating Database for User...'
    [System.Environment]::SetEnvironmentVariable('MYSQL_PWD', $DatabaseUserPassword)
    $SQL = "CREATE DATABASE IF NOT EXISTS ``${DatabaseName}`` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;";
    if ($ShowSQL) {
        WriteMessage -Message "${SQL}";
        return
    }
    mysql --host=127.0.0.1 --port=${Port} --user=${DatabaseUserUsername} --execute="`"${SQL};`""
    WriteMessage -Type Success -Message 'Database created'
    WriteMessage -Message 'Database Name: ' -NoNewLine
    WriteMessage -Type Info -Message "'${DatabaseName}'"
    WriteMessage -Type Success -Message 'for Database User'
    WriteMessage -Message 'Username     : ' -NoNewLine
    WriteMessage -Type Info -Message "'${DatabaseUserUsername}'"
    WriteMessage -Message 'Password     : ' -NoNewLine
    WriteMessage -Type Info -Message "'${DatabaseUserPassword}'"
}
New-Alias -Name mycrdb -Value MySQLCreateDatabase

function MySQLCreateDatabaseUser {
    Param(
        [Parameter(Mandatory=$true)]
        [ValidateSet('cms','cmsdev','webdev1','webdev2','webtech2')]
        [String]
        $Course,

        [String]
        $DatabaseName,

        [ValidateSet('College','Default','Student','Test')]
        [String]
        $Mode = 'Default',

        [Int16]
        $Port = 3306,

        [Switch]
        $ShowSQL
    )
    if (! $Database) {
        $DatabaseName = "${Course}-db"
        switch ($Mode) {
            'College' {
                $DatabaseName = "${DatabaseName}-college"
            }
            'Student' {
                $DatabaseName = "${DatabaseName}-student"
            }
            'Test' {
                $DatabaseName = "${DatabaseName}-test"
            }
            Default {}
        }
    } else {
        $DatabaseName = $DatabaseName.ToLower()
        $Course       = $DatabaseName
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
        "CREATE USER IF NOT EXISTS '${DatabaseUserUsername}'@'localhost' IDENTIFIED BY '${DatabaseUserPassword}';",
        "GRANT ALL PRIVILEGES ON ``${DatabaseName}``.* TO '${DatabaseUserUsername}'@'localhost' WITH GRANT OPTION;"
    )
    $SQL = $SQL -join ''
    if ($ShowSQL) {
        WriteMessage -Message "${SQL}";
        return
    }
    mysql --host=127.0.0.1 --port=${Port} --user=${DatabaseAdministratorUsername} --execute="`"${SQL};`""
    WriteMessage -Type Success -Message 'Database User created'
    WriteMessage -Message 'Username                  : ' -NoNewLine
    WriteMessage -Type Info -Message "'${DatabaseUserUsername}'"
    WriteMessage -Message 'Password                  : ' -NoNewLine
    WriteMessage -Type Info -Message "'${DatabaseUserPassword}'"
    WriteMessage -Message 'Has privileges on database: ' -NoNewLine
    WriteMessage -Type Info -Message "'${DatabaseName}'"
}
New-Alias -Name mycruser -Value MySQLCreateDatabaseUser

function MySQLDropDatabase {
    Param(
        [Parameter(Mandatory=$true)]
        [ValidateSet('cms','cmsdev','webdev1','webdev2','webtech2')]
        [String]
        $Course,

        [String]
        $DatabaseName,

        [Int16]
        $Port = 3306,

        [ValidateSet('College','Default','Student','Test')]
        [String]
        $Mode = 'Default',

        [Switch]
        $ShowSQL
    )
    if (! $DatabaseName) {
        $DatabaseName= "${Course}-db"
        switch ($Mode) {
            'College' {
                $DatabaseName = "${DatabaseName}-college"
            }
            'Student' {
                $DatabaseName = "${DatabaseName}-student"
            }
            'Test' {
                $DatabaseName = "${DatabaseName}-test"
            }
            Default {}
        }
    } else {
        $DatabaseName = $DatabaseName.ToLower()
        $Course       = $DatabaseName
    }
    $DatabaseUserUsername = "${Course}-user"
    $DatabaseUserPassword = "${Course}-pass"
    WriteMessage -Type Info -Message 'Creating Database for User...'
    [System.Environment]::SetEnvironmentVariable('MYSQL_PWD', $DatabaseUserPassword)
    $SQL = "DROP DATABASE IF EXISTS ``${DatabaseName}``;";
    if ($ShowSQL) {
        WriteMessage -Message "${SQL}";
        return
    }
    mysql --host=127.0.0.1 --port=${Port} --user=${DatabaseUserUsername} --execute="`"${SQL};`""
    WriteMessage -Type Success -Message 'Database dropped'
    WriteMessage -Message 'Database Name: ' -NoNewLine
    WriteMessage -Type Info -Message "'${DatabaseName}'"
}
New-Alias -Name mydrdb -Value MySQLDropDatabase

function MySQLLogin {
    Param(
        [Parameter(Mandatory=$true)]
        [ValidateSet('cms','cmsdev','webdev1','webdev2','webtech2')]
        [String]
        $Course,

        [Int16]
        $Port = 3306,

        [Switch]
        $Root
    )
    if ($Root) {
        $Username = 'root'
        $Password = 'secret'
    } else {
        $Username = "${Course}-user"
        $Password = "${Course}-pass"
    }

    [System.Environment]::SetEnvironmentVariable('MYSQL_PWD', $Password)
    mysql --host=127.0.0.1 --port=${Port} --user="${Username}"
}
New-Alias -Name mylog -Value MySQLLogin