@ECHO OFF
composer config --global repositories.artestead vcs https://github.com/gdmghent/artestead.git
composer global require gdmghent/artestead
artestead init --skip --vagrant-plugin-install