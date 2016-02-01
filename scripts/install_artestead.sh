#!/bin/sh
vagrant plugin install vagrant-hostsupdater
composer config --global repositories.artestead vcs https://github.com/gdmgent/artestead.git
composer g require gdmgent/artestead