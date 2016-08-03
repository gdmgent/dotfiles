#!/bin/sh
composer self-update
composer global update
cgr drush/drush
cgr friendsofphp/php-cs-fixer
cgr gdmgent/artestead
cgr laravel/installer
cgr psy/psysh
cgr symfony/symfony-installer
cgr wp-cli/wp-cli