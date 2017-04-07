function MySQLStart {
    mysql.server start
}

function MySQLStop {
    mysql.server stop
}

function MySQLStatus {
    mysql.server status
}

function MySQLInitialize {
    mysqladmin --user=homestead --password=secret
}

function MySQLLogin {
    mysql --user=homestead --password=secret
}