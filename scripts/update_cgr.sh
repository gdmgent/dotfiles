#!/bin/sh
composer self-update
composer global update
cgr drush/drush
cgr laravel/installer
cgr psy/psysh
cgr symfony/symfony-installer
cgr wp-cli/wp-cli
