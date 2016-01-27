@ECHO OFF
vagrant plugin install vagrant-hostsupdater
composer config --global repositories.artestead vcs https://github.com/gdmgent/artestead.git
composer global require gdmgent/artestead