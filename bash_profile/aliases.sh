# Add BASH aliases
alias dotfiles="cat ~/Code/dotfiles/VERSION"

alias ..="cd .."
alias ...="cd ../.."
alias c="cd ~/Code/"
alias h="cd ~"
alias s="cd ~/Syllabi/"

alias ll="ls -la"

alias hosts="sudo nano /etc/hosts"

# Git
alias add="git add ."
alias pull="git pull"
alias push="git push"
alias sts="git status"
alias wip="git commit -a -m [WIP] && git push"

# Jekyll
alias cjs="code . && js"
alias cjsd="code . && jsd"
alias cjsf="code . && jsf"
alias cjsi="code . && jsi"
alias cjsu="code . && jsu"
alias js="[ ! -f _config.yml ] && echo There is no _config.yml in this directory! || jekyll serve --watch"
alias jsd="[ ! -f _config.yml ] && echo There is no _config.yml in this directory! || jekyll serve --watch --drafts"
alias jsf="[ ! -f _config.yml ] && echo There is no _config.yml in this directory! || jekyll serve --watch --future"
alias jsi="[ ! -f _config.yml ] && echo There is no _config.yml in this directory! || jekyll serve --watch --incremental"
alias jsu="[ ! -f _config.yml ] && echo There is no _config.yml in this directory! || jekyll serve --watch --unpublished"

# Vagrant
alias vbl="[ !-f Vagrantfile ] && echo There is no Vagrantfile in this directory! || vagrant box list"
alias vbr="[ !-f Vagrantfile ] && echo There is no Vagrantfile in this directory! || vagrant box remove laravel/homestead --box-version "
alias vbu="[ !-f Vagrantfile ] && echo There is no Vagrantfile in this directory! || vagrant box update"
alias vd="[ !-f Vagrantfile ] && echo There is no Vagrantfile in this directory! || vagrant destroy"
alias vg="[ !-f Vagrantfile ] && echo There is no Vagrantfile in this directory! || vagrant global-status"
alias vgp="[ !-f Vagrantfile ] && echo There is no Vagrantfile in this directory! || vagrant global-status --prune"
alias vh="[ !-f Vagrantfile ] && echo There is no Vagrantfile in this directory! || vagrant halt"
alias vp="[ !-f Vagrantfile ] && echo There is no Vagrantfile in this directory! || vagrant provision"
alias vr="[ !-f Vagrantfile ] && echo There is no Vagrantfile in this directory! || vagrant reload"
alias vrp="[ !-f Vagrantfile ] && echo There is no Vagrantfile in this directory! || vagrant reload --provision"
alias vs="[ !-f Vagrantfile ] && echo There is no Vagrantfile in this directory! || vagrant status"
alias vss="[ !-f Vagrantfile ] && echo There is no Vagrantfile in this directory! || vagrant ssh"
alias vsu="[ !-f Vagrantfile ] && echo There is no Vagrantfile in this directory! || vagrant suspend"
alias vu="[ !-f Vagrantfile ] && echo There is no Vagrantfile in this directory! || vagrant up"
alias vup="[ !-f Vagrantfile ] && echo There is no Vagrantfile in this directory! || vagrant up --provision"

# OLODs
# -----

# Crossmedia Publishing
alias cmp="cd ~/Code/cmp.local/"
alias cmp-s="cd ~/Syllabi/cmp/ && open http://localhost:4000/cmp/ && cjsu"

# Crossmedia Publishing I, II & III
alias cmp1="cd ~/Code/cmp1.local/"
alias cmp2="cd ~/Code/cmp2.local/"
alias cmp3="cd ~/Code/cmp3.local/"

# E-design
alias ed="cd ~/Code/ed.local/"
alias ed-s="cd ~/Syllabi/ed/ && open http://localhost:4000/ed && cjsu"

# Mulimedia-applicaties
alias mapps="cd ~/Code/mapps.local/"
alias mapps-s="cd ~/Syllabi/mapps/ && open http://localhost:4000/mapps/ && cjs"

alias mma="cd ~/Code/mma.local/"
alias mma-s="cd ~/Syllabi/mma/ && open http://localhost:4000/mma/ && cjsu"

# New Media Design & Development II
alias nmdad2="cd ~/Code/nmdad2.local/"
alias nmdad2-s="cd ~/Syllabi/nmdad2/ && open http://localhost:4000/nmdad2/ && cjsu"

# New Media Design & Development III
alias nmdad3="cd ~/Code/nmdad3.local/"
alias nmdad3-s="cd ~/Syllabi/nmdad3/ && open http://localhost:4000/nmdad3/ && cjsu"

# Webdesign I & II
alias webd="cd ~/Code/webd.local/"
alias webd-s="cd ~/Syllabi/webd/ && open http://localhost:4000/webd/ && cjsu"

# Syllabi
# -------

# Artestead
alias artestead-c="cd ~/Code/artestead/"
alias artestead-s="cd ~/Syllabi/artestead-doc/ && open http://localhost:4000/artestead/ && cjsu"

# Dotfiles
alias dotfiles-c="cd ~/Code/dotfiles/"
alias dotfiles-s="cd ~/Syllabi/dotfiles-doc/ && open http://localhost:4000/dotfiles/ && cjsu"

# Syllabus
alias syllabus-s="cd ~/Syllabi/syllabus/ && open http://localhost:4000/syllabus/ && cjsu"

# Web & New Media
alias wanm-s="cd ~/Syllabi/wanm/ && open http://localhost:4000/wanm/ && cjsu"

function artisan() {
    if [ -f artisan ]
    then
        php artisan "$@"
    else
        echo "Laravel Artisan is not available from this directory!"
    fi
}

function behat() {
    if [ -f bin/behat ]
    then
        php bin/behat "$@"
    else
        if [ -f vendor/bin/behat ]
        then
            php vendor/bin/behat "$@"
        else
            command phpunit "$@"
        fi
    fi
}

function console() {
    if [ -f bin/console ]
    then
        php bin/console "$@"
    else
        if [ -f app/console ]
        then
            php app/console "$@"
        else
            echo "Symfony Console is not available from this directory!"
        fi
    fi
}

function phpunit() {
    if [ -f bin/phpunit ]
    then
        php bin/phpunit "$@"
    else
        if [ -f vendor/bin/phpunit ]
        then
            php vendor/bin/phpunit "$@"
        else
            command phpunit "$@"
        fi
    fi
}

