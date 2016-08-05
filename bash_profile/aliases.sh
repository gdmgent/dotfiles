# Add BASH aliases
alias artisan="php artisan"
alias console="php app/console"

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
alias js="jekyll serve --watch"
alias jsd="jekyll serve --watch --drafts"
alias jsf="jekyll serve --watch --future"
alias jsi="jekyll serve --watch --incremental"
alias jsu="jekyll serve --watch --unpublished"

# Vagrant
alias vbl="vagrant box list"
alias vbr="vagrant box remove laravel/homestead --box-version"
alias vbu="vagrant box update"
alias vd="vagrant destroy"
alias vg="vagrant global-status"
alias vgp="vagrant global-status --prune"
alias vh="vagrant halt"
alias vp="vagrant provision"
alias vr="vagrant reload"
alias vrp="vagrant reload --provision"
alias vs="vagrant status"
alias vss="vagrant ssh"
alias vsu="vagrant suspend"
alias vu="vagrant up"
alias vup="vagrant up --provision"

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