function MySQLStart {
    mysql.server start
}
New-Alias -Name myon -Value MySQLStart

function MySQLStop {
    mysql.server stop
}
New-Alias -Name myoff -Value MySQLStop

function MySQLStatus {
    mysql.server status
}
New-Alias -Name mysts -Value MySQLStatus

function MySQLInitialize {
    mysql --host=127.0.0.1 --user=root --execute="CREATE USER 'homestead'@'localhost' IDENTIFIED BY 'secret';GRANT ALL PRIVILEGES ON *.* TO 'homestead'@'localhost' WITH GRANT OPTION;"
}
New-Alias -Name myinit -Value MySQLInitialize

function MySQLLogin {
    mysql --host=127.0.0.1 --user=homestead --password=secret
}
New-Alias -Name mydb -Value MySQLLogin