#!/bin/sh
echo "Remove local Artestead and Vagrant"
vagrant destroy
rm -rfi .gitignore .vagrant/ *.yaml Vagrantfile *.sh composer.* vendor/