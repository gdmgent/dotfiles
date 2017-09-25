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

function MySQLInitialize {
    $DbAdminUser = 'root'
    $DbAdminPassword = 'secret'
    $DbUser = 'dbuser'
    $DbPassword = 'secret'
    [System.Environment]::SetEnvironmentVariable('MYSQL_PWD', $DbAdminPassword)
    mysql --host=127.0.0.1 --user=$DbAdminUser --execute="CREATE USER IF NOT EXISTS '${DbUser}'@'localhost' IDENTIFIED BY '${DbPassword}'; GRANT ALL PRIVILEGES ON *.* TO '${DbUser}'@'localhost' WITH GRANT OPTION;"
}
New-Alias -Name myinit -Value MySQLInitialize

function MySQLLogin {
    Set-Item Env:MYSQL_PWD -Value secret
    mysql --host=127.0.0.1 --user=dbuser
}
New-Alias -Name mydb -Value MySQLLogin