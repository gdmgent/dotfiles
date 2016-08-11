@echo off
call vagrant plugin install vagrant-hostsupdater
rem call composer config --global repositories.artestead vcs https://github.com/gdmgent/artestead.git && composer g require gdmgent/artestead
rem call composer g require gdmgent/artestead
call cgr gdmgent/artestead