@echo off
call composer self-update
call composer global update
call cgr drush/drush
call cgr laravel/installer
call cgr psy/psysh
call cgr symfony/symfony-installer
call cgr wp-cli/wp-cli
