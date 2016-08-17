@echo off
echo Remove local Artestead and Vagrant
vagrant destroy && rm -rf .vagrant/
rm -rf vendor/
rm -i .gitignore *.yaml Vagrantfile *.sh composer.*
