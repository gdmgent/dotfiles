@echo off
call composer self-update
call composer global update
call cgr drush/drush
call cgr friendsofphp/php-cs-fixer
call cgr gdmgent/artestead
call cgr laravel/installer
call cgr psy/psysh
call cgr symfony/symfony-installer
call cgr wp-cli/wp-cli